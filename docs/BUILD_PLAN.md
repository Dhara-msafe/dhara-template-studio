# Build plan (tracker items TS-01 … TS-12)

Order matters: decisions first, then the engine, then content. Source: DHARA GitLaw Assessment and Workspace Plan (Drive) and the design chat.

| ID | Item | Done when | Owner |
|---|---|---|---|
| TS-01 | Decide pilot scope: first ~11 templates, 3 languages (EN/HI/MR), citizen-only first | Written decision in the feature hub | Owner |
| TS-02 | Tier every template: guided self-serve / advocate-reviewed / advocate-only | CSV tier column signed off | Owner + counsel |
| TS-03 | Counsel opinion on unauthorised-practice risk (Advocates Act ss. 29, 33, 45) | Written opinion stored in Drive | Owner |
| TS-04 | Tech stack + hosting + auth choice (independent accounts) | ADR in `docs/` | Developer |
| TS-05 | Data models: templates, template_versions (immutable), template_variants (per language), reviews, drafts, draft_versions, audit_events | Models + tests merged | Developer |
| TS-06 | Admin API: create template, add version, add language variant, record review, publish | Endpoints + tests merged | Developer |
| TS-07 | Publish gate: only `published` reaches the public API | Test proves drafts/unreviewed are invisible | Developer |
| TS-08 | Migrate DHARA's 4 existing drafts (cheque bounce, deposit refund, unpaid salary, police complaint) as seed templates | 4 templates render from the engine | Developer |
| TS-09 | Public API: browse/filter published, start draft, save (versioned), export PDF/DOCX; ownership checks on every draft route | Endpoints + tests merged | Developer |
| TS-10 | Website: browse → fill → preview → download, Free vs Pro labels, advocate-only gating | Pages working end to end on staging | Developer |
| TS-11 | Content: write + legally review + language review the pilot templates | All pilot templates `published` | Owner + reviewers |
| TS-12 | Pilot test with 50–100 users + a few advocates | Test report in Drive, go/no-go | Owner |

Separate DHARA issue to raise (not this repo): DHARA's corpus shows "last checked 15 January 2026" while the app says "checked against current law".
