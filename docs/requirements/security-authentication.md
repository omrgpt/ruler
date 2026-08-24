# Security, Authentication & Infrastructure Requirements

**Scope:** All server, client, database, infrastructure, payment, pipeline,
and AI code in every project in this workspace.
**Items:** SEC-001 … SEC-075 (75 requirements).
**Legend:** `[AUTO]` script-checked · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human/cloud-console action. See [README](./README.md).

---

## 1. Secrets & Key Management

| ID | Requirement | Verification |
|---|---|---|
| SEC-001 | Database credentials must never appear in source code, client bundles, config committed to git, or logs. They exist only in server-side environment variables or a secrets manager. | `[AUTO]` audit scan for credential literals; `[AGENT]` cite env var name only |
| SEC-002 | `.env*` files are gitignored before the first commit and never tracked — including under other names (`config.local.js`, `settings.json` with real values). Env var *names* may be documented via `.env.example` with empty values. | `[AUTO]` `git ls-files` check for `.env*`; `[MANUAL]` confirm `.env.example` has no real values |
| SEC-003 | API keys and third-party secrets (Stripe, OpenAI, SendGrid, etc.) live exclusively in server-side environment variables — prefer short-lived, scoped credentials over static keys where the provider supports them. No key material hardcoded anywhere in the repo or shared via client-fetchable files. | `[AUTO]` secret-pattern scan (sk_live_, AKIA…, ghp_, PEM blocks); `[AGENT]` review of fetch paths |
| SEC-015 | Git history must be free of secrets — not just the current tree. If a secret ever lands in history: rotate it immediately, then purge (git-filter-repo / BFG). Rotation always precedes history rewriting. | `[MANUAL]` periodic `git log -p` / secret-scanner review after any leak incident |
| SEC-016 | Front-end JS bundles contain no secrets. Anything imported into client code is public by definition; only anon/public keys designed for browser use may ship there. | `[AUTO]` bundle grep for secret patterns; `[AGENT]` verify only `NEXT_PUBLIC_`/VITE-style public vars used client-side |
| SEC-030 | JWT signing secrets are long random values from env vars, rotated on schedule and immediately on suspicion; tokens carry short expiry + audience/issuer claims. Never a default like `secret`, `jwt_secret`, or the app name. | `[AUTO]` weak-secret-pattern scan; `[AGENT]` cite where secret is loaded from env |
| SEC-035 | Default credentials are removed everywhere before deploy: DB users, admin panels, routers, sample apps, `.htaccess` basics. No `admin/admin`, no vendor defaults. | `[AUTO]` default-credential-pattern scan; `[MANUAL]` console spot-check at launch |
| SEC-062 | Every paid service (hosting, AI APIs, email, storage) has a hard spend cap and a billing alert configured so a bug or abuse cannot drain the account silently. | `[MANUAL]` billing console screenshot per service recorded in checklist evidence |
| SEC-063 | 2FA is enabled on all infrastructure accounts: hosting, cloud consoles, DB dashboards, domain registrar, DNS, GitHub/org admin, email root. Prefer hardware key or TOTP over SMS. | `[MANUAL]` account-by-account confirmation logged in checklist |

---

## 2. Authentication & Sessions

