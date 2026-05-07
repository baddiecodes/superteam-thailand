-- ============================================================
-- Superteam Thailand Member Registry
-- Migration: 001_initial_schema
-- ============================================================

-- Enable UUID extension
create extension if not exists "pgcrypto";

-- ============================================================
-- ENUM TYPES
-- ============================================================

create type member_role as enum (
  'Founder', 'Co-founder', 'Developer', 'Creator', 'Partner', 'Investor'
);

create type chain_alignment as enum (
  'Solana Native', 'Multi-chain', 'Chain-agnostic', 'Exploring Solana'
);

create type project_stage as enum (
  'Idea', 'MVP', 'Early traction', 'Scaling'
);

create type funding_status as enum (
  'Bootstrapped', 'Raised', 'Raising', 'Pre-funding'
);

create type value_flow_position as enum (
  'Create', 'Distribute', 'Capture'
);

create type current_need as enum (
  'Capital', 'Users', 'Hiring', 'Tech support', 'BD'
);

create type member_tier as enum (
  'T1', 'T2', 'T3'
);

create type category_option as enum (
  -- Infrastructure
  'Core infrastructure', 'Developer tooling', 'RPC / node services',
  'Oracles', 'Indexing / data', 'Security / auditing',
  -- DeFi
  'DEX / AMM', 'Lending / borrowing', 'Derivatives / perps',
  'Yield / vaults', 'Stablecoins', 'Payments / remittance', 'Cross-chain / bridges',
  -- Consumer
  'NFTs / digital collectibles', 'Gaming / GameFi', 'Social / SocialFi',
  'Creator economy', 'Identity / reputation', 'Wallets / UX',
  -- Emerging
  'AI agents', 'DePIN', 'DeSci', 'RWA tokenization', 'DAOs / governance', 'Prediction markets',
  -- Other
  'Analytics / research', 'Education / community', 'Media / content', 'Enterprise / B2B', 'Other'
);

-- ============================================================
-- MEMBERS TABLE (identity + build + stage + intent)
-- ============================================================

create table members (
  -- Primary key
  id                  uuid primary key default gen_random_uuid(),

  -- Identity layer
  full_name           text not null,
  project_name        text,
  role                member_role not null,
  city                text not null,
  country             text not null,
  twitter_or_x        text,
  linkedin            text,

  -- Build layer
  what_building       text not null,
  category_primary    category_option not null,
  category_secondary  category_option,
  chain_alignment     chain_alignment not null,
  why_solana          text,
  github_or_demo      text,

  -- Stage layer
  stage               project_stage not null,
  traction_signal     text,
  funding_status      funding_status not null,

  -- Intent + value layer
  intent_score        smallint not null check (intent_score >= 1 and intent_score <= 5),
  value_flow_position value_flow_position not null,
  current_need        current_need,

  -- Consent (PDPA Thailand)
  pdpa_consent        boolean not null default false,
  consent_at          timestamptz,

  -- Timestamps
  submitted_at        timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- ============================================================
-- CURATION TABLE (curator-only, separate from member data)
-- ============================================================

create table member_curation (
  id              uuid primary key default gen_random_uuid(),
  member_id       uuid not null references members(id) on delete cascade,

  -- Curation layer (not visible to submitters)
  tier            member_tier,
  curator_notes   text,
  intent_score    smallint check (intent_score >= 1 and intent_score <= 5),

  -- Audit
  curated_by      text,
  curated_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger members_updated_at
  before update on members
  for each row execute function set_updated_at();

create trigger curation_updated_at
  before update on member_curation
  for each row execute function set_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table members enable row level security;
alter table member_curation enable row level security;

-- PUBLIC: can INSERT only (submit form) — cannot read other members
create policy "public_insert_members"
  on members for insert
  to anon
  with check (pdpa_consent = true);

-- AUTHENTICATED (curators): full access to members
create policy "curator_all_members"
  on members for all
  to authenticated
  using (true)
  with check (true);

-- AUTHENTICATED (curators): full access to curation table
create policy "curator_all_curation"
  on member_curation for all
  to authenticated
  using (true)
  with check (true);

-- BLOCK anon from reading members entirely
create policy "block_anon_select_members"
  on members for select
  to anon
  using (false);

-- BLOCK anon from curation table entirely
create policy "block_anon_curation"
  on member_curation for all
  to anon
  using (false);

-- ============================================================
-- INDEXES
-- ============================================================

create index idx_members_submitted_at on members (submitted_at desc);
create index idx_members_country on members (country);
create index idx_members_chain_alignment on members (chain_alignment);
create index idx_members_stage on members (stage);
create index idx_members_category_primary on members (category_primary);
create index idx_curation_member_id on member_curation (member_id);
create index idx_curation_tier on member_curation (tier);

-- ============================================================
-- COMMENTS (documentation in DB)
-- ============================================================

comment on table members is 'Superteam Thailand unofficial member registry. Public write-only via anon key. Read requires curator auth.';
comment on table member_curation is 'Curator-only layer. Tier and notes assigned post-submission. Never exposed to submitters.';
comment on column members.pdpa_consent is 'PDPA Thailand compliance. Submission blocked if false.';
comment on column members.intent_score is '1=tourist 3=exploring 5=shipping. Set by submitter; curator may override in member_curation.';
