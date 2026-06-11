-- ALU Connect – seed data for dev / demo
-- Run AFTER 001_initial_schema.sql and 002_schema_fixes.sql
-- Supabase SQL Editor → New Query

-- ─── 1. DUMMY AUTH USERS ─────────────────────────────────────────────────────
-- We insert directly into auth.users so profiles can reference them.
-- These are throwaway dev accounts — passwords are all "Password1!"

insert into auth.users (
  id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_user_meta_data, is_super_admin, confirmation_token,
  recovery_token, email_change_token_new, email_change
)
values
  ('00000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated',
   'amara@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Amara Diallo","username":"amara_d"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated',
   'kofi@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Kofi Mensah","username":"kofi_m"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated',
   'zanele@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Zanele Dube","username":"zanele_d"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated',
   'tolu@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Tolu Adeyemi","username":"tolu_a"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated',
   'naledi@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Naledi Khumalo","username":"naledi_k"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000006', 'authenticated', 'authenticated',
   'ibrahim@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Ibrahim Sawadogo","username":"ibrahim_s"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000007', 'authenticated', 'authenticated',
   'priya@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Priya Nkosi","username":"priya_n"}'::jsonb,
   false, '', '', '', ''),

  -- organiser account — can post events
  ('00000000-0000-0000-0000-000000000010', 'authenticated', 'authenticated',
   'ventures@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"ALU Ventures Club","username":"alu_ventures"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000011', 'authenticated', 'authenticated',
   'careers@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Career Services","username":"career_services"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000012', 'authenticated', 'authenticated',
   'src@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Student Representative Council","username":"src_alu"}'::jsonb,
   false, '', '', '', ''),

  ('00000000-0000-0000-0000-000000000013', 'authenticated', 'authenticated',
   'techcrew@alu.edu', crypt('Password1!', gen_salt('bf')),
   now(), now(), now(),
   '{"full_name":"Tech Crew ALU","username":"tech_crew"}'::jsonb,
   false, '', '', '', '')

on conflict (id) do nothing;

-- ─── 2. PROFILES ─────────────────────────────────────────────────────────────
insert into public.profiles (id, full_name, username, role, campus, cohort_year)
values
  ('00000000-0000-0000-0000-000000000001', 'Amara Diallo',    'amara_d',         'student',    'Kigali', 2024),
  ('00000000-0000-0000-0000-000000000002', 'Kofi Mensah',     'kofi_m',          'student',    'Kigali', 2023),
  ('00000000-0000-0000-0000-000000000003', 'Zanele Dube',     'zanele_d',        'student',    'Lagos',  2024),
  ('00000000-0000-0000-0000-000000000004', 'Tolu Adeyemi',    'tolu_a',          'student',    'Lagos',  2025),
  ('00000000-0000-0000-0000-000000000005', 'Naledi Khumalo',  'naledi_k',        'student',    'Kigali', 2024),
  ('00000000-0000-0000-0000-000000000006', 'Ibrahim Sawadogo','ibrahim_s',       'student',    'Kigali', 2023),
  ('00000000-0000-0000-0000-000000000007', 'Priya Nkosi',     'priya_n',         'student',    'Lagos',  2025),
  ('00000000-0000-0000-0000-000000000010', 'ALU Ventures Club','alu_ventures',   'club_leader','Kigali', 2022),
  ('00000000-0000-0000-0000-000000000011', 'Career Services', 'career_services', 'organiser',  'Kigali', 2022),
  ('00000000-0000-0000-0000-000000000012', 'Student Representative Council','src_alu','organiser','Kigali',2022),
  ('00000000-0000-0000-0000-000000000013', 'Tech Crew ALU',   'tech_crew',       'club_leader','Kigali', 2022)
on conflict (id) do nothing;

-- ─── 3. IDEAS ────────────────────────────────────────────────────────────────
insert into public.ideas
  (id, founder_id, founder_name, title, problem_statement, domain, skills_needed, backer_count)