| ID | Requirement | Verification |
|---|---|---|
| SEC-004 | Authentication is enforced **on the server** for every protected route/resource. Hiding UI elements is never access control; an unauthenticated API call must fail with 401 regardless of what the frontend shows. | `[AGENT]` attempt unauthenticated curl to each protected endpoint, paste result as evidence |
| SEC-026 | Password reset uses single-use, short-TTL (≤15 min) tokens tied to the requesting account, invalidated on use and on password change; responses never reveal whether an email exists (no user enumeration). Reset links are HTTPS-only. | `[AGENT]` test flow: reuse token, expired token, unknown-email response parity |
| SEC-064 | User-facing MFA offered and encouraged (not just infra 2FA): TOTP authenticator support at minimum, enforced for admin/privileged roles, encouraged via nudge for all users; backup codes provided; MFA enrollment and challenge flows rate-limited. | `[AGENT]` enroll test account in TOTP → login challenge demonstrated; recovery path tested |
| SEC-065 | Account enumeration prevented across ALL identity flows: login ("invalid email or password" for both cases), signup (neutral "check your email" flow), and reset (identical response + timing regardless of account existence). Response timing normalized where timing differences leak account existence. Pairs with SEC-026. | `[AGENT]` compare responses+timing for existing vs nonexistent accounts on login/signup/reset |
| SEC-027 | Sessions expire (idle + absolute timeout), rotate IDs on login/privilege change, and are destroyed server-side on logout. Session fixation is impossible because IDs never persist across auth state changes. | `[AGENT]` demonstrate logout invalidation + rotation behavior |
| SEC-028 | Session tokens are stored in `Secure`, `HttpOnly`, `SameSite=Lax/Strict` cookies. localStorage/sessionStorage is forbidden for tokens (XSS-readable). | `[AUTO]` audit scan for token-in-localStorage patterns; `[AGENT]` inspect Set-Cookie flags |
| SEC-029 | Passwords are hashed with bcrypt (cost ≥12) or argon2id. No MD5/SHA1/plain. Rehash-on-login upgrades legacy hashes automatically. | `[AGENT]` cite hashing call site; `[AUTO]` reject `md5(`/`sha1(` near password fields |
| SEC-061 | OAuth flows validate `state` (CSRF), redirect URIs against an exact allowlist (no wildcards), exchange codes server-side only, and store refresh tokens encrypted. Client secrets never reach the browser/mobile bundle. | `[AGENT]` walk the OAuth callback path and show validation points |

---

## 3. Authorization & Access Control

| ID | Requirement | Verification |
|---|---|---|
| SEC-005 | Every endpoint re-checks authorization server-side (role/permission), every request. Frontend role-hiding is cosmetic only. Deny by default. | `[AGENT]` call admin/privileged endpoints as normal user → expect 403, paste output |
| SEC-006 | Users can only read/write their own records. Every query scoped by ownership (`WHERE user_id = :current_user`) or enforced via RLS — never trust a user-supplied ID alone. | `[AGENT]` IDOR test: user A requests user B's resource IDs → expect 404/403 |
| SEC-038 | IDOR/BOLA: enumerate object references in all APIs (including nested/relationship fields, export/report endpoints); access checks apply to every object touched, not just the top-level resource. | `[AGENT]` sweep endpoint list; mark each with its authorization check location |
| SEC-056 | Multi-tenant data isolation is absolute: tenant scoping enforced in queries AND/OR Postgres RLS policies; cross-tenant leakage tests run before every release that touches shared tables. | `[AUTO]` RLS presence check where applicable; `[AGENT]` cross-tenant probe test |

---

## 4. Database Security

| ID | Requirement | Verification |
|---|---|---|
| SEC-007 | DB permission rules reviewed and locked down: no publicly writable tables, no world-readable sensitive tables, grants limited to explicit needs. For Supabase/Firebase-style backends, security rules deny by default. | `[AGENT]` dump effective grants/rules into checklist evidence; `[MANUAL]` console review |
| SEC-008 | Row-Level Security enabled on every table containing user or business data, with policies tested for allow/deny both ways. Tables without RLS need a written exception in this file's changelog explaining why they're safe. | `[AUTO]` SQL/CLI check: list tables missing RLS → FAIL if any unexempted |
| SEC-047 | App connects to DB with least-privilege roles: separate roles for app/runtime vs migrations vs admin. No app runtime connection uses superuser/owner. Service keys never used from clients. | `[AGENT]` cite connection strings' roles (names only); `[AUTO]` service-key-in-client scan |
| SEC-055 | Sensitive columns (PII, tokens, payment-adjacent data) encrypted at rest — disk/volume encryption on the managed DB plus application-level encryption for crown-jewel fields when feasible. Keys managed outside the DB. | `[MANUAL]` provider setting confirmation; `[AGENT]` identify encrypted columns |

---

## 5. API & Input Validation

