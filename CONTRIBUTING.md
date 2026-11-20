# How to contribute

## Branches
- `main` – released code only. Changed only by a release PR from `develop`, approved by the owner.
- `develop` – integration branch. All work lands here first.
- Task branches, one per change, short-lived (1–3 days):
  - `feat/<area>/<task>` – e.g. `feat/backend/template-models`, `feat/web/browse-page`
  - `fix/<area>/<ID>-<task>` – e.g. `fix/backend/TS-05-publish-gate`
  - Areas: `backend`, `web`, `content`, `infra`, `docs`.

## Pull requests
1. Branch from the latest `develop`.
2. Open a PR into `develop` (never into `main`). Fill in the PR template, including the tracker ID (`TS-##`) and `Feature: #<hub issue>`.
3. Tests pass; no secrets, keys, passwords or real user data in any file (including test reports and fixtures).
4. Squash-merge after review, then delete the branch.

## Daily updates
- Tracker items are `TS-01`, `TS-02`, … in the DHARA Launch Tracker.
- Evidence (screenshots, test logs) goes in the Drive folder *DHARA → Advocate features → Template Studio*, named `<ID>_<test>_<commit>_<date>`.
- Status changes go in your `updates_<name>` sheet. Claude syncs Drive, this repo and the tracker at 09:15 and 19:40 IST.

## Never
- Push to `main` directly, force-push, or merge without a PR.
- Publish a template that has not been legally and linguistically reviewed by a named person.
- Store API keys or credentials in the repo; use environment variables / the host's secret store.
