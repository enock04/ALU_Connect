-- ALU Connect – initial schema
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New Query)

-- ─── EXTENSIONS ────────────────────────────────────────────────────────────────
create extension if not exists "uuid-ossp";

-- ─── PROFILES ──────────────────────────────────────────────────────────────────
create table public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  full_name    text not null,
  username     text unique not null,
  avatar_url   text,
  role         text not null default 'student'  -- student | organiser | club_leader
                 check (role in ('student', 'organiser', 'club_leader')),
  bio          text,
  campus       text,
  cohort_year  int,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view any profile"
  on public.profiles for select using (true);

create policy "Users can update their own profile"
  on public.profiles for update using (auth.uid() = id);

create policy "Users can insert their own profile"
  on public.profiles for insert with check (auth.uid() = id);

-- auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, full_name, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'New Student'),
    coalesce(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8))
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ─── POSTS (events, jobs, networking, etc.) ────────────────────────────────────
create table public.posts (
  id               uuid primary key default uuid_generate_v4(),
  author_id        uuid not null references public.profiles(id) on delete cascade,
  type             text not null
                     check (type in ('school_event','job_internship','networking',
                                     'venture_support','entertainment','src')),
  subtype          text,
  title            text not null,
  body             text not null,
  image_url        text,
  event_date       timestamptz,
  location         text,
  rsvp_count       int not null default 0,
  capacity         int,
  deadline         timestamptz,
  compensation_info text,
  created_at       timestamptz not null default now()
);

alter table public.posts enable row level security;

create policy "Anyone can read posts"
  on public.posts for select using (true);

create policy "Organisers and club leaders can insert posts"
  on public.posts for insert with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid()
        and role in ('organiser', 'club_leader')
    )
  );

create policy "Authors can update their own posts"
  on public.posts for update using (author_id = auth.uid());

create policy "Authors can delete their own posts"
  on public.posts for delete using (author_id = auth.uid());

-- ─── RSVPS ─────────────────────────────────────────────────────────────────────
create table public.rsvps (
  id         uuid primary key default uuid_generate_v4(),
  post_id    uuid not null references public.posts(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

alter table public.rsvps enable row level security;

create policy "Users can manage their own RSVPs"
  on public.rsvps for all using (user_id = auth.uid());

create policy "Anyone can read RSVP counts"
  on public.rsvps for select using (true);

-- keep rsvp_count in sync
create or replace function public.update_rsvp_count()
returns trigger language plpgsql as $$
begin
  if tg_op = 'INSERT' then
    update public.posts set rsvp_count = rsvp_count + 1 where id = new.post_id;
  elsif tg_op = 'DELETE' then
    update public.posts set rsvp_count = rsvp_count - 1 where id = old.post_id;
  end if;
  return null;
end;
$$;

create trigger rsvp_count_trigger
  after insert or delete on public.rsvps
  for each row execute function public.update_rsvp_count();

-- ─── IDEAS ─────────────────────────────────────────────────────────────────────
create table public.ideas (
  id                 uuid primary key default uuid_generate_v4(),
  founder_id         uuid not null references public.profiles(id) on delete cascade,
  title              text not null,
  problem_statement  text not null,
  domain             text not null
                       check (domain in ('agri_tech','health_tech','ed_tech',
                                         'fin_tech','clean_tech','logistics','other')),
  skills_needed      text[] not null default '{}',
  backer_count       int not null default 0,
  team_chat_room_id  uuid,
  created_at         timestamptz not null default now()
);

alter table public.ideas enable row level security;

create policy "Anyone can read ideas"
  on public.ideas for select using (true);

create policy "Any student can post an idea"
  on public.ideas for insert with check (auth.uid() = founder_id);

create policy "Founder can update their idea"
  on public.ideas for update using (founder_id = auth.uid());

-- ─── IDEA BACKERS ──────────────────────────────────────────────────────────────
create table public.idea_backers (
  id         uuid primary key default uuid_generate_v4(),
  idea_id    uuid not null references public.ideas(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (idea_id, user_id)
);

alter table public.idea_backers enable row level security;

create policy "Users manage their own backing"
  on public.idea_backers for all using (user_id = auth.uid());

create policy "Anyone can read backer list"
  on public.idea_backers for select using (true);

-- keep backer_count in sync + unlock chat at threshold
create or replace function public.update_backer_count()
returns trigger language plpgsql as $$
declare
  new_count int;
begin
  if tg_op = 'INSERT' then
    update public.ideas set backer_count = backer_count + 1
    where id = new.idea_id
    returning backer_count into new_count;

    -- unlock team chat room when threshold (3) is reached
    if new_count >= 3 then
      insert into public.chat_rooms (idea_id, name)
      select new.idea_id, i.title || ' – Team Chat'
      from public.ideas i
      where i.id = new.idea_id and i.team_chat_room_id is null
      on conflict do nothing;

      update public.ideas
      set team_chat_room_id = (
        select id from public.chat_rooms where idea_id = new.idea_id limit 1
      )
      where id = new.idea_id and team_chat_room_id is null;
    end if;

  elsif tg_op = 'DELETE' then
    update public.ideas set backer_count = backer_count - 1 where id = old.idea_id;
  end if;
  return null;
end;
$$;

create trigger backer_count_trigger
  after insert or delete on public.idea_backers
  for each row execute function public.update_backer_count();

-- ─── CHAT ROOMS ────────────────────────────────────────────────────────────────
create table public.chat_rooms (
  id         uuid primary key default uuid_generate_v4(),
  idea_id    uuid references public.ideas(id) on delete cascade,
  name       text not null,
  created_at timestamptz not null default now()
);

alter table public.chat_rooms enable row level security;

create policy "Anyone can read chat rooms"
  on public.chat_rooms for select using (true);

-- ─── MESSAGES ──────────────────────────────────────────────────────────────────
create table public.messages (
  id          uuid primary key default uuid_generate_v4(),
  room_id     uuid not null references public.chat_rooms(id) on delete cascade,
  sender_id   uuid not null references public.profiles(id) on delete cascade,
  sender_name text not null,
  body        text not null,
  created_at  timestamptz not null default now()
);

alter table public.messages enable row level security;

create policy "Anyone can read messages"
  on public.messages for select using (true);

create policy "Authenticated users can send messages"
  on public.messages for insert with check (auth.uid() = sender_id);

-- enable realtime for live chat
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.posts;