| ID | Requirement | Verification |
|---|---|---|
| SEC-017 | Security decisions are never made client-side. Assume every request is crafted with curl: revalidate price, quantity, plan tier, file content, and permissions server-side on every call. | `[AGENT]` bypass demo: replay modified request → server rejects, paste output |
| SEC-018 | All user input validated server-side against schemas: type, length, range, format, size caps; **unexpected/unknown fields rejected**, not silently passed through. Oversized/malformed input rejected with 4xx, never processed. Schema validation (zod/joi/equivalent) at every entry point. | `[AGENT]` fuzz representative endpoints with oversized/wrong-type/extra-field payloads |
| SEC-019 | SQL access uses parameterized queries or a query builder/ORM exclusively. String-concatenated SQL is forbidden even in "safe" admin scripts. Dynamic ORDER BY/table names go through strict allowlists. | `[AUTO]` scan for concatenation patterns near SQL keywords |
| SEC-020 | NoSQL injection blocked: Mongo filters built from validated whitelisted fields, `$where`/raw JS execution disabled, operator injection (`$gt:` etc.) neutralized by schema casting. | `[AGENT]` send operator-payload to query endpoints → expect sanitized/rejected |
| SEC-039 | Every API route validates its inputs independently — including internal/service APIs, webhooks, and anything reachable behind the frontend. Trust boundary = network listener. | `[AGENT]` inventory routes × validation presence table in evidence |
| SEC-058 | Mass assignment prevented: API update/create handlers accept an explicit field allowlist (DTO/schema pick). Client-supplied fields like `role`, `is_admin`, `plan`, `price` can never flow into the DB untouched. | `[AGENT]` attempt extra-field injection in PATCH/POST → ignored/rejected |

---

## 6. Web Attack Prevention

| ID | Requirement | Verification |
|---|---|---|
| SEC-021 | XSS: user-generated content escaped/sanitized before HTML rendering. Raw HTML injection (`dangerouslySetInnerHTML`, `innerHTML`, `v-html`) only with sanitizer (DOMPurify-class) and documented justification. CSP deployed as backstop. | `[AUTO]` raw-HTML sink scan; `[AGENT]` stored-XSS probe on rich-text fields |
| SEC-022 | CSRF protection on all state-changing routes: SameSite cookies plus framework CSRF tokens where applicable; state-changing GETs forbidden. | `[AGENT]` cross-site form POST test without token → rejected |
| SEC-023 | File uploads locked down server-side: extension AND MIME AND magic-byte checks, size cap, randomized storage names, never executable, served from a separate domain/path with `Content-Disposition` where relevant. | `[AGENT]` upload polyglot/executable test → rejected; cite validator lines |
| SEC-024 | Path traversal blocked: normalize+resolve user-influenced paths and verify containment within the intended base directory before any fs/storage access. | `[AGENT]` `../../etc/passwd`-style probes on any download/read endpoints |
| SEC-025 | SSRF blocked: outbound requests derived from user input target-allowlist domains, block link-local/private IP ranges (incl. DNS-rebinding resolution re-check), disable redirect-following to internal ranges. | `[AGENT]` webhook/import URL probes to `169.254.x.x`, `localhost`, RFC1918 |
| SEC-066 | Open redirects prevented: any redirect driven by user input (`?next=`, `?returnUrl=`) validates against an exact origin/path allowlist — relative-paths-only or explicit host matching, never raw `Location` passthrough. Redirect chains via hosted link shorteners on your domain equally validated. | `[AGENT]` probe redirect endpoints with `https://evil.com`, `//evil.com`, `javascript:` → all rejected |
| SEC-059 | Command injection eliminated: no shell string composition from user input; prefer native APIs/libraries; unavoidable exec uses array-form args + allowlisted binaries. | `[AUTO]` `exec(`/`system(`/backtick-call scan; `[AGENT]` payload probes |
| SEC-060 | Insecure deserialization forbidden: no language-native object deserialization of untrusted data (PHP unserialize, Java readObject, Python pickle, Ruby Marshal). Use JSON/dataclass schemas with validation. | `[AGENT]` locate deserialization sites; confirm schema-based parsing |

---

## 7. Payments & Webhooks

| ID | Requirement | Verification |
|---|---|---|
| SEC-036 | Payment webhooks strictly verified: signature checked against provider SDK using the webhook secret from env; timestamp-tolerance enforced; unverified events dropped with 4xx; event processing idempotent. | `[AGENT]` replay unsigned/tampered webhook → rejected, paste output |
| SEC-037 | Pricing lives and is verified **only on the server**. Amounts come from server-side catalog/Stripe Price IDs — never from client-submitted totals. Server recomputes cart totals before charging. | `[AGENT]` tamper-test: submit modified price → server ignores client amount |

