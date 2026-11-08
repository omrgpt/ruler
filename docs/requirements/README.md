# Requirements & Compliance Library

Single source of truth for every security, legal, SEO, performance, UX, and
operations requirement across all projects in this workspace. Written in plain
Markdown so **any** AI agent (Codex, Gemini CLI, Claude Code, Cursor,
opencode) or human can read and act on it.

**Requirements index:** [`compliance-checklist.md`](./compliance-checklist.md) lists all 190 IDs. Each project keeps its own applicability decisions, status and evidence in its own `RULER-REPORT.md`.

---

## File Index

| File | Scope | IDs |
|---|---|---|
| [`security-authentication.md`](./security-authentication.md) | Secrets, auth, authz, DB security, API/input hardening, web attacks, payments/machine endpoints, rate limiting, infra config, logging, supply chain, AI safety, business-logic resilience, CI/CD pipeline, deployment-surface/recovery/operational security | SEC-001 … SEC-087 (87) |
| [`mobile.md`](./mobile.md) | Mobile bundle, secure storage, deep links, biometrics, ATT, store privacy labels & manifests | MOB-064 … MOB-069 (6) |
| [`backend-performance.md`](./backend-performance.md) | Query audits, N+1, indexing, connection lifecycle, blob hygiene, cascading deletions, third-party purges, migration discipline, DB-enforced constraints, job reliability, money types | PERF-069 … PERF-080 (12) |
| [`legal-compliance-gcc-gdpr.md`](./legal-compliance-gcc-gdpr.md) | GCC PDPL (BH/AE/SA) + GDPR: policies, cookies, data rights, deletion mechanics, minors, AI/cross-border processing, breach plan, retention automation, AI disclosure, EU consumer/VAT/channel duties | LEG-075 … LEG-100 (26) |
| [`seo-metadata-production.md`](./seo-metadata-production.md) | Domain, metadata/OG/schema, semantic HTML, crawler files, SSR output, console hygiene, bundle budget | SEO-096 … SEO-109 (14) |
| [`conversion-content.md`](./conversion-content.md) | Landing page quality, CTAs, copy, speed, trust signals | CRO-085 … CRO-104 (20) |
| [`ui-ux-frontend.md`](./ui-ux-frontend.md) | Mobile UX, metadata, pages, messages, polish | UIX-105 … UIX-119 (15) |
| [`analytics-monitoring.md`](./analytics-monitoring.md) | Uptime, error tracking, SEO console, analytics, experiments, email authentication, domain/cert expiry guards | OPS-120 … OPS-129 (10) |
| [`tooling-costs.md`](./tooling-costs.md) | What each external dependency costs: free paths, free tiers, paid triggers | cost map for all tools referenced above |
| [`compliance-checklist.md`](./compliance-checklist.md) | Shared requirements index for all of the above | All 190 |

**Automated verification:** `scripts/audit-compliance.ps1` implements the
static/grep layer of the `[AUTO]` tags (secrets, injection patterns, storage
misuse, crawler config, bundle/image budgets…). The remaining `[AUTO]`
verifications are runtime/DNS/live-service probes, executed as agent-run or
CI checks per each row's verification column. Targets are classified by
project type from root-level evidence: non-web repos (CLIs, libraries,
backend services) skip absence-based marketing checks (sitemap/robots/OG/
h1/title/lang/canonical) as not applicable — every security and code-quality
check always runs. Run it after changes:

```powershell
powershell -File scripts/audit-compliance.ps1 -Target <project-folder> [-Deep] [-ProjectType Web|Library]
```

Exit code `2` = FAIL findings exist; `0` = clean (review WARNs).

**Library integrity check:** `scripts/verify-library.ps1` machine-verifies
that all 190 IDs exist exactly once, ranges are complete, the ledger is in
sync with category files, changelogs are maintained, and no secrets leaked
into the docs. Run it after any edit to this library:

```powershell
powershell -File scripts/verify-library.ps1
```

---

## ID Scheme & v1→v2 History

IDs are **permanent**: they encode the original 127-point master list (v1)
position and never change, even when the master list evolves.

```
SEC   Security, Authentication & Web Vulnerabilities   001–087
MOB   Mobile App Specifics                             064–069
PERF  Backend Performance & Audits                     069–080
LEG   Legal, Compliance & Data Privacy                 075–100
SEO   SEO, Metadata & Production Config                096–109
CRO   Website Conversions & Content                    085–104
UIX   UI, UX & Frontend                                105–119
OPS   Analytics, Monitoring & Post-Launch              120–129
```

