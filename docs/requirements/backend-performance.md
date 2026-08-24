# Backend Performance & Audits

**Scope:** All server code, database queries, background jobs, and data
lifecycle logic across projects in this workspace.
**Items:** PERF-069 … PERF-076 (8 requirements).
**Legend:** `[AUTO]` script-checked · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human/monitoring action.

---

## Query & Connection Hygiene

| ID | Requirement | Verification |
|---|---|---|
| PERF-069 | Backend queries fetch only what the UI/API response needs: no `SELECT *` into large tables when a projection suffices, no loading entire result sets to count/filter in app code, responses trimmed of unused heavy fields. Over-fetching found in audit is fixed or justified. | `[AGENT]` audit table: endpoint → query → fields used vs fetched; fix citations |
| PERF-070 | N+1 query patterns eliminated (or batched): loops issuing per-item queries replaced with joins/eager-loading/batch APIs (`IN`, dataloader-style). ORM relation-loading configured deliberately; per-request query counts sanity-checked on hot paths. | `[AGENT]` enable query logging on staging, walk key pages, paste counts before/after |
| PERF-071 | Database indexes exist for frequent search/filter/join/sort columns: FK columns, columns in common WHERE clauses, pagination cursors. Index additions verified with EXPLAIN/query-plan evidence; unused/duplicate indexes pruned. | `[MANUAL]`/`[AGENT]` EXPLAIN outputs recorded for top queries; index DDL cited |
| PERF-072 | DB connections closed properly: every acquire has a guaranteed release (try/finally, context managers), pool sizes bounded and matched to host concurrency, no connection leaks under error paths. Pool exhaustion alerts configured. | `[AGENT]` load/stress spot-check showing stable connection count; cite release pattern per DB client module |

## Storage Lifecycle

| ID | Requirement | Verification |
|---|---|---|
| PERF-073 | Object storage audited: no orphaned blobs (uploads whose owning record was deleted but object remained). Lifecycle rules / cleanup jobs remove unreferenced objects after grace period; storage growth monitored. | `[MANUAL]` quarterly orphan scan run + cleanup job config recorded; `[AGENT]` verify delete flows remove both row + object |
| PERF-074 | No hidden long-lived background jobs holding DB connections open: cron/serverless/queue workers use short-lived or properly pooled connections; idle-in-transaction timeouts set; worker logs reviewed for stuck transactions. | `[MANUAL]` `pg_stat_activity` (or equivalent) review during peak; `[AGENT]` inventory all background jobs → connection strategy each |

## Deletion Mechanics (pairs with LEG-080…LEG-086)

Account deletion is a **data-lifecycle transaction**, not a credentials wipe.
PERF-075 and PERF-076 exist so that "right to be forgotten" (LEG-080) cannot
be satisfied by deleting only the auth row while user content survives.

| ID | Requirement | Verification |
|---|---|---|
| PERF-075 | Cascading deletions: account deletion permanently wipes ALL associated user artifacts — relational rows across every table referencing the user (profiles, posts, comments, settings, tokens, sessions), uploaded files/images/blobs in object storage, generated exports/caches, search indexes, and push/notification subscriptions. Implemented as explicit cascade lists or DB-level `ON DELETE CASCADE` + storage cleanup job; a deletion dry-run on a seeded test account enumerates every store touched and proves zero orphans afterwards. | `[AGENT]` execute deletion on seeded test account → enumerate all tables/buckets/indexes before+after, paste orphan-check results |
| PERF-076 | Third-party data purge: account deletion triggers automated deletion/anonymization requests to every external processor holding that user's data — payment gateways (Stripe customer deletion), email/marketing lists (ESP contact delete), analytics identifiers (GA4 user deletion API), AI providers' stored logs/chat history (where retention applies), error trackers (Sentry user identity scrub), CDN caches where feasible. Each integration has documented API call + failure retry path + completion log entry. | `[AGENT]` trigger test-account deletion → show processor-side confirmations/API responses logged; list each integration with its call site |

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | Initial import: 6 performance items with stable IDs and verification methods. |
| 2026-08-24 | v2: Added PERF-075 (cascading deletions) and PERF-076 (third-party data purge) from the 142-point master list; grouped into sections. |