---

## 8. Rate Limiting & Abuse Prevention

| ID | Requirement | Verification |
|---|---|---|
| SEC-032 | Rate limiting on auth endpoints (login/signup/reset) and paid/expensive APIs, per-IP AND per-account, with lockout/backoff that cannot be weaponized for DoS against a victim's account. Limits tuned above legit traffic. | `[AGENT]` burst-test staging endpoint → 429s appear; cite limiter config |
| SEC-033 | Bot protection/CAPTCHA on public-facing forms (signup, contact, comment, password reset) — invisible-challenge first (Turnstile/hCaptcha class), escalating only on suspicion. | `[MANUAL]` form submission without challenge blocked; `[AGENT]` cite integration point |

---

## 9. Infrastructure & Configuration

| ID | Requirement | Verification |
|---|---|---|
| SEC-009 | Only the public/anon key ships to the frontend. The service/admin/secret key exists solely in server environments and is structurally excluded from client builds (separate env namespaces, import-lint rules). | `[AUTO]` service-key-name-in-client-code scan; `[AGENT]` build-output inspection |
| SEC-010 | Cloud production settings reviewed and hardened before launch: public exposure of buckets/DBs/dashboards off, backups on, IAM minimal, deletion protection where available. Documented once per project, re-checked quarterly. | `[MANUAL]` console checklist walkthrough recorded with date |
| SEC-011 | Admin routes protected: server-side authz (see SEC-005), separate credentials/2FA for admin surfaces, no admin functionality discoverable by URL guessing, admin panels not indexed or linked publicly. | `[AGENT]` unauthenticated admin-route sweep → all 401/403 |
| SEC-012 | Debug mode, verbose stack traces, debug toolbars (Flask/Werkzeug, Laravel Telescope, Django DEBUG, Express error stack) disabled in production builds. Errors are generic client-side; details go to server logs only. | `[AUTO]` debug-flag pattern scan for prod configs; `[AGENT]` trigger prod-style error page |
| SEC-031 | CORS explicitly allowlisted: specific origins, methods, headers. Never `Access-Control-Allow-Origin: *` on authenticated/API surfaces; never reflect arbitrary Origin with credentials. | `[AUTO]` wildcard-CORS scan; `[AGENT]` preflight test from disallowed origin |
| SEC-034 | Environments isolated: staging/dev use separate DBs, keys, and third-party test accounts. Production secrets never present in dev machines/CI logs beyond masked values. Deploy targets pinned per environment. | `[MANUAL]` env matrix documented; `[AGENT]` confirm code branches by env correctly |
| SEC-041 | Source maps disabled/excluded from production deploys (or uploaded privately to error trackers only). Public `.map` files = FAIL. | `[AUTO]` scan deployed/static dirs for `.map`; `[AGENT]` check build config |
| SEC-051 | Internal dashboards (DB UIs, task queues, mail catchers, metrics) unreachable from the public internet: VPN/IP-allowlist/SSO-gated, never on predictable public URLs without auth. | `[MANUAL]` external probe of dashboard hosts; record results |
| SEC-052 | Security headers set globally: CSP (at least frame-ancestors 'none'/default-src discipline), HSTS with preload intent, X-Content-Type-Options nosniff, X-Frame-Options/frame-ancestors DENY, Referrer-Policy strict-origin-when-cross-origin, Permissions-Policy minimized. | `[AUTO]` header-config scan; `[MANUAL]` securityheaders.com grade ≥ B recorded |
| SEC-053 | Cookies: `Secure`, `HttpOnly` (where not needed to JS), `SameSite` set, minimal scope/domain, defined Max-Age. No `domain=.com` over-broad cookies. | `[AUTO]` cookie-flag scan in framework config; `[AGENT]` Set-Cookie inspection |
| SEC-054 | HTTPS forced everywhere: HSTS on, http→https redirects 308/301, no mixed content, TLS ≥1.2, certificates auto-renewing. Internal service calls also TLS. | `[AUTO]` http:// URL scan (excluding localhost/docs); `[MANUAL]` cert monitor on |

