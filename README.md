# Ruler

**The ruler every AI agent measures code against.** A master compliance
list (190 stable requirement IDs as of v4, 2026-08-24) covering security, authentication,
GCC PDPL / GDPR legal compliance, SEO/production config, conversion quality,
UI/UX, and post-launch operations — plus tools that check parts of the list.

Built to be dropped next to your code so that **any** AI agent — Codex,
Claude Code, Gemini CLI, Cursor, opencode — reads the same rules before
writing a single line.

## What's inside

| Path | Purpose |
|---|---|
| `AGENTS.md` | Entry point every agent auto-reads: governance rules + file index |
| `docs/requirements/*.md` | The 190 requirements, each with rule text + a verification method (`[AUTO]` / `[AGENT]` / `[MANUAL]`) |
| `docs/requirements/compliance-checklist.md` | Shared requirements index; each project keeps its own status and evidence |
| `docs/requirements/tooling-costs.md` | Free/paid map + what to reconfigure when you upgrade a plan |
| `docs/requirements/security-testing-tools.md` | Security tools, independent cross-checks, and safe testing scope |
| `scripts/audit-compliance.ps1` | 37 automated machine checks (grep/git/npm/DNS-free static layer) covering part of the `[AUTO]` items; the rest of the `[AUTO]` tags are executed as agent-run or CI probes per each row's verification column |
| `scripts/verify-library.ps1` | 32 assertions proving the library itself is structurally sound |
| `tests/run-repo-tests.ps1` | Full test suite: tamper-resistance, planted-violation detection, exit-code contracts, cross-file consistency |

## Design principles

- **Stable IDs, forever.** `SEC-028` means the same thing in 10 years. Items
  get renumbered never; new items append.
- **Evidence or it isn't done.** An agent claiming compliance must cite
  `file:line`, a test, or audit output — otherwise it reports `UNVERIFIED`.
- **Rules, never secrets.** This repo contains policies, not credentials.
  Whitelist-only `.gitignore` makes leaking practically impossible.
- **Machine-checked where possible.** Prose doesn't scale; the audit script
  does.
- **Relevant and efficient.** Apply controls to real project features and
  risks; document exclusions. Prefer existing platform controls and measure
  performance without weakening protections.
- **Evidence has limits.** A scan cannot prove a project unhackable or guarantee
  legal compliance. Record unverified checks and obtain appropriate expert review.

## Usage

```powershell
# audit a project against the requirements (auto-detects web vs library;
# force with -ProjectType Web|Library)
powershell -File scripts/audit-compliance.ps1 -Target <project-folder> [-Deep]

# wire ANY project to this library (writes its AGENTS.md hook pointing here)
powershell -File scripts/link-project.ps1 -Target <project-folder>

# verify the library structure itself
powershell -File scripts/verify-library.ps1
```

Each project audit appends an IN PROGRESS review to that project's
`RULER-REPORT.md`. It records the Ruler and project revisions when available,
audit checks and findings, and every requirement ID as UNVERIFIED. The agent
then records applicability, reasons, evidence, project findings, Ruler
mistakes, fixes and retests. The report stays with the project. Use the
Caveman skill when available, while keeping evidence and uncertainty clear.

Agents: read `AGENTS.md` first. For linked projects, the project hook calls for
security checks suited to the project, including Strix when available and
appropriate. Investigate findings, fix confirmed issues, retest, and record
results and unrun checks in the project's own `RULER-REPORT.md`. A clean scan
alone does not establish complete security.

<!-- requirements:start -->
## Requirement tracker

Short descriptions below come from the [requirements index](docs/requirements/compliance-checklist.md). Updates to the index refresh this list after changes reach the main branch. Each project keeps its own check results and evidence.

Only apply requirements relevant to the project. A passing automated audit covers only some requirements.

### Security and authentication (SEC)

