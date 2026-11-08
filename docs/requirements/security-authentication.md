# Security, Authentication & Infrastructure Requirements

**Scope:** All server, client, database, infrastructure, payment, pipeline,
and AI code in every project in this workspace.
**Items:** SEC-001 … SEC-087 (87 requirements; SEC-083 retired v4.1 — see its row and the Exceptions Register).
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
| SEC-062 | Every paid service (hosting, AI APIs, email, storage) has a hard spend cap and a billing alert configured so a bug or abuse cannot drain the account silently. | `[MANUAL]` billing console screenshot per service recorded in the project's RULER-REPORT.md |
| SEC-063 | 2FA is enabled on all infrastructure accounts: hosting, cloud consoles, DB dashboards, domain registrar, DNS, GitHub/org admin, email root. Prefer hardware key or TOTP over SMS. | `[MANUAL]` account-by-account confirmation logged in the project's RULER-REPORT.md |

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
| SEC-056 | Multi-tenant data isolation is absolute: tenant scoping enforced in queries AND/OR Postgres RLS policies; cross-tenant leakage tests run before every release that touches shared tables. Extended (v4) beyond SQL: object storage enforces deny-by-default policies with private-by-default buckets and TTL-bounded signed URLs for user files (Supabase Storage-class access lives in storage policies, not table RLS); vector/embedding stores carry tenant+permission metadata filtered server-side at query time by the requesting principal's authorization — never via prompt instructions. Cross-tenant retrieval/object-read probes join the release gate. | `[AUTO]` RLS presence check where applicable; `[AGENT]` cross-tenant probe test incl. object URLs + RAG retrieval |

---

## 4. Database Security

| ID | Requirement | Verification |
|---|---|---|
| SEC-007 | DB permission rules reviewed and locked down: no publicly writable tables, no world-readable sensitive tables, grants limited to explicit needs. For Supabase/Firebase-style backends, security rules deny by default. | `[AGENT]` record evidence of effective grants/rules in the project's RULER-REPORT.md; `[MANUAL]` console review |
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
| SEC-036 | Payment webhooks strictly verified: signature checked against provider SDK using the webhook secret from env; timestamp-tolerance enforced; unverified events dropped with 4xx; event processing idempotent. Extended (v4) to ALL machine-invoked endpoints: cron triggers, queue consumers, and internal callbacks require their own shared-secret/signature header (Vercel `CRON_SECRET` pattern) and fail closed (401/404) without it — inbound webhook trust does not cover self-invoked machine endpoints. | `[AGENT]` replay unsigned/tampered webhook → rejected, paste output; curl each cron/internal route without credentials → 401/403/404 |
| SEC-037 | Pricing lives and is verified **only on the server**. Amounts come from server-side catalog/Stripe Price IDs — never from client-submitted totals. Server recomputes cart totals before charging. | `[AGENT]` tamper-test: submit modified price → server ignores client amount |

---

## 8. Rate Limiting & Abuse Prevention

| ID | Requirement | Verification |
|---|---|---|
| SEC-032 | Rate limiting on auth endpoints (login/signup/reset) and paid/expensive APIs, per-IP AND per-account, with lockout/backoff that cannot be weaponized for DoS against a victim's account. Limits tuned above legit traffic. Amended (v4.1, from live differential pentest): every state-changing endpoint validates the DECLARED body size before performing any blocking read and rejects absurd values with 413; the server sets explicit per-connection read timeouts so a client that stalls mid-request (slowloris, CWE-400) cannot pin a worker thread indefinitely. | `[AGENT]` burst-test staging endpoint → 429s appear; cite limiter config; `[AGENT]` half-open request with inflated Content-Length times out / gets 413 instead of wedging the server |
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
| SEC-054 | HTTPS forced everywhere: HSTS on, http→https redirects 308/301, no mixed content, TLS ≥1.2, certificates auto-renewing. Internal service calls also TLS. Amended (v4): an independent certificate-expiry alarm exists (wired to the OPS-129 expiry guard) and HTTPS is re-verified after ANY DNS change — auto-renewal is assumed broken until proven, since certs on non-default hosts fail issuance silently. | `[AUTO]` http:// URL scan (excluding localhost/docs); `[MANUAL]` cert monitor on; expiry alarm delivery tested |

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
| SEC-043 | New packages vetted before adoption: name typosquatting check, maintainer/publisher sanity, weekly-download floor, repo activity, license. Pin versions; review transitive surprises on major bumps. | `[AGENT]` vetting notes recorded in the project's RULER-REPORT.md for each newly added dependency |
| SEC-050 | Backups automatic AND tested: scheduled DB backups, retention policy, point-in-time recovery where offered, and a restore drill performed (backup ≠ verified until restored). Restore drill date recorded. | `[MANUAL]` perform restore drill; record date + duration in the project's RULER-REPORT.md |
| SEC-057 | No unreviewed code merges to main: PR review by owner or second agent pass with requirement-ID citation, CI green (lint/type/tests/audit) required. Direct-to-main pushes disabled. | `[MANUAL]` branch protection settings; `[AGENT]` PR descriptions cite SEC/LEG IDs touched |