### v3 (154-point) mapping

v3 reorganized sections (IDs are permanent — nothing moved or renumbered)
and added 12 genuinely new items, which became:

| v3 item | Stable ID | Requirement |
|---|---|---|
| 5 | SEC-064 | User-facing MFA offered (TOTP), enforced for admins |
| 8 | SEC-065 | Account enumeration blocked on login/signup/reset |
| 23 | SEC-066 | Open redirects prevented |
| 36 | SEC-067 | AI output schema-validated before use |
| 37 | SEC-068 | AI agents least-privileged |
| 55 | SEC-069 | Business-logic abuse tested and blocked |
| 56 | SEC-070 | Race conditions prevented (atomic transactions/locks) |
| 57 | SEC-071 | Security checks fail closed |
| 58 | SEC-072 | Strict timeouts on external calls and queries |
| 59 | SEC-073 | CI/CD pipelines secured |
| 60 | SEC-074 | Third-party build actions audited |
| 61 | SEC-075 | Build dependencies pinned (SHAs + lockfiles) |

v3 items that were relocations of existing coverage: #67–69 → SEC-007/008/009,
#75–77 → PERF-074/075/076, #78–96 → LEG-075…093, #97 → SEC-012,
#137–144 → SEC-010/034/035/042/043/036/014/013, #145–152 → OPS-120…127.
v3 duplicates removed: #142 = #27 (SEC-036), #153 = #25 (SEC-032),
#154 = #26 (SEC-033).

### v2 (142-point) mapping

New v2 items received the next unused ID in their category:

| v2 # | Stable ID | Requirement |
|---|---|---|
| 75 | PERF-075 | Cascading deletions (files/images/rows wiped, zero orphans) |
| 76 | PERF-076 | Third-party data purge on account deletion |
| 83 | LEG-085 | Soft deletion & anonymization of retained records |
| 84 | LEG-086 | Backup retention expiry for deleted data |
| 89 | LEG-087 | Age verification gate |
| 90 | LEG-088 | Verifiable parental consent |
| 91 | LEG-089 | Default maximum-privacy settings for minors |
| 92 | LEG-090 | Zero-data-retention agreements with AI providers |
| 93 | LEG-091 | PII scrubbing middleware before external AI calls |
| 94 | LEG-092 | Cross-border transfer adequacy verification |
| 95 | LEG-093 | Explicit unbundled consent for sensitive data |
| 96–109 | SEO-096…109 | New category (domain → bundle budget), IDs match v2 numbers |

v2 also *merged* some v1 lines (e.g., "titles + meta descriptions" became one
item). The granular v1 IDs remain active and are satisfied together:
112←CRO-087+089 · 113←CRO-088+096 · 115←CRO-091+092 · 116←CRO-093+094 ·
118←CRO-097+098 · 127←UIX-108+109 · 132←UIX-114+115 · 134←UIX-117+118+119.
CRO-104 (unnecessary cookies/storage) was absorbed into LEG-079's consent
scope and marked consolidated in the requirements index.

To add future requirements: append the next unused number in the correct
category file and mirror the row in the checklist. Never renumber or reuse.
Deviations need an Exceptions Register entry at the bottom of the relevant
file.

---

## Verification Legend

Requirements can use more than one verification method:

| Tag | Meaning |
|---|---|
| `[AUTO]` | Machine-verifiable by the Ruler audit, CI, or another identified tool. Check the actual tool and output; this tag does not prove that Ruler runs the check or that the whole requirement passed. |
| `[AGENT]` | An AI agent verifies during development/review and must attach concrete evidence (file:line, test name, command output). |
| `[MANUAL]` | Human action in a cloud console, legal document, or external service. Agent can prepare but cannot attest. |

An item counts as compliant **only** when its verification method has been
executed and the evidence recorded in the relevant project's `RULER-REPORT.md`.

Audit-script conventions:
- Any source line containing the token `noqa` is skipped by static scans —
  use it only with a justification comment (e.g., `# noqa: SEC-019 allowlisted table name`).
- Severity: `FAIL` blocks release (exit 2); `WARN` requires written
  justification against its requirement ID; `INFO` is informational.

---

## Mandatory Agent Workflow

