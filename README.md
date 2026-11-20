# DHARA Template Studio

An independent product: a library of reviewed Indian legal document templates that any user can browse, fill in (typing or voice, later), preview and download. Built **website first**, with its own backend, database, user accounts and hosting, so it can later be shipped inside the DHARA app or released as a separate product without untangling anything.

> Status: **planning / scaffold**. Nothing user-facing is built yet. See [docs/BUILD_PLAN.md](docs/BUILD_PLAN.md).

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
