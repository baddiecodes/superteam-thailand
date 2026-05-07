# Data Flow & Security Model

## Submission flow

```
1. User fills form in browser
2. User checks PDPA consent box
3. JS calls supabase.from('members').insert([payload])
   using the ANON key over HTTPS
4. Supabase RLS checks:
   a. Is pdpa_consent = true?  → allow insert
   b. Is this a SELECT?        → block (returns 0 rows)
5. Row written to members table
6. No data returned to browser (insert only)
7. Success screen shown
```

## Key security properties

**Anon key is safe to expose in frontend code.**  
It's designed to be public. Access is controlled by RLS at the database level, not by keeping the key secret.

**The service_role key bypasses RLS entirely.**  
Never use it in frontend code. Never commit it. Only use it in Supabase Dashboard or trusted server environments.

**Curation data is in a separate table.**  
`member_curation` holds tier, curator notes, and curator intent score override. It is inaccessible via anon key.

## RLS policies summary

| Table | anon INSERT | anon SELECT | auth SELECT | auth ALL |
|---|---|---|---|---|
| `members` | ✅ (consent required) | ❌ blocked | ✅ | ✅ |
| `member_curation` | ❌ | ❌ | ✅ | ✅ |

## What is safe to commit to GitHub

| File | Safe? | Reason |
|---|---|---|
| `src/index.html` | ✅ (with placeholders) | No real keys |
| `supabase/migrations/*.sql` | ✅ | Schema only, no data |
| `.env.example` | ✅ | No real values |
| `README.md`, `PRIVACY.md` | ✅ | Documentation |
| `.env` | ❌ NEVER | Contains real keys |
| Any CSV/JSON export | ❌ NEVER | Contains member PII |
| `index.html` after manual key substitution | ❌ NEVER | Contains real anon key |

## Deletion request workflow

When a member requests deletion under PDPA:

```sql
-- Verify identity first, then:
delete from members where full_name = 'Name' and submitted_at = 'timestamp';
-- Cascade delete also removes member_curation row automatically
```
