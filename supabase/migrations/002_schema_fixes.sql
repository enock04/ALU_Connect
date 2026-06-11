-- ALU Connect – schema fixes & additions
-- Apply AFTER 001_initial_schema.sql
-- Run in Supabase Dashboard → SQL Editor → New Query

-- ─── 1. FIX posts TABLE ────────────────────────────────────────────────────
-- Add denormalised author fields (avoids a join on every feed load)
alter table public.posts
  add column if not exists author_name    text not null default 'Unknown',
  add column if not exists author_avatar  text,
  add column if not exists author_role    text,
  add column if not exists category       text;   -- maps to EventCategory: academic|career|social|venture|student

-- Fix type check constraint: Dart enum .name produces camelCase, not snake_case
alter table public.posts drop constraint if exists posts_type_check;
alter table public.posts
  add constraint posts_type_check
    check (type in ('schoolEvent','jobInternship','networking',
                    'ventureSupport','entertainment','src'));

-- ─── 2. FIX ideas TABLE ────────────────────────────────────────────────────
-- Same camelCase issue for domain values
alter table public.ideas drop constraint if exists ideas_domain_check;
alter table public.ideas
  add constraint ideas_domain_check
    check (domain in ('agriTech','healthTech','edTech',
                      'finTech','cleanTech','logistics','other'));

-- ideas also needs founderName for the card display (denormalised)
alter table public.ideas
  add column if not exists founder_name   text not null default 'Unknown',
  add column if not exists founder_avatar text;

-- ─── 3. FIX messages TABLE ────────────────────────────────────────────────
-- Code inserts/queries 'sent_at'; schema currently uses 'created_at'.
-- Add sent_at as the canonical timestamp; keep created_at for compatibility.
alter table public.messages
  add column if not exists sent_at        timestamptz not null default now(),
  add column if not exists sender_avatar  text;

-- Back-fill sent_at from created_at for any existing rows
update public.messages set sent_at = created_at where sent_at = now();

-- ─── 4. FIX chat_rooms TABLE ──────────────────────────────────────────────
-- Provider queries type, description, member_count, last_message, last_message_at
alter table public.chat_rooms
  add column if not exists type             text not null default 'community'
    check (type in ('community', 'team_chat')),
  add column if not exists description      text,
  add column if not exists member_count     int  not null default 0,
  add column if not exists last_message     text,
  add column if not exists last_message_at  timestamptz;

-- Back-fill existing idea-linked rooms as team_chat
update public.chat_rooms set type = 'team_chat' where idea_id is not null;

-- ─── 5. CREATE community_members TABLE ────────────────────────────────────
create table if not exists public.community_members (
  id         uuid primary key default uuid_generate_v4(),
  room_id    uuid not null references public.chat_rooms(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  joined_at  timestamptz not null default now(),
  unique (room_id, user_id)
);

alter table public.community_members enable row level security;

create policy "Users manage their own membership"
  on public.community_members for all using (user_id = auth.uid());

create policy "Anyone can read community membership"
  on public.community_members for select using (true);

-- ─── 6. increment_member_count RPC ────────────────────────────────────────
-- Called by joinCommunity() — best-effort, provider wraps in catchError
create or replace function public.increment_member_count(room_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.chat_rooms
  set member_count = member_count + 1
  where id = room_id;
end;
$$;

-- ─── 7. last_message trigger ──────────────────────────────────────────────
-- Keep chat_rooms.last_message / last_message_at in sync on every insert
create or replace function public.update_room_last_message()
returns trigger language plpgsql as $$
begin
  update public.chat_rooms
  set last_message    = new.body,
      last_message_at = new.sent_at
  where id = new.room_id;
  return null;
end;
$$;

drop trigger if exists room_last_message_trigger on public.messages;
create trigger room_last_message_trigger
  after insert on public.messages
  for each row execute function public.update_room_last_message();

-- ─── 8. SEED community rooms ──────────────────────────────────────────────
-- The communities tab falls back to mock data if this table is empty.
-- These five rows give the app real data to work with immediately.
insert into public.chat_rooms (name, description, type, member_count)
values
  ('Tech & Innovation',    'Software, hardware, and cutting-edge ideas.',                   'community', 142),
  ('Entrepreneurship Hub', 'Founders, aspiring founders, and everyone in between.',          'community',  89),
  ('Creative Arts & Media','Photography, design, music, and storytelling at ALU.',           'community',  67),
  ('Sports & Wellness',    'Football, basketball, yoga — stay active, stay healthy.',        'community', 201),
  ('SRC Updates',          'Official announcements from the Student Representative Council.','community', 480)
on conflict do nothing;

-- ─── 9. INDEXES ────────────────────────────────────────────────────────────
create index if not exists idx_posts_type           on public.posts(type);
create index if not exists idx_posts_event_date     on public.posts(event_date);
create index if not exists idx_messages_room_sent   on public.messages(room_id, sent_at);
create index if not exists idx_community_members_uid on public.community_members(user_id);
create index if not exists idx_chat_rooms_type      on public.chat_rooms(type);
create index if not exists idx_idea_backers_idea    on public.idea_backers(idea_id);

-- ─── 10. REALTIME ──────────────────────────────────────────────────────────
-- messages already added in 001; add chat_rooms so community list updates live
alter publication supabase_realtime add table public.chat_rooms;