values
  ('10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001', 'Amara Diallo',
   'Campus Ride-Share App',
   'ALU students spend too much on transport between campus and the city. There is no coordinated way to split rides with peers going the same direction.',
   'logistics', array['developer','designer'], 2),

  ('10000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000002', 'Kofi Mensah',
   'Africa Study Abroad Network',
   'African students rarely do study exchanges within Africa — most programs are Western-focused. There is no platform connecting universities continent-wide for intra-Africa exchanges.',
   'edTech', array['developer','marketer','operations'], 5),

  ('10000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000003', 'Zanele Dube',
   'Micro-Lending for Students',
   'Students facing unexpected expenses have no fast, zero-interest option. Bank loans are slow; asking friends is awkward. A peer-backed micro-loan pool could solve this.',
   'finTech', array['developer','finance','legal'], 8),

  ('10000000-0000-0000-0000-000000000004',
   '00000000-0000-0000-0000-000000000004', 'Tolu Adeyemi',
   'Farmer-to-Market Price Alert System',
   'Smallholder farmers in Rwanda and Nigeria sell below market value because they have no visibility on real-time commodity prices at nearby markets. An SMS + app price-alert tool could close that information gap.',
   'agriTech', array['developer','operations','marketer'], 3),

  ('10000000-0000-0000-0000-000000000005',
   '00000000-0000-0000-0000-000000000005', 'Naledi Khumalo',
   'Mental Health Check-In Platform',
   'Most ALU students go through at least one mental health rough patch per semester but counselling slots are limited and often carry stigma. An anonymous peer-support and mood-tracking platform could bridge the gap.',
   'healthTech', array['developer','designer','legal'], 11),

  ('10000000-0000-0000-0000-000000000006',
   '00000000-0000-0000-0000-000000000006', 'Ibrahim Sawadogo',
   'Solar Kiosk Co-op for Off-Grid Communities',
   'Millions of households in sub-Saharan Africa still lack reliable electricity. A student-run co-op model for solar kiosk franchising — owned by local communities — could make clean energy accessible without heavy upfront costs.',
   'cleanTech', array['finance','operations','legal'], 6),

  ('10000000-0000-0000-0000-000000000007',
   '00000000-0000-0000-0000-000000000007', 'Priya Nkosi',
   'Campus Skills Swap Marketplace',
   'Students at ALU have wildly different skill sets — one person knows Python, another knows Figma, another is a great writer. There is no structured way to trade skills without money changing hands.',
   'other', array['developer','designer'], 4)

on conflict (id) do nothing;

-- ─── 4. POSTS (EVENTS) ───────────────────────────────────────────────────────
insert into public.posts
  (id, author_id, author_name, author_role, type, category,
   title, body, location, event_date, rsvp_count, capacity)
values
  ('20000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000010', 'ALU Ventures Club', 'club_leader',
   'schoolEvent', 'venture',
   'Startup Pitch Night — Kigali',
   'Present your venture to a panel of investors and ALU faculty. Selected pitches receive seed funding up to $5,000.',
   'ALU Auditorium, Kigali',
   now() + interval '7 days', 42, 80),

  ('20000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000011', 'Career Services', 'organiser',
   'schoolEvent', 'career',
   'LinkedIn Profile Workshop',
   'Optimise your LinkedIn for internship and job hunting. Bring your laptop — live profile edits with Career Services.',
   'Block B, Seminar Room 3',
   now() + interval '3 days', 28, 30),

  ('20000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000012', 'Student Representative Council', 'organiser',
   'schoolEvent', 'social',
   'Pan-African Culture Festival 2026',
   'Celebrate ALU''s diversity with food, music, art, and performances from across the continent.',
   'ALU Campus Grounds',
   now() + interval '14 days', 156, null),

  ('20000000-0000-0000-0000-000000000004',
   '00000000-0000-0000-0000-000000000013', 'Tech Crew ALU', 'club_leader',
   'schoolEvent', 'academic',
   'ML Study Circle — Backprop from Scratch',
   'Weekly deep-dive into ML fundamentals. This week: implementing backpropagation in pure Python.',
   'Innovation Lab, Floor 2',
   now() + interval '2 days', 19, 25),

  ('20000000-0000-0000-0000-000000000005',
   '00000000-0000-0000-0000-000000000012', 'Student Representative Council', 'organiser',
   'schoolEvent', 'student',
   'SRC Town Hall — Semester 2',
   'Open forum with student leadership. Raise concerns, vote on policy changes, and hear updates on campus projects.',
   'Main Lecture Hall',
   now() + interval '5 days', 87, null)

on conflict (id) do nothing;
