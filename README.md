# DHARA Template Studio

An independent product: a library of reviewed Indian legal document templates that any user can browse, fill in (typing or voice, later), preview and download. Built **website first**, with its own backend, database, user accounts and hosting, so it can later be shipped inside the DHARA app or released as a separate product without untangling anything.

> Status: **MVP scaffold built, not yet deployed**. Database schema, FastAPI backend and Next.js frontend exist and are verified working locally (see Running it below); no real template content, counsel opinion, or pilot users yet. See [docs/BUILD_PLAN.md](docs/BUILD_PLAN.md) and [docs/ADR-001-stack.md](docs/ADR-001-stack.md).

## Running it locally

1. **Database** — create a free project at [supabase.com](https://supabase.com), then in its SQL editor run `supabase/schema.sql` followed by `supabase/seed.sql` (4 seed templates, TS-08). Copy `backend/.env.example` → `backend/.env` and `frontend/.env.example` → `frontend/.env.local`, filling in your project's URL/keys from Project Settings → API.
2. **Backend** —
   ```
   cd backend
   python -m venv .venv && source .venv/bin/activate
   pip install -r requirements.txt
   uvicorn app.main:app --reload
   ```
   Runs at `http://localhost:8000`; interactive API docs at `/docs`.
3. **Frontend** —
   ```
   cd frontend
   npm install
   npm run dev
   ```
   Runs at `http://localhost:3000`.
4. To act as a reviewer or admin, set a `profiles.role` row directly in the Supabase table editor after signing up once through the app (defaults to `citizen_free`).

What's not wired up yet: real template content (seed data is placeholder text pending TS-11), a payment gateway (Pricing page calls a stub until TS's Open Questions on the gateway are settled), and HI/MR language variants.

## Links (keep these in sync)

| What | Where |
|---|---|
| Feature hub (status, decisions, all PRs) | Issue #1 in this repo: **Feature hub: template-studio** |
| Research and planning pack (GitLaw assessment, 70-template catalogue, Emmy brief) | Google Drive *DHARA → Advocate features*: https://drive.google.com/drive/folders/1QhbltUke25SnlAzVv3XwRdiTrOyRocjU |
| Design chat (analysis so far) | https://claude.ai/share/05e47d4d-a01b-4b0c-ae8a-778c2b27aa81 |
| Launch tracker (items TS-01 … TS-12) | https://claude.ai/artifact/GcPo3KLjNbdiQkcMkZ7r9y (read-only copy in Drive 00_Shared_Kit_and_Daily_Reports) |

## Independence rules

- Own repo (this one), own database, own sign-up/login, own domain. No DHARA user data.
- Legal citations: call DHARA's legal-lookup API as a **read-only client** when needed; never copy the DHARA corpus here.
- Nothing is visible to users unless its status is **published** (after legal review and language review by named reviewers).

## How we work

See [CONTRIBUTING.md](CONTRIBUTING.md). In short: short task branches → PR into `develop` → squash-merge → delete branch. `main` only receives tested releases.