---

## 10. Logging & Monitoring

| ID | Requirement | Verification |
|---|---|---|
| SEC-013 | Logs never contain secrets: passwords, tokens, full auth headers, card data, or full request bodies with PII. Log redaction/filter layer applied at the logging library level, not per-call hope. | `[AUTO]` scan for logging of password/token/key variables; `[AGENT]` sample real logs |
| SEC-014 | Production errors return generic messages + correlation IDs to clients. Stack traces, SQL, file paths, and config stay in server-side logs. Framework debug/verbose modes off (pairs with SEC-012). | `[AGENT]` force an error in staging-prod-mode → generic body shown |
| SEC-040 | Logs, log endpoints, and log dashboards are themselves protected: no public `/logs` routes, no downloadable log artifacts in web roots, log storage access-controlled. | `[AUTO]` public-log-path scan; `[MANUAL]` hosting config check |
| SEC-048 | Audit logs record security-relevant events (login, failed login, logout, password/email change, role change, data export, deletion, admin actions, payment events) with actor, IP, UA, timestamp — append-only. | `[AGENT]` map each event type → log call site; demonstrate one entry |
| SEC-049 | Security monitoring active: alerts on auth-failure spikes, 5xx spikes, webhook signature failures, rate-limit trips, and new admin actions. Alerts route somewhere a human actually reads (email/SMS/Slack). | `[MANUAL]` fire one test alert end-to-end; record delivery proof |

---

## 11. Supply Chain & Resilience

| ID | Requirement | Verification |
|---|---|---|
| SEC-042 | Dependencies scanned and updated: automated vulnerability scanning ( Dependabot/audit CI), zero known-critical vulns allowed at release, lockfiles committed, updates merged on schedule not never. | `[AUTO]` `npm audit --omit=dev` (or ecosystem equivalent) in audit script `-Deep` mode / CI |
| SEC-043 | New packages vetted before adoption: name typosquatting check, maintainer/publisher sanity, weekly-download floor, repo activity, license. Pin versions; review transitive surprises on major bumps. | `[AGENT]` vetting notes appended to checklist for each newly added dependency |
| SEC-050 | Backups automatic AND tested: scheduled DB backups, retention policy, point-in-time recovery where offered, and a restore drill performed (backup ≠ verified until restored). Restore drill date recorded. | `[MANUAL]` perform restore drill; record date + duration in checklist |
| SEC-057 | No unreviewed code merges to main: PR review by owner or second agent pass with requirement-ID citation, CI green (lint/type/tests/audit) required. Direct-to-main pushes disabled. | `[MANUAL]` branch protection settings; `[AGENT]` PR descriptions cite SEC/LEG IDs touched |

---

## 12. AI-Specific Security

| ID | Requirement | Verification |
|---|---|---|
| SEC-044 | Prompt injection defended: user input never concatenated into system prompts; system/user roles strictly separated; tool/function calls validated against allowlists; LLM output treated as untrusted data (never executed/rendered raw). | `[AGENT]` injection probes ("ignore instructions…", fake tool syntax) → contained |
| SEC-045 | Every AI endpoint requires authentication AND authorization like any other API; model/provider API keys server-side only; per-endpoint scopes so a leaked user token can't invoke arbitrary expensive models. | `[AGENT]` unauthenticated AI call → 401; low-privilege call to restricted model → 403 |
| SEC-046 | Per-user AI usage capped: quota/rate/token budget per user and per plan, tracked server-side, with graceful limit responses. Prevents single-user credit draining and runaway loops. | `[AGENT]` exceed-quota test → clean 429/limit message; cite counter implementation |
| SEC-067 | AI output schema-validated before use: model responses parsed against an expected schema (JSON schema/structured output/zod) and rejected on violation — never string-matched into execution, SQL, file paths, or rendered raw. Invalid output triggers a safe fallback path, not an exception leak. Pairs with SEC-044 (output = untrusted) and SEC-060. | `[AGENT]` feed malformed/adversarial model output through the parser → rejection path shown |
| SEC-068 | AI agents run least-privileged: any agent/tool-calling layer gets scoped, revocable credentials — read-only DB roles by default, per-tool allowlists, no shell/root, no cross-tenant access, spending caps per agent (SEC-046/SEC-062). An agent's blast radius is auditable: list every credential/tool it can touch. | `[AGENT]` produce agent-capability matrix (tools × permissions) for each AI feature |

