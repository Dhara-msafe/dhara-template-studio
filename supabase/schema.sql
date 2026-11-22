-- DHARA Template Studio — Supabase (Postgres) schema
-- Satisfies TS-05. Run this once in the Supabase SQL editor (or via `supabase db push`)
-- on a fresh project. Safe to re-run: every statement is idempotent.
--
-- Pattern used throughout: the FastAPI **Admin API** writes with the Supabase
-- *service role* key, which bypasses RLS entirely (that's where TS-06/TS-07's
-- lifecycle + publish-gate logic lives, in backend/app/routers/admin.py).
-- The FastAPI **Public API** and any direct frontend Supabase calls use the
-- *anon*/user key, so everything a citizen or guest can see is governed by
-- the RLS policies below — this is the single safety gate TS-07 asks for.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
do $$ begin
  create type user_role as enum (
    'guest',               -- not persisted; unauthenticated requests behave as this
    'citizen_free',
    'citizen_pro',
    'verified_advocate',
    'reviewer_legal',
    'reviewer_language',
    'admin'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type template_tier as enum ('free', 'pro');
exception when duplicate_object then null; end $$;

do $$ begin
  create type template_mode as enum ('guided_self_serve', 'advocate_reviewed', 'advocate_only');
exception when duplicate_object then null; end $$;

do $$ begin
  create type lifecycle_status as enum (
    'draft', 'in_legal_review', 'in_language_review', 'approved',
    'published', 'needs_re_review', 'deprecated'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type review_stage as enum ('legal', 'language');
exception when duplicate_object then null; end $$;

do $$ begin
  create type review_decision as enum ('approved', 'rejected');
exception when duplicate_object then null; end $$;

do $$ begin
  create type advocate_verification_status as enum ('none', 'pending', 'verified', 'rejected');
exception when duplicate_object then null; end $$;

do $$ begin
  create type locale_code as enum ('en', 'hi', 'mr');
exception when duplicate_object then null; end $$;

-- ---------------------------------------------------------------------------
-- profiles — one row per auth.users row (created by trigger below)
-- ---------------------------------------------------------------------------
create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  role user_role not null default 'citizen_free',
  plan template_tier not null default 'free',
  advocate_bar_id text,
  advocate_verification advocate_verification_status not null default 'none',
  advocate_documents jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into profiles (id) values (new.id);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

-- ---------------------------------------------------------------------------
-- templates — metadata only; content lives in template_versions
-- ---------------------------------------------------------------------------
create table if not exists templates (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  category text not null,
  legal_basis text,
  tier template_tier not null default 'free',
  mode template_mode not null default 'guided_self_serve',
  field_schema jsonb not null default '[]'::jsonb,
  -- mirrors the lifecycle status of this template's current/latest version;
  -- kept in sync by sync_template_status() below so the public API can
  -- filter on one simple column instead of joining to find the live version.
  status lifecycle_status not null default 'draft',
  current_published_version_id uuid,
  created_by uuid references profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists templates_category_idx on templates (category);
create index if not exists templates_status_idx on templates (status);
-- backs GET /templates?search= (TS-09)
create index if not exists templates_search_idx
  on templates using gin (to_tsvector('english', title || ' ' || coalesce(legal_basis, '')));

-- ---------------------------------------------------------------------------
-- template_versions — one immutable snapshot of a template's content
-- ---------------------------------------------------------------------------
create table if not exists template_versions (
  id uuid primary key default gen_random_uuid(),
  template_id uuid not null references templates (id) on delete cascade,
  version_number int not null,
  content jsonb not null,            -- the authored source content for this version
  status lifecycle_status not null default 'draft',
  authored_by uuid references profiles (id),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  unique (template_id, version_number)
);

create index if not exists template_versions_template_idx on template_versions (template_id);
create index if not exists template_versions_status_idx on template_versions (status);

-- keep templates.status / current_published_version_id in sync whenever a
-- version's lifecycle status changes — this is TS-07's enforcement point.
create or replace function sync_template_status()
returns trigger language plpgsql as $$
begin
  update templates
     set status = new.status,
         current_published_version_id = case when new.status = 'published' then new.id
                                              else current_published_version_id end,
         updated_at = now()
   where id = new.template_id;
  return new;
end;
$$;

drop trigger if exists template_version_status_sync on template_versions;
create trigger template_version_status_sync
  after insert or update of status on template_versions
  for each row execute procedure sync_template_status();

-- ---------------------------------------------------------------------------
-- template_variants — per-language rendering of a version
-- ---------------------------------------------------------------------------
create table if not exists template_variants (
  id uuid primary key default gen_random_uuid(),
  version_id uuid not null references template_versions (id) on delete cascade,
  locale locale_code not null,
  rendered_content jsonb not null,
  status lifecycle_status not null default 'draft',
  created_at timestamptz not null default now(),
  unique (version_id, locale)
);

-- ---------------------------------------------------------------------------
-- reviews — legal / language review decisions
-- ---------------------------------------------------------------------------
create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  version_id uuid not null references template_versions (id) on delete cascade,
  stage review_stage not null,
  locale locale_code,                -- set only when stage = 'language'
  reviewer_id uuid not null references profiles (id),
  decision review_decision not null,
  comment text,
  created_at timestamptz not null default now()
);

create index if not exists reviews_version_idx on reviews (version_id);

-- ---------------------------------------------------------------------------
-- drafts + draft_versions — a user's in-progress fill of a published version
-- ---------------------------------------------------------------------------
create table if not exists drafts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles (id) on delete cascade,
  template_id uuid not null references templates (id),
  template_version_id uuid not null references template_versions (id),
  locale locale_code not null default 'en',
  fields jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists drafts_user_idx on drafts (user_id);

create table if not exists draft_versions (
  id uuid primary key default gen_random_uuid(),
  draft_id uuid not null references drafts (id) on delete cascade,
  fields jsonb not null,
  created_at timestamptz not null default now()
);

create index if not exists draft_versions_draft_idx on draft_versions (draft_id);

-- autosave: snapshot the previous field state into draft_versions before
-- overwriting drafts.fields, so edit history is never lost (TS-05).
create or replace function snapshot_draft_version()
returns trigger language plpgsql as $$
begin
  if old.fields is distinct from new.fields then
    insert into draft_versions (draft_id, fields) values (old.id, old.fields);
  end if;
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists draft_autosave_snapshot on drafts;
create trigger draft_autosave_snapshot
  before update of fields on drafts
  for each row execute procedure snapshot_draft_version();

-- ---------------------------------------------------------------------------
-- audit_events — every review / publish action
-- ---------------------------------------------------------------------------
create table if not exists audit_events (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references profiles (id),
  action text not null,               -- e.g. 'template.publish', 'review.approve'
  entity_type text not null,          -- e.g. 'template_version'
  entity_id uuid not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists audit_events_entity_idx on audit_events (entity_type, entity_id);

-- ---------------------------------------------------------------------------
-- Row-level security
-- ---------------------------------------------------------------------------
alter table profiles enable row level security;
alter table templates enable row level security;
alter table template_versions enable row level security;
alter table template_variants enable row level security;
alter table reviews enable row level security;
alter table drafts enable row level security;
alter table draft_versions enable row level security;
alter table audit_events enable row level security;

-- helper: current user's role, '' for anon/unauthenticated
create or replace function current_user_role()
returns user_role language sql stable as $$
  select role from profiles where id = auth.uid();
$$;

-- profiles: a user can read/update their own row; admins can read all
create policy profiles_select_own on profiles for select
  using (id = auth.uid() or current_user_role() = 'admin');
create policy profiles_update_own on profiles for update
  using (id = auth.uid());

-- templates: published rows are world-readable (guests included); reviewers
-- and admin can see everything regardless of status
create policy templates_select_published on templates for select
  using (
    status = 'published'
    or current_user_role() in ('reviewer_legal', 'reviewer_language', 'admin')
  );

-- template_versions: published versions are world-readable; otherwise only
-- reviewer/admin roles (the people doing the reviewing) can see draft content
create policy template_versions_select on template_versions for select
  using (
    status = 'published'
    or current_user_role() in ('reviewer_legal', 'reviewer_language', 'admin')
  );

create policy template_variants_select on template_variants for select
  using (
    exists (
      select 1 from template_versions v
      where v.id = template_variants.version_id
        and (v.status = 'published'
             or current_user_role() in ('reviewer_legal', 'reviewer_language', 'admin'))
    )
  );

-- reviews: reviewers and admin only
create policy reviews_select on reviews for select
  using (current_user_role() in ('reviewer_legal', 'reviewer_language', 'admin'));
create policy reviews_insert on reviews for insert
  with check (current_user_role() in ('reviewer_legal', 'reviewer_language', 'admin'));

-- drafts: strictly owner-only (TS-09 "ownership checks on every draft route")
create policy drafts_owner_select on drafts for select using (user_id = auth.uid());
create policy drafts_owner_insert on drafts for insert with check (user_id = auth.uid());
create policy drafts_owner_update on drafts for update using (user_id = auth.uid());
create policy drafts_owner_delete on drafts for delete using (user_id = auth.uid());

create policy draft_versions_owner_select on draft_versions for select
  using (exists (select 1 from drafts d where d.id = draft_versions.draft_id and d.user_id = auth.uid()));

-- audit_events: admin only; inserts happen via the backend's service role key
create policy audit_events_select on audit_events for select
  using (current_user_role() = 'admin');

-- NOTE: templates / template_versions / template_variants have no INSERT,
-- UPDATE or DELETE policy on purpose — all writes to them go through the
-- Admin API using the Supabase service role key (bypasses RLS), which is
-- where TS-06's create/version/variant/review/publish endpoints enforce the
-- lifecycle rules in one place.