---

## 12. AI-Specific Security

| ID | Requirement | Verification |
|---|---|---|
| SEC-044 | Prompt injection defended: user input never concatenated into system prompts; system/user roles strictly separated; tool/function calls validated against allowlists; LLM output treated as untrusted data (never executed/rendered raw). Amended (v4, OWASP LLM07): system/prompt templates contain no credentials, API keys, internal hostnames, or personal data and pass the same secret-pattern scans as any config artifact (SEC-001-style) — system prompts are treated as extractable by design, so no access decision may ever rely on a prompt staying secret. | `[AGENT]` injection probes ("ignore instructions…", fake tool syntax) → contained; `[AUTO]` secret-pattern scan over prompt templates |
| SEC-045 | Every AI endpoint requires authentication AND authorization like any other API; model/provider API keys server-side only; per-endpoint scopes so a leaked user token can't invoke arbitrary expensive models. | `[AGENT]` unauthenticated AI call → 401; low-privilege call to restricted model → 403 |
| SEC-046 | Per-user AI usage capped: quota/rate/token budget per user and per plan, tracked server-side, with graceful limit responses. Prevents single-user credit draining and runaway loops. | `[AGENT]` exceed-quota test → clean 429/limit message; cite counter implementation |
| SEC-067 | AI output schema-validated before use: model responses parsed against an expected schema (JSON schema/structured output/zod) and rejected on violation — never string-matched into execution, SQL, file paths, or rendered raw. Invalid output triggers a safe fallback path, not an exception leak. Pairs with SEC-044 (output = untrusted) and SEC-060. | `[AGENT]` feed malformed/adversarial model output through the parser → rejection path shown |
| SEC-068 | AI agents run least-privileged: any agent/tool-calling layer gets scoped, revocable credentials — read-only DB roles by default, per-tool allowlists, no shell/root, no cross-tenant access, spending caps per agent (SEC-046/SEC-062). An agent's blast radius is auditable: list every credential/tool it can touch. Amended (v4, OWASP LLM06): irreversible actions — delete/wipe, mass-send, payments, public posting — require explicit per-action human confirmation or a sandbox/dry-run first, have independent rate limits per high-impact tool class, and every executed action is audit-logged attributed to the initiating user and conversation. | `[AGENT]` produce agent-capability matrix (tools × permissions) for each AI feature; demonstrate human gate on one irreversible action |

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

## 15. v4 Additions — Deployment Surface, Recovery & Operational Security

Added in the v4 expansion (2026-08-24 research pass). Scope tags: items marked
*(feature-gated)* activate when the named feature exists; the rest are universal.

