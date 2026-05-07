# Superteam Thailand — Unofficial Member Registry

Open-source form. **Code is public. Member data is private.**

Built on [Supabase](https://supabase.com) with Row Level Security — the public anon key is **write-only**. No one can read member data without curator authentication.

---

## Architecture

```
Browser (form)
    │
    │  HTTPS (anon key — write-only)
    ▼
Supabase (PostgreSQL + RLS)
    ├── members table          ← public INSERT only, no SELECT
    └── member_curation table  ← authenticated curators only
```

**The anon key can only insert rows. It cannot read, update, or delete.**  
Curator access requires a Supabase authenticated session (email/password or SSO).

---

## Repository structure

```
superteam-thailand/
├── src/
│   └── index.html              # The form (plain HTML + Supabase JS)
├── supabase/
│   └── migrations/
│       └── 001_initial_schema.sql  # Full DB schema + RLS policies
├── docs/
│   └── DATA_FLOW.md            # Detailed security data flow
├── .env.example                # Required env vars (no real values)
├── .gitignore                  # Blocks .env and data exports
├── PRIVACY.md                  # PDPA-compliant privacy notice
└── README.md
```

---

## Setup

### 1. Create a Supabase project

1. Go to [supabase.com](https://supabase.com) → New project
2. Choose region closest to your users (e.g. `ap-southeast-1` Singapore)
3. Save your database password somewhere secure

### 2. Run the migration

In Supabase Dashboard → **SQL Editor**, paste and run the contents of:

```
supabase/migrations/001_initial_schema.sql
```

This creates:
- `members` table with all form fields
- `member_curation` table (curator-only)
- Row Level Security policies
- Indexes

### 3. Get your keys

Supabase Dashboard → **Settings → API**

| Key | Where to use |
|---|---|
| Project URL | `VITE_SUPABASE_URL` in `.env` |
| `anon` public key | `VITE_SUPABASE_ANON_KEY` in `.env` |
| `service_role` key | **Never in this repo. Dashboard only.** |

### 4. Configure environment

```bash
cp .env.example .env
# Edit .env with your real values
```

### 5. Inject env vars into the HTML

The `src/index.html` uses placeholder tokens `__SUPABASE_URL__` and `__SUPABASE_ANON__`.

**Option A — Vite (recommended):**

```bash
npm create vite@latest . -- --template vanilla
# Move src/index.html to index.html, update the script to:
# const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL
# const SUPABASE_ANON = import.meta.env.VITE_SUPABASE_ANON_KEY
npm run build
```

**Option B — Manual (quick deploy):**

Replace the two placeholder strings in `src/index.html` directly:
```js
// Replace these lines:
const SUPABASE_URL  = typeof __SUPABASE_URL__  !== 'undefined' ? __SUPABASE_URL__  : '';
const SUPABASE_ANON = typeof __SUPABASE_ANON__ !== 'undefined' ? __SUPABASE_ANON__ : '';

// With your actual values:
const SUPABASE_URL  = 'https://your-project-ref.supabase.co';
const SUPABASE_ANON = 'your-anon-key';
```

⚠️ If using Option B, **do not commit this file** after substitution.

### 6. Deploy

```bash
# GitHub Pages, Vercel, Netlify, or any static host
# The form is a single HTML file — no server required
```

---

## Accessing member data (curators only)

Member data is **never exposed via the public form**. To view submissions:

**Option A — Supabase Dashboard**  
Dashboard → Table Editor → `members` (authenticated via your Supabase account)

**Option B — Supabase Studio query**
```sql
select
  m.full_name, m.project_name, m.role, m.city, m.country,
  m.what_building, m.category_primary, m.chain_alignment,
  m.stage, m.intent_score,
  c.tier, c.curator_notes
from members m
left join member_curation c on c.member_id = m.id
order by m.submitted_at desc;
```

**Option C — Export to CSV**  
Dashboard → Table Editor → Export (authenticated only)

---

## Adding curation data (tier + notes)

After reviewing a submission, add curation via SQL Editor:

```sql
insert into member_curation (member_id, tier, curator_notes, intent_score, curated_by)
values (
  'uuid-of-member-here',
  'T1',
  'Ex-Grab engineer, shipping on devnet, 300 waitlist.',
  5,
  'your-name'
);
```

---

## Security model — plain English

| Threat | Mitigation |
|---|---|
| Someone reads all member data via anon key | Blocked by RLS policy: anon `SELECT` returns 0 rows |
| Someone scrapes the form JS to get credentials | Anon key is write-only by design — useless for reading |
| API key committed to git | `.gitignore` blocks `.env`; `.env.example` has no real values |
| Data export leaked in repo | `*.csv`, `*.json`, `data/` all in `.gitignore` |
| Submitter sees other members' data | No GET endpoint exists; success screen shows no data back |
| Service role key exposed | Never used in frontend; Dashboard-only |
| Spam / junk submissions | Add Supabase rate limiting or Cloudflare Turnstile to form |
| PDPA non-compliance | Consent checkbox required; `pdpa_consent = false` blocked by RLS |

---

## PDPA (Thailand) compliance checklist

- [x] Explicit consent checkbox before submission
- [x] Consent timestamp stored (`consent_at`)
- [x] Privacy notice linked from form (`PRIVACY.md`)
- [x] Purpose of collection stated
- [x] Data subject rights documented
- [x] No sensitive personal data collected (PDPA Section 26)
- [ ] Add your contact email to `PRIVACY.md`
- [ ] Add your Supabase region to `PRIVACY.md`
- [ ] Set up deletion workflow (manual SQL or Supabase function)

---

## License

MIT — code is open source. Member data is private and never included in this repository.
