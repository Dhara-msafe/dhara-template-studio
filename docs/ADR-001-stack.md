# ADR-001: Backend stack — FastAPI + Supabase (Postgres) + Next.js

**Status:** Accepted — 2026-11-22
**Satisfies:** TS-04

## Decision

- **Database + auth + storage:** [Supabase](https://supabase.com) (managed Postgres, built-in auth, row-level security, file storage, auto-generated REST/Realtime).
- **Backend API:** FastAPI (Python), talking to Supabase via `supabase-py` and/or direct Postgres (`asyncpg`/SQLAlchemy) for anything RLS can't express cleanly.
- **Frontend:** Next.js (App Router), calling the FastAPI backend.

## Why Supabase over the alternatives considered

| | Supabase | MongoDB Atlas (M0 free) | Firebase (Spark free) |
|---|---|---|---|
| Free DB | ✅ 500MB Postgres | ✅ 512MB | ✅ (Firestore) |
| Free auth included | ✅ built-in, 50k MAU | ❌ separate product/cost | ✅ |
| Free file storage | ✅ 1GB | ❌ no free tier | ❌ Cloud Storage now requires paid Blaze plan (since Feb 2026) |
| Needs a credit card for free tier | ❌ no | ❌ no | ✅ Blaze required for storage |
| Row-level security | ✅ native Postgres RLS | application-level only | security rules (different model) |
| Fit for our data | Relational — templates/versions/variants/reviews/drafts have real foreign keys | Document store; relations are a worse fit here | Document store; same issue |
| Open-source / self-hostable later | ✅ | partially | ❌ |

Template Studio needs: relational integrity between templates → versions → variants → reviews → drafts, row-level security to enforce the role/tier gates in one place (not re-implemented in every endpoint), and free file storage for advocate-verification document uploads. Supabase is the only option of the three that covers all of this without a paid plan or a credit card up front. Projects pause after 7 days fully idle on the free tier (a non-issue once the pilot has real traffic, and a one-click un-pause otherwise).

Template Studio's own Postgres database is **independent of DHARA's data** — this backend only ever calls DHARA's legal-lookup API as a read-only HTTP client for citations, never shares a database with it.

## Consequences

- RLS policies in `supabase/schema.sql` are the single source of truth for who can read/write what — the FastAPI layer should not re-implement access logic that RLS already guarantees, only add checks RLS can't express (e.g. "is this draft bound to a still-published template version").
- Local dev requires a free Supabase project (`project_ref` in `.env`) — see `backend/.env.example` and `frontend/.env.example`.