| ID | What it covers |
|---|---|
| SEC-001 | No DB credentials in code/bundles/logs |
| SEC-002 | .env gitignored, never tracked |
| SEC-003 | API keys server-side env only; short-lived where possible |
| SEC-015 | Git history secret-free (rotate+purge on leak) |
| SEC-016 | No secrets in front-end bundles |
| SEC-030 | JWT secrets long/random/rotated/env-sourced |
| SEC-035 | Default credentials removed everywhere |
| SEC-062 | Spend caps + billing alerts all paid services |
| SEC-063 | 2FA on all infrastructure accounts |
| SEC-004 | Auth enforced server-side, not UI-only |
| SEC-026 | Password reset: single-use, TTL ≤15min, no enumeration |
| SEC-064 | User-facing MFA (TOTP) offered; enforced for admins |
| SEC-065 | Account enumeration blocked on login/signup/reset (generic responses + timing) |
| SEC-027 | Sessions expire, rotate, server-side destroy on logout |
| SEC-028 | Tokens in Secure/HttpOnly/SameSite cookies (not localStorage) |
| SEC-029 | bcrypt ≥12 / argon2id password hashing |
| SEC-061 | OAuth state validated, strict redirects, server-side exchange |
| SEC-005 | Server-side authz on every endpoint, deny by default |
| SEC-006 | Users access only own records |
| SEC-038 | IDOR/BOLA sweep incl. nested/export endpoints |
| SEC-056 | Tenant isolation absolute (scoping + RLS) |
| SEC-007 | DB rules/grants deny-by-default, reviewed |
| SEC-008 | RLS enabled on every user/business table |
| SEC-047 | Least-privilege DB roles; service keys never client-side |
| SEC-055 | Sensitive data encrypted at rest (+app-level crown jewels) |
| SEC-017 | Never trust client-side security decisions |
| SEC-018 | Schema-based validation: types, lengths, reject unexpected fields |
| SEC-019 | Parameterized queries exclusively (SQL injection) |
| SEC-020 | NoSQL injection blocked (operator/`$where`) |
| SEC-039 | Every API route validates inputs independently |
| SEC-058 | Mass assignment blocked via field allowlists |
| SEC-021 | XSS: escape/sanitize rendered user content + CSP |
| SEC-022 | CSRF protection on state-changing routes |
| SEC-023 | File uploads: type+magic-byte+size checks, safe storage |
| SEC-024 | Path traversal blocked (containment verified) |
| SEC-025 | SSRF blocked (allowlist, private-range denial) |
| SEC-066 | Open redirects prevented (allowlist-validated redirects) |
| SEC-059 | Command injection eliminated |
| SEC-060 | No native deserialization of untrusted data |
| SEC-036 | Webhook signatures strictly verified, idempotent processing |
| SEC-037 | Pricing set/verified server-side only |
| SEC-032 | Rate limits on login/signup/paid APIs (IP + account) |
| SEC-033 | Bot protection/CAPTCHA on public forms |
| SEC-009 | Only anon/public key in frontend |
| SEC-010 | Cloud prod settings hardened + quarterly recheck |
| SEC-011 | Admin routes protected (authz + 2FA, undiscoverable) |
| SEC-012 | Debug mode/toolbars disabled in production |
| SEC-031 | CORS explicit allowlist, no wildcard w/ credentials |
| SEC-034 | Environments isolated (DBs, keys, accounts) |
| SEC-041 | Source maps not public in production |
| SEC-051 | Internal dashboards unreachable from public internet |
| SEC-052 | Security headers: CSP/HSTS/nosniff/frame-deny/etc. |
| SEC-053 | Cookie flags: Secure/HttpOnly/SameSite/scope/max-age |
| SEC-054 | HTTPS forced everywhere, TLS ≥1.2 |
| SEC-013 | Logs redact secrets/PII at library level |
| SEC-014 | Generic prod errors; traces stay server-side |
| SEC-040 | Logs/log-endpoints themselves protected |
| SEC-048 | Audit logs for security events (actor/IP/UA/time) |
| SEC-049 | Security alerting wired to a human-read channel |
| SEC-042 | Dependency scanning in CI, zero known-critical at release |
| SEC-043 | New packages vetted (typosquat/popularity/license) |
| SEC-050 | Automatic backups + tested restore drill (dated) |
| SEC-057 | No unreviewed merges to main; CI green required |
| SEC-044 | Prompt injection defended; LLM output untrusted |
| SEC-045 | AI endpoints authed/authz'd; keys server-side |
| SEC-046 | Per-user AI usage caps enforced server-side |
| SEC-067 | AI output schema-validated before execution/render |
| SEC-068 | AI agents least-privileged (scoped tools/credentials) |
| SEC-069 | Business-logic abuse tested (discounts, credits, sequences) |
| SEC-070 | Race conditions prevented (atomic ops, locks) |
| SEC-071 | Security checks fail CLOSED on error/timeout |
| SEC-072 | Strict timeouts on external APIs + DB queries |
| SEC-073 | Deployment pipelines secured (review-gated, masked secrets) |
| SEC-074 | Third-party build actions vetted before adoption |
| SEC-075 | Build deps pinned (SHA-pinned actions, lockfile `npm ci`) |
| SEC-076 | Preview/staging deployments auth-protected; never touch prod data anonymously |
| SEC-077 | Passwords NIST-validated (length floor, 64+ accepted, no composition/rotation) + breached-password blocklist |
| SEC-078 | Collection/export endpoints clamp page size server-side (hard max ~100) |
| SEC-079 | Step-up re-auth ≤15min on sensitive ops; contact changes confirm-to-activate w/ 24h auto-revert |
| SEC-080 | Third-party scripts allowlisted + SRI/self-hosted; CSP blocks all other origins |
| SEC-081 | No unmasked prod PII in lower envs; destructive scripts require env-naming flag; env-var name parity + fail-fast boot |
| SEC-082 | Break-glass recovery codes offline + exercised runbook per infra account |
| SEC-083 | Identity inventory (humans + keys/tokens/grants); same-day offboarding; quarterly dormant-access purge |
| SEC-084 | Zero dangling DNS records; quarterly takeover-fingerprint zone audit |
| SEC-085 | AI model versions pinned; deprecation watch; golden-set smoke test before AI releases *(feature-gated: external AI APIs)* |
| SEC-086 | Card pages processor-iframe-only; SAQ A filed w/ affirmative script-susceptibility confirmation *(feature-gated: self-hosted checkout)* |
| SEC-087 | DDoS/WAF platform posture confirmed before launch spikes *(feature-gated: traffic-attracting launch)* |

