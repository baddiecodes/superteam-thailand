# Privacy Notice — Superteam Thailand Member Registry

**Last updated:** 2026-05-07  
**Governed by:** Thailand Personal Data Protection Act (PDPA) B.E. 2562 (2019)

---

## 1. Who collects your data

Superteam Thailand (unofficial community group). This registry is not operated by or affiliated with Solana Foundation, Superteam HQ, or any registered legal entity. Contact: [add your contact email here]

## 2. What data we collect

| Category | Fields |
|---|---|
| Identity | Full name, project name, role, city, country |
| Contact | Twitter/X URL, LinkedIn URL |
| Build info | What you're building, project category, chain alignment, GitHub/demo URL, why Solana |
| Stage info | Stage, traction signal, funding status |
| Intent | Intent score, value flow position, current need |
| Consent record | PDPA consent flag, timestamp of consent |

**We do not collect:** wallet addresses, private keys, passwords, financial account details, or any sensitive personal data as defined under PDPA Section 26.

## 3. Why we collect it (legal basis)

**Consent (PDPA Section 19)** — collection occurs only after you explicitly check the consent box. You may withdraw consent at any time (see Section 7).

**Purposes:**
- Mapping the Solana/Web3 builder ecosystem in Southeast Asia
- Connecting builders with resources, grants, and collaborators
- Producing anonymised community analytics (e.g. "28% are building DeFi")

## 4. Who can see your data

| Role | Access level |
|---|---|
| Curator (Superteam Thailand team) | Full read/write via authenticated Supabase session |
| General public | None — anon key is write-only by design (RLS enforced) |
| Third parties | Not shared, not sold |

Curation notes and tier assignments (T1/T2/T3) are internal only and never shared with submitters or the public.

## 5. Where data is stored

- **Platform:** [Supabase](https://supabase.com) — PostgreSQL database
- **Region:** [Specify your Supabase project region, e.g. ap-southeast-1 Singapore]
- **Encryption at rest:** Yes (Supabase default)
- **Encryption in transit:** Yes (TLS 1.2+)
- **Row Level Security:** Enabled. Anon users can write only. Reading requires authenticated curator session.

## 6. Retention

Data is retained as long as the registry is active. If you request deletion (Section 7), your record is permanently deleted within 30 days.

## 7. Your rights under PDPA

You have the right to:

- **Access** — request a copy of your data
- **Correction** — request corrections to inaccurate data
- **Deletion** — request permanent deletion of your record
- **Withdrawal of consent** — withdraw consent at any time (does not affect lawfulness of prior processing)
- **Portability** — receive your data in a machine-readable format
- **Objection** — object to processing

To exercise any right, email: **[add your contact email here]**  
We will respond within **30 days**.

## 8. Security measures

- Supabase anon key is **write-only** — it cannot read member data
- Service role key is **never exposed** in frontend code or this repository
- Row Level Security (RLS) is enforced at the database level
- No PII is logged in browser console or analytics
- This repository contains **no real member data** — only code and schema

## 9. Changes to this notice

Material changes will be noted with an updated date at the top. Continued use of the form after changes constitutes acceptance.

---

*This notice was written in good faith for a community project. It is not legal advice. If you have compliance concerns, consult a PDPA-qualified legal professional.*
