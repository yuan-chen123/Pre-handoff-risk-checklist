-- Shared backend for the risk checklist. Run once in the Supabase SQL editor.
-- Tables are locked down (RLS on, no policies): the browser can only call the functions
-- below, and every function requires the shared password.
-- CHANGE 'password' below. It is only a shared secret: anyone who learns it has full access.
create table if not exists projects(
  id uuid primary key default gen_random_uuid(), name text not null,
  state jsonb not null default '{}', updated_by text, updated_at timestamptz not null default now());
create table if not exists comments(
  id uuid primary key default gen_random_uuid(), project_id uuid not null references projects on delete cascade,
  item_key text not null, author text not null, body text not null, created_at timestamptz not null default now());
alter table projects enable row level security;
alter table comments enable row level security;

create or replace function _ok(p text) returns void language plpgsql as $$
begin if p is distinct from 'password' then raise exception 'unauthorized'; end if; end $$;

create or replace function check_pass(p_pass text) returns boolean language plpgsql security definer as $$
begin return p_pass is not distinct from 'password'; end $$;

create or replace function list_projects(p_pass text) returns setof projects language plpgsql security definer as $$
begin perform _ok(p_pass); return query select id,name,'{}'::jsonb,updated_by,updated_at from projects order by updated_at desc; end $$;

create or replace function create_project(p_pass text,p_name text,p_user text) returns uuid language plpgsql security definer as $$
declare v uuid; begin perform _ok(p_pass);
  insert into projects(name,state,updated_by) values(left(p_name,200),jsonb_build_object('meta.Project',left(p_name,200)),left(p_user,100)) returning id into v; return v; end $$;

create or replace function get_project(p_pass text,p_id uuid) returns projects language plpgsql security definer as $$
declare r projects; begin perform _ok(p_pass); select * into r from projects where id=p_id; return r; end $$;

-- Shallow-merges per-field patches; a null value deletes the key. Concurrent edits to different fields never clobber each other.
create or replace function patch_project(p_pass text,p_id uuid,p_patch jsonb,p_user text) returns void language plpgsql security definer as $$
begin perform _ok(p_pass);
  update projects set state=jsonb_strip_nulls(state||p_patch),updated_by=left(p_user,100),updated_at=now() where id=p_id; end $$;

create or replace function list_comments(p_pass text,p_id uuid) returns setof comments language plpgsql security definer as $$
begin perform _ok(p_pass); return query select * from comments where project_id=p_id order by created_at; end $$;

create or replace function add_comment(p_pass text,p_id uuid,p_key text,p_body text,p_user text) returns void language plpgsql security definer as $$
begin perform _ok(p_pass);
  insert into comments(project_id,item_key,author,body) values(p_id,left(p_key,20),left(p_user,100),left(p_body,4000)); end $$;

grant execute on function check_pass,list_projects,create_project,get_project,patch_project,list_comments,add_comment to anon;

create or replace function rename_project(p_pass text,p_id uuid,p_name text,p_user text) returns void language plpgsql security definer as $$
begin perform _ok(p_pass);
  update projects set name=left(p_name,200),state=state||jsonb_build_object('meta.Project',left(p_name,200)),updated_by=left(p_user,100),updated_at=now() where id=p_id; end $$;

create or replace function delete_project(p_pass text,p_id uuid) returns void language plpgsql security definer as $$
begin perform _ok(p_pass); delete from projects where id=p_id; end $$;

create or replace function duplicate_project(p_pass text,p_id uuid,p_name text,p_user text) returns uuid language plpgsql security definer as $$
declare v uuid; begin perform _ok(p_pass);
  insert into projects(name,state,updated_by) select left(p_name,200),state||jsonb_build_object('meta.Project',left(p_name,200)),left(p_user,100) from projects where id=p_id returning id into v;
  return v; end $$;

grant execute on function rename_project,delete_project,duplicate_project to anon;