### Mobile apps (MOB)

| ID | What it covers |
|---|---|
| MOB-064 | No API keys in compiled app bundle |
| MOB-065 | Tokens in Keychain/Keystore, not AsyncStorage |
| MOB-066 | Deep links validated before sensitive actions |
| MOB-067 | Biometrics unlock UI only; server step-up for sensitive actions |
| MOB-068 | ATT prompt iff tracking used; disclosures synced |
| MOB-069 | Store privacy labels accurate; Play deletion web link live; Apple privacy manifests complete *(feature-gated: store distribution)* |

### Performance and data (PERF)

| ID | What it covers |
|---|---|
| PERF-069 | Queries fetch only what UI needs |
| PERF-070 | N+1 queries eliminated/batched |
| PERF-071 | Indexes on frequent search/filter/join columns |
| PERF-072 | Connections closed properly; bounded pools |
| PERF-073 | Object storage free of orphaned blobs; cleanup jobs |
| PERF-074 | No hidden background jobs holding connections |
| PERF-075 | Cascading deletions: files/images/rows all wiped, zero orphans |
| PERF-076 | Third-party purge: payment/ESP/AI-log deletion requests automated |
| PERF-077 | Schema changes ship as versioned forward-only migrations; no manual console DDL; destructive ops expand→contract |
| PERF-078 | Business invariants mirrored by DB-level NOT NULL/UNIQUE/FK/CHECK constraints |
| PERF-079 | Jobs: bounded retries, alerting dead-letter state, idempotent replay, heartbeat monitor for missed runs |
| PERF-080 | Money stored as integer minor-units/NUMERIC with currency column; floats forbidden *(feature-gated: payments/billing)* |

### Privacy and legal (LEG)

| ID | What it covers |
|---|---|
| LEG-075 | Accessibility statement + WCAG 2.1 AA incl. alt text on all images |
| LEG-076 | EULA published, versioned |
| LEG-077 | Privacy Policy: exact data inventory, bases, transfers |
| LEG-078 | ToS published; acceptance captured w/ version+timestamp |
| LEG-079 | Block non-essential tracking until required consent; no needless banner |
| LEG-080 | Erasure requests, exceptions, processors and backups assessed |
| LEG-085 | Minimize and protect retained data; distinguish pseudonymization |
| LEG-086 | Backup expiry and safe restores follow documented retention |
| LEG-081 | Applicable portability rights and request deadlines assessed |
| LEG-082 | Data localization/transfer mechanisms documented per region |
| LEG-083 | Zero pre-ticked marketing checkboxes; consent records kept |
| LEG-084 | Breach plan, jurisdiction-specific triggers, deadlines and drill |
| LEG-087 | Proportionate child-safety and age-assurance assessment |
| LEG-088 | Parental authorization where applicable; document legal basis |
| LEG-089 | Minor accounts default to maximum privacy settings |
| LEG-090 | AI provider terms, retention and training use reviewed |
| LEG-091 | Minimize and protect user data sent to external AI |
| LEG-092 | Assess actual external data flows and cross-border transfers |
| LEG-093 | Assess sensitive data, legal basis and applicable safeguards |
| LEG-094 | Retention periods enforced by automated purge mechanisms with logged runs (policy text alone fails) |
| LEG-095 | Grounded customer AI, disclosure and justified transcript retention |
| LEG-096 | EU withdrawal-right mechanics at checkout incl. electronic withdrawal function; waivers only where valid *(feature-gated: EU B2C checkout)* |
| LEG-097 | Assess GDPR Art. 27 representative requirements and exceptions |
| LEG-098 | Per-channel opt-in, approved templates, registered sender IDs for WhatsApp/SMS *(feature-gated: messaging channels)* |
| LEG-099 | Assess seller, product, VAT route and registration before EU sales |
| LEG-100 | Assess DSA notice, decision and complaint duties for actual service |

