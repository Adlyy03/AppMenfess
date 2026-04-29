-- One-table identity setup: use auth.users as the only users source
-- Run in Supabase SQL Editor

begin;

-- 1) Ensure menfess.user_id references auth.users(id)
alter table if exists public.menfess
  drop constraint if exists menfess_user_id_fkey;

alter table if exists public.menfess
  add constraint menfess_user_id_fkey
  foreign key (user_id)
  references auth.users(id)
  on delete set null;

-- 2) Reactions and comments should also point to auth.users
alter table if exists public.reactions
  drop constraint if exists reactions_user_id_fkey;

alter table if exists public.reactions
  add constraint reactions_user_id_fkey
  foreign key (user_id)
  references auth.users(id)
  on delete set null;

alter table if exists public.comments
  drop constraint if exists comments_user_id_fkey;

alter table if exists public.comments
  add constraint comments_user_id_fkey
  foreign key (user_id)
  references auth.users(id)
  on delete set null;

-- 3) RLS: menfess (public read, owner write)
alter table public.menfess enable row level security;

drop policy if exists menfess_select_all on public.menfess;
create policy menfess_select_all
  on public.menfess
  for select
  using (true);

drop policy if exists menfess_insert_own on public.menfess;
create policy menfess_insert_own
  on public.menfess
  for insert
  with check (auth.uid() = user_id);

drop policy if exists menfess_update_own on public.menfess;
create policy menfess_update_own
  on public.menfess
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists menfess_delete_own on public.menfess;
create policy menfess_delete_own
  on public.menfess
  for delete
  using (auth.uid() = user_id);

-- 4) RLS: comments
alter table public.comments enable row level security;

drop policy if exists comments_select_all on public.comments;
create policy comments_select_all
  on public.comments
  for select
  using (true);

drop policy if exists comments_insert_own on public.comments;
create policy comments_insert_own
  on public.comments
  for insert
  with check (auth.uid() = user_id);

drop policy if exists comments_update_own on public.comments;
create policy comments_update_own
  on public.comments
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists comments_delete_own on public.comments;
create policy comments_delete_own
  on public.comments
  for delete
  using (auth.uid() = user_id);

-- 5) RLS: reactions
alter table public.reactions enable row level security;

drop policy if exists reactions_select_all on public.reactions;
create policy reactions_select_all
  on public.reactions
  for select
  using (true);

drop policy if exists reactions_insert_own on public.reactions;
create policy reactions_insert_own
  on public.reactions
  for insert
  with check (auth.uid() = user_id);

drop policy if exists reactions_update_own on public.reactions;
create policy reactions_update_own
  on public.reactions
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists reactions_delete_own on public.reactions;
create policy reactions_delete_own
  on public.reactions
  for delete
  using (auth.uid() = user_id);

commit;

-- Optional: if you want to fully remove public.users table, do this only after
-- confirming no code, view, trigger, function, or FK still depends on it.
-- drop table if exists public.users;
