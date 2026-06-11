-- Migration 004 – Fix update_backer_count trigger to set type='team_chat'
--
-- Problem: migration 001 created the trigger before migration 002 added the
-- `type` column to chat_rooms with a default of 'community'. Any team chat
-- room auto-created by the trigger after 002 runs receives type='community',
-- causing it to appear in the communities list and making ChatRoom.isTeamChat
-- return false. This replaces the trigger function to set type='team_chat'
-- explicitly on insert.

create or replace function public.update_backer_count()
returns trigger language plpgsql as $$
declare
  new_count int;
begin
  if tg_op = 'INSERT' then
    update public.ideas
    set backer_count = backer_count + 1
    where id = new.idea_id
    returning backer_count into new_count;

    -- unlock team chat room when threshold (3) is reached
    if new_count >= 3 then
      insert into public.chat_rooms (idea_id, name, type)
      select
        new.idea_id,
        i.title || ' – Team Chat',
        'team_chat'          -- ← explicit type (was missing in 001)
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
    update public.ideas
    set backer_count = backer_count - 1
    where id = old.idea_id;
  end if;

  return null;
end;
$$;