### Search and production (SEO)

| ID | What it covers |
|---|---|
| SEO-096 | Launched on custom domain (no platform-preview URL) |
| SEO-097 | No boilerplate tab titles ("Vite + React" etc.) |
| SEO-098 | Open Graph/Twitter tags + image on every shareable page |
| SEO-099 | Exactly one `<h1>` per page; hierarchical headings; landmarks |
| SEO-100 | Canonical URLs on every indexable page |
| SEO-101 | JSON-LD structured data, validated |
| SEO-102 | sitemap.xml present, accurate, linked from robots.txt |
| SEO-103 | `<html lang>` correct (+hreflang when multi-language) |
| SEO-104 | robots.txt allows intended crawlers; blocks only deliberately |
| SEO-105 | llms.txt removed unless deliberately maintained |
| SEO-106 | View-source shows real content (SSR/prerender), curl-verified |
| SEO-107 | Zero console errors in production build |
| SEO-108 | Zero console warnings in production build |
| SEO-109 | JS bundles proportionate; no MB-scale payload on simple pages |

### Content and conversion (CRO)

| ID | What it covers |
|---|---|
| CRO-085 | Max one popup interruption per intent, frequency-capped |
| CRO-086 | Headline passes 5-second clarity test |
| CRO-087 | One clear primary CTA above the fold per page |
| CRO-089 | No equal-weight competing CTAs in same viewport |
| CRO-088 | No AI-slop images; no text baked into images |
| CRO-096 | Stock photos minimal/tasteful; real media preferred |
| CRO-090 | Speed budget: mobile perf ≥80, LCP ≤2.5s, CLS ≤0.1 |
| CRO-091 | No walls of text; scannable structure |
| CRO-092 | Copy specific, owner-approved; no generic AI filler |
| CRO-093 | Value prop explicit above the fold (desktop + mobile) |
| CRO-094 | Clear next step at every scroll depth |
| CRO-095 | Mobile-first layouts verified 320–430px |
| CRO-097 | Animations restrained, reduced-motion respected |
| CRO-098 | Video backgrounds muted/lazy/mobile-skipped |
| CRO-099 | Forms minimal; every field justified |
| CRO-100 | Pricing transparent (≤1 click); hidden pricing justified |
| CRO-101 | Real social proof near conversion points |
| CRO-102 | Zero broken links/buttons; checker runs pre-release |
| CRO-103 | Navigation lean; dead nav removed |
| CRO-104 | ➖ Consolidated into LEG-079 (storage minimization) in v2 |

### Design and usability (UIX)

| ID | What it covers |
|---|---|
| UIX-105 | Zero horizontal scroll ≥320px viewports |
| UIX-106 | Mobile menu works, focus-trapped, closes properly |
| UIX-107 | Favicon set complete (ico/PNG/apple-touch/manifest) |
| UIX-108 | Titles unique/descriptive/≤60 chars on every route |
| UIX-109 | Meta descriptions unique, 120–160 chars, every page |
| UIX-110 | Footer links resolve; footer consistent site-wide |
| UIX-111 | Custom branded 404 returning proper HTTP status |
| UIX-112 | Copyright year dynamic |
| UIX-113 | Images compressed/modern formats/lazy/sized |
| UIX-114 | Success messages on every mutating action (aria-live) |
| UIX-115 | Error messages actionable on every failure mode |
| UIX-116 | No placeholder/lorem/TODO content shipped |
| UIX-117 | Logo clickable → home, accessible name present |
| UIX-118 | Phone numbers are tel: links (international format) |
| UIX-119 | Emails are mailto: links |

### Monitoring and operations (OPS)

| ID | What it covers |
|---|---|
| OPS-120 | Uptime monitoring + tested alert delivery |
| OPS-121 | Frontend error tracking (Sentry-class), PII-scrubbed |
| OPS-122 | Search Console verified, sitemap submitted |
| OPS-123 | Conversion tracking mapped + end-to-end tested |
| OPS-124 | GA4 installed, consent-gated, internal traffic filtered |
| OPS-125 | Email capture lawful: double-opt-in, unsubscribe honored |
| OPS-126 | A/B testing hygiene if used (anti-flicker, no SEO cloaking) |
| OPS-127 | Heatmap/replay masks PII, consent-gated if used |
| OPS-128 | Sending domains enforce SPF/DKIM/DMARC (≥quarantine); transactional mail on dedicated subdomain |
| OPS-129 | Domain auto-renew/transfer-lock/secondary-contact/expiry alarm ≥30d; same alarm wired to TLS certs |

<!-- requirements:end -->

## Status

Personal governance system, actively used. Content provided as-is,
no warranty.