| ID | Requirement | Verification |
|---|---|---|
| SEC-076 | Every non-production deployment surface (preview URLs, staging, branch deploys) sits behind platform-level authentication (e.g., Vercel Deployment Protection) and never connects to production data stores unless it enforces identical access controls. An anonymous fetch of any preview URL hits a login wall. | `[MANUAL]` protection setting recorded per project; `[AUTO]` unauthenticated probe of deployed preview hostnames |
| SEC-077 | Passwords validated server-side per NIST SP 800-63B: minimum length enforced (≥8; ≥15 when password is the sole factor), ≥64 chars accepted, NO composition rules, NO periodic rotation — and prospective passwords are checked against a breached/common-password blocklist and rejected on match. Pairs with SEC-029 hashing. | `[AUTO]` signup/reset probes: `password123`-class rejected, long passphrase accepted |
| SEC-078 | Every list/search/export endpoint enforces a server-side default page size AND a hard maximum (~100 records); client-supplied `limit`/`offset`/`page` params are clamped or rejected. Rate limits bound requests-per-minute; this bounds rows-per-response (OWASP API4). | `[AUTO]` probe `?limit=<huge>` on each collection route → clamped/400 |
| SEC-079 | High-risk actions (password/email change, MFA-device change, payout/bank details, bulk export, role grants) re-authenticate with the current password (plus MFA where enrolled) within a ≤15-min freshness window — house values, NIST SP 800-63B-aligned; completing such changes revokes other sessions; email/contact changes notify BOTH old and new address out-of-band and activate only after the NEW address confirms within 24 h — auto-revert otherwise; no support/help-desk path bypasses these checks. Enterprise extras (scheduled reversal-window machinery, dedicated step-up UI, support-desk identity runbooks) stay dormant until staff/admin roles exist. | `[AGENT]` aged-session sensitive op → challenged; old+new notification shown; unconfirmed contact change auto-reverts; session revocation diffed |
| SEC-080 | Client-loaded third-party scripts come only from a reviewed allowlisted origin set and carry SRI hashes (or are vendored first-party); marketing tags load consent-gated (LEG-079); CSP blocks every other script origin — a compromised CDN or tag must never gain first-party execution (polyfill.io class). Dynamic third-party payloads (ads, GA4/GTM-class loaders, A/B tools, chat widgets) cannot carry SRI — for those the control is the origin allowlist + consent gating + CSP + runtime script-change monitoring; SRI applies to stable, vendored/versioned libraries. | `[AUTO]` crawl shipped pages: every external `<script src>` is allowlisted + integrity-attributed or self-hosted |
| SEC-081 | Environment data hygiene: production personal data is never copied into dev/staging without irreversible PII masking; any script/job capable of mass deletion/reset/schema destruction refuses to execute unless an explicit per-run flag names the target environment; required env-var NAMES are identical across environments (CI-diffed) and the app fails fast at boot on missing/empty required variables. Extends SEC-034. | `[AGENT]` destructive-script guard demo (refuses prod without flag) + masking step cited; `[AUTO]` CI env-name parity diff |
| SEC-082 | Break-glass recovery: every critical infrastructure account (registrar, DNS, hosting, cloud root, repo admin, ESP) has 2FA recovery codes exported to offline storage plus a written recovery path, exercised at least once so the runbook is proven. Completes SEC-063 (which mandates 2FA but not the exit). | `[MANUAL]` codes-stored confirmation + dated recovery walkthrough per account |
| SEC-083 | **RETIRED (v4.1, owner-approved)** — identity inventory + same-day offboarding is deferred until the first hire/subcontractor exists; until then, fold "delete unused API keys/tokens/webhooks when noticed" into SEC-010's existing quarterly console sweep. Reinstate this row as written when the team grows past one person (IDs are permanent — the number is never reused or renumbered). | `[MANUAL]` reinstatement recorded here when triggered; interim coverage: SEC-010 quarterly walkthrough includes unused-key/token cleanup |
| SEC-084 | No dangling DNS: every CNAME/A/AAAA/wildcard record in each managed zone points at a still-provisioned resource you control; decommissioning a service removes its records the same day; zones audited quarterly against known takeover fingerprints — abandoned records let attackers serve phishing from your own subdomains with valid certificates. | `[AUTO]` quarterly zone scan flags NXDOMAIN targets / takeover fingerprints |
| SEC-085 | *(feature-gated: external AI APIs)* AI integrations pin explicit versioned model IDs (never unversioned `-latest` aliases); provider deprecation notices are subscribed with migrations scheduled before shutdown dates; before each AI-feature release a small golden-set smoke test (≥5 representative prompts with expected behavior) passes; provider error-rate spikes alert through existing monitoring (OPS-121/SEC-049) with a defined degraded-mode fallback. Model supply-chain mirror of SEC-043/075. | `[AUTO]` unpinned-model-string scan; `[AGENT]` golden-set smoke-run evidence; `[MANUAL]` deprecation-watch subscription recorded |
| SEC-086 | *(feature-gated: self-hosted checkout)* Card-data pages embed payment fields ONLY from processor-hosted iframes/scripts (Stripe Elements / hosted checkout class); unrelated third-party JS stays off those pages; the annual SAQ A is filed with the affirmative script-susceptibility confirmation (PCI DSS v4.x FAQ 1588). Custom card-data fields void SAQ-A eligibility (card functions not fully outsourced → SAQ A-EP); extra scripts do NOT automatically void eligibility, but the filing requires evidencing non-susceptibility — CSP/hash allowlists, runtime monitoring, or written processor attestation. | `[AUTO]` payment-page scan for non-processor scripts/custom card inputs; `[MANUAL]` SAQ filing incl. confirmation method, dated |
| SEC-087 | *(feature-gated: traffic-attracting launch)* Before launch spikes: platform always-on DDoS mitigation confirmed active and WAF/bot managed rulesets (or a Cloudflare proxy) enabled on authenticated/expensive routes, with mitigated-request billing behavior understood — a distinct layer from SEC-032's application-level limits. | `[MANUAL]` firewall/DDoS settings confirmed per project; `[AGENT]` synthetic abusive request → challenge/block fires |