1. **Before** writing or modifying any code, read the requirement file(s) for
   the area you are touching (auth work → `security-authentication.md`; forms,
   tracking, cookies → also `legal-compliance-gcc-gdpr.md`; landing pages →
   `conversion-content.md` + `ui-ux-frontend.md` + `seo-metadata-production.md`;
   queries/APIs/deletion flows → `backend-performance.md`).
2. Implement the change and satisfy the related requirement IDs that apply.
3. Run the automated audit (command above). Fix every `FAIL`; justify every
   remaining `WARN`.
4. In your summary/commit message, cite affected requirement IDs
   (e.g., `Implements SEC-028, LEG-079`).
5. Update the project's `RULER-REPORT.md` with applicability, results, evidence,
   unverified checks, and the project and Ruler revisions. Keep project results
   out of the shared requirements index. **No evidence means not done.**

### Anti-hallucination protocol

- Agents must quote real evidence: `src/server/auth.ts:42 sets httpOnly cookie`
  beats "sessions are secure".
- Any claim of the form "we already do X" must be backed by either an `[AUTO]`
  audit pass, a test that exists in the repo, or a `file:line` citation.
- If you cannot verify a requirement, report `UNVERIFIED` — never `done`.

---

## Security Rules for This Library Itself

1. **Rules, never secrets.** These files describe policies ("hash with
   argon2id"). Real keys, passwords, tokens, and connection strings live only
   in untracked `.env` files or a secrets manager. Violations are treated as
   SEC-002/SEC-003 findings.
2. This directory ships inside the **private** repo. Do not publish it, do not
   paste its contents into public issues, prompts, or third-party tools.
3. Legal documents produced from these requirements belong to the product
   repo/site, reviewed by the owner before publishing.

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | v1: Initial import of the 127-point master checklist into 7 category files with stable IDs and verification methods. Added audit script and master tracker. |
| 2026-08-24 | v2: Expanded to the 142-point master list. Added PERF-075/076 (deletion mechanics), LEG-085–093 (soft-delete, backup expiry, minors, AI privacy, transfers, sensitive consent), new category seo-metadata-production.md (SEO-096–109). Documented v1↔v2 merge mappings; CRO-104 consolidated into LEG-079. Ledger now tracks 152 IDs across 152→142 logical checkpoints. Audit script gained SEO/config checks and a `noqa` escape hatch. |
| 2026-08-24 | v2.1: Added tooling-costs.md (free/paid map for every external dependency). Added scripts/verify-library.ps1 integrity checker — 30 structural assertions over the library itself. |
| 2026-08-24 | v3: Expanded to the 154-point master list (164 IDs). Added SEC-064…075 from Part 4 of the source series: user MFA, account enumeration, open redirects, AI output validation, AI agent least privilege, business-logic abuse, race conditions, fail-closed checks, external timeouts, CI/CD security, untrusted build actions, pinned dependencies. Documented v3 relocations and deduped 3 duplicate lines (#142, #153, #154). Audit script gained SHA-pinning check (SEC-075). |
| 2026-08-24 | v4: Expanded to 190 IDs via a sourced gap-analysis research pass (5 specialist agents; OWASP Top 10 2025 + API Top 10 + GenAI LLM Top 10 2026, NIST SP 800-63B, ICANN ERRP, PCI DSS v4.x FAQ 1588, EU AI Act Art. 50, DSA Art. 16, CJEU rulings). New IDs: SEC-076…087 (preview protection, NIST password validation, page-size caps, step-up re-auth, script integrity/SRI, env data hygiene, break-glass recovery, identity inventory, dangling-DNS audits, AI model pinning, PCI SAQ-A hygiene, DDoS/WAF posture), PERF-077…080 (migration discipline, DB-enforced constraints, job reliability/heartbeats, exact money types), LEG-094…100 (retention automation, grounded customer AI, EU withdrawal mechanics, Art. 27 representative, WhatsApp/SMS channels, VAT routing, UGC notice-and-action), OPS-128…129 (SPF/DKIM/DMARC, domain/cert expiry guards), MOB-069 (store privacy labels/manifests). Amended in place: SEC-036 (machine-endpoint auth), SEC-044 (system prompts hold no secrets / treated as extractable), SEC-054 (cert-expiry alarm + post-DNS reverify), SEC-056 (object-storage/vector-store tenant parity), SEC-068 (human gate for irreversible agent actions), LEG-075 (annual EAA exemption-basis record). Feature-gated add-ons marked *(feature-gated: …)* — universal essentials are not. |