---

## 13. Business Logic, Concurrency & Resilience

| ID | Requirement | Verification |
|---|---|---|
| SEC-069 | Business-logic abuse tested and blocked: every workflow with value (discount codes, referral credits, free tiers, trial resets, quantity limits, invite systems) is probed for exploitation via unconventional sequences — reuse, stacking, negative values, self-referral, replayed flows. Server enforces the intended business rules, not just input formats. | `[AGENT]` abuse matrix per workflow: attempt stacking/reuse/negative/sequence exploits → all rejected or clamped server-side |
| SEC-070 | Race conditions prevented where money/inventory/limits are involved: balance debits, coupon redemption, stock decrement, quota consumption, and one-per-user actions use DB transactions with row locks or atomic conditional updates (`UPDATE … WHERE balance >= x`), never read-then-write across requests. Concurrent-request tests prove single execution. | `[AGENT]` fire N parallel requests against a limited resource → exactly-once behavior shown (e.g., 2 concurrent redemptions of 1-use code) |
| SEC-071 | Security checks fail CLOSED: every authz/auth/permission decision defaults to DENY on error, timeout, or missing data — exceptions never grant access. Feature flags and entitlement checks resolve to the restrictive branch when their source is unavailable. | `[AGENT]` simulate check failure (throw/unreachable provider) in staging → access denied, error handled, no grant |
| SEC-072 | Strict timeouts on all outbound calls: external HTTP clients, AI providers, payment gateways, and DB queries have explicit connect+read timeouts (seconds, not none) plus retry caps with jitter — no request path can hang forever and pin workers into DoS-by-slow-neighbor. | `[AGENT]` cite timeout configuration per client; staging test with a deliberately slow endpoint → circuit opens |

---

## 14. CI/CD & Pipeline Security

| ID | Requirement | Verification |
|---|---|---|
| SEC-073 | Deployment pipelines secured: workflow files live only on protected branches, secrets via masked CI variables (never inline), deployments require review for production targets, and pipeline tokens are minimal-scope + short-lived. Unauthorized workflow edits cannot reach production. | `[MANUAL]` branch protection + environment protection rules recorded; `[AGENT]` inventory workflow triggers vs protection |
| SEC-074 | Third-party build actions audited: every GitHub Action/CI plugin reviewed (publisher, popularity, pinned source) before adoption; new/low-trust actions rejected. Changes to build actions get the same review as code (SEC-057). | `[AGENT]` action inventory table: name → publisher → trust rationale |
| SEC-075 | Build dependencies pinned: CI actions pinned to full-length commit SHAs (not mutable tags like `@v3`), lockfiles committed and used in CI (`npm ci`), and build tooling versions fixed — a renamed tag or published-later dependency cannot silently inject code into builds. | `[AUTO]` audit scan flags `uses:` lines without SHA pinning; `[AGENT]` confirm `npm ci` in pipeline |

---

## Exceptions Register

Any deviation from these rules requires an entry here: ID, reason, compensating
control, owner, expiry date.

| ID | Reason | Compensating control | Expiry |
|---|---|---|---|

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | Initial import: 63 security items organized into 12 sections with stable IDs and verification methods. |
| 2026-08-24 | v2: SEC-003 short-lived credentials emphasis; SEC-018 wording strengthened to schema-based sanitization with unexpected-field rejection (v2 item 18). No IDs changed. |
| 2026-08-24 | v3: Added 12 items from Part 4 of the source series — SEC-064 (user MFA), SEC-065 (account enumeration), SEC-066 (open redirects), SEC-067 (AI output validation), SEC-068 (AI agent least privilege), SEC-069 (business-logic abuse), SEC-070 (race conditions), SEC-071 (fail-closed checks), SEC-072 (external timeouts), SEC-073 (CI/CD security), SEC-074 (untrusted build actions), SEC-075 (pinned build deps). New sections 13–14. Total now 75. |