---

## Attack-Chain Awareness (reviewer guidance)

Vulnerabilities compound. During live validation, a read-only path-traversal
bug was chained to exfiltrate application source (exposing hardcoded
credentials) and the database itself — turning two MEDIUM-class issues into a
full compromise. When reviewing or fixing any single finding, agents MUST ask:
*what does this bug let me reach next?* Source disclosure → secret reuse;
injection → privilege data; SSRF → cloud metadata. Fix chains, not just sinks,
and re-run the audit after every fix in a chain.

## Exceptions Register

Any deviation from these rules requires an entry here: ID, reason, compensating
control, owner, expiry date.

| ID | Reason | Compensating control | Expiry |
|---|---|---|---|

- **SEC-083** — Retired v4.1 (owner-approved 2026-08-25): identity inventory +
  same-day offboarding assumes staff this workspace doesn't have; bookkeeping
  overhead for a solo founder outweighs benefit. Compensating control: unused
  key/token/webhook cleanup folded into SEC-010's quarterly console sweep.
  Reinstatement trigger: first hire/subcontractor. ID never reused; the
  requirement row carries the reinstatement text.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | Initial import: 63 security items organized into 12 sections with stable IDs and verification methods. |
| 2026-08-24 | v2: SEC-003 short-lived credentials emphasis; SEC-018 wording strengthened to schema-based sanitization with unexpected-field rejection (v2 item 18). No IDs changed. |
| 2026-08-24 | v3: Added 12 items from Part 4 of the source series — SEC-064 (user MFA), SEC-065 (account enumeration), SEC-066 (open redirects), SEC-067 (AI output validation), SEC-068 (AI agent least privilege), SEC-069 (business-logic abuse), SEC-070 (race conditions), SEC-071 (fail-closed checks), SEC-072 (external timeouts), SEC-073 (CI/CD security), SEC-074 (untrusted build actions), SEC-075 (pinned build deps). New sections 13–14. Total now 75. |
| 2026-08-24 | v4: Added section 15 — SEC-076 (preview/staging auth protection), SEC-077 (NIST password validation + breached-password blocklist), SEC-078 (collection endpoint page-size caps), SEC-079 (step-up re-auth + contact-change notifications + support-path MFA rule), SEC-080 (third-party script allowlist + SRI), SEC-081 (env data hygiene + destructive-script guards + env-name parity), SEC-082 (break-glass recovery codes/runbooks), SEC-083 (identity inventory + same-day offboarding), SEC-084 (dangling-DNS/takeover audits), SEC-085 (AI model pinning/deprecation watch/eval gates — feature-gated), SEC-086 (PCI SAQ-A eligibility hygiene — feature-gated), SEC-087 (DDoS/WAF launch posture — feature-gated). Amended SEC-036 (machine-endpoint auth), SEC-044 (system prompts hold no secrets / treated as extractable), SEC-054 (cert-expiry alarm + post-DNS-change reverify), SEC-056 (object-storage + vector-store tenant parity), SEC-068 (human gate for irreversible agent actions). Total now 87. |
| 2026-08-25 | v4.1 calibration pass (owner-approved, from the four-reviewer audit): **SEC-079** simplified to small-team mechanics — current-password re-auth ≤15 min + MFA where enrolled (house values, NIST-aligned), confirm-to-activate contact change with 24 h auto-revert replaces the pending-change/reversal-window machinery and support-desk runbook (dormant until staff exist). **SEC-080** gained the dynamic-payload carve-out (ads/GTM-class tags cannot carry SRI; allowlist+CSP+consent+monitoring is their control) per PCI-independent fact-check of SRI limitations. **SEC-083** retired to the Exceptions Register (defer until first hire; number never reused); interim coverage via SEC-010 quarterly sweep. **SEC-085** eval-set deploy gate replaced by a ≥5-prompt golden-set smoke test; error spikes alert through existing OPS-121/SEC-049 monitoring. **SEC-086** corrected against PCI SSC FAQ 1588: extra scripts do NOT void SAQ-A eligibility — custom card fields do; filing needs affirmative non-susceptibility confirmation. ID count unchanged at 87 tracked (86 active + SEC-083 retired-in-place). |
| 2026-08-25 | Strix differential-pentest feedback (owner-directed live validation): audit script gained **SERVER-HTML-SINK** (SEC-021 — server-side f-string HTML composition without escaping, Python/Ruby) and **UNCONTAINED-FILE-OPEN** (SEC-024 — `open(os.path.join(base, var))` without visible containment check). Both were proven exploitable by an agentic pentest on a practice target (stored XSS via unescaped server-rendered comment; path traversal chaining to source/DB exfiltration) while the static JS-layer scans saw nothing; new checks verified to fire on that target and stay silent on its clean twin. Machine checks now 37. |
| 2026-08-25 | SEC-032 amended after Strix's clean-target scan returned one TRUE positive (slowloris wedge, CWE-400: inflated Content-Length with stalled body pinned a single-threaded worker forever): state-changing endpoints must validate declared body size before any blocking read (reject 413) and set explicit per-connection read timeouts. Verification column extended with a half-open-request probe; fix proven by exploit replay (instant 413, server stays healthy). No ID count change. |
| 2026-08-25 | v4.1.1 audit-calibration (Darb Bahrain run): **PRIVILEGED-KEY-IN-CLIENT** pattern now requires an actual assigned value (`NAME=xyz` / `NAME: xyz`) — documentation prose ("never expose SERVICE_ROLE_KEY") and empty `.env.example` template lines no longer false-positive as SEC-009/SEC-047 FAILs; genuine client-side assignments still fail. Check count unchanged (37 machine checks); no ID changes. |
| 2026-08-25 | v4.1.2 reconciliation (cross-session): the v4.1.1 tightening accidentally missed runtime ACCESS forms — a client file reading `process.env.SERVICE_ROLE_KEY` is itself the leak vector even without an assignment. Pattern now matches assignment form (with value) OR privileged-name access via process.env/os.environ; prose/template false-positives stay fixed. Trap suite re-proves both directions (client usage FAILs, server-dir usage passes). |
| 2026-08-25 | v4.2 repo-type scoping (owner-directed "functionality first, analyze each case"): audit-compliance.ps1 auto-classifies targets from ROOT-level evidence only (root index.html / next|nuxt|astro|vite|svelte config / framework dep in root package.json); non-web targets skip absence-based marketing checks (BOILERPLATE-TITLE, HTML-LANG, H1-COUNT, OG/canonical/schema, sitemap/robots/llms.txt, BUNDLE-SIZE) as SKIP-not-applicable while every security and code-quality check always runs. `-ProjectType Web|Library` overrides Auto; generated artifacts deep in a tree (report.html, docs builds) never flip classification. Proven on three live repos: docsqueeze/agentport-class CLI → LIBRARY exit 0; Tijarti (Next.js) → WEB with all checks intact. Detector precision fixes in the same pass: SERVER-HTML-SINK and PLAINTEXT-HTTP-URL exclude tests/fixtures paths (attack-string fixtures were self-flagging), idpf.org added to namespace allowlist beside w3.org/purl.org. |
