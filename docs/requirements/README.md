# Requirements & Compliance Library

Single source of truth for every security, legal, SEO, performance, UX, and
operations requirement across all projects in this workspace. Written in plain
Markdown so **any** AI agent (Codex, Gemini CLI, Claude Code, Cursor,
opencode) or human can read and act on it.

**Master tracker:** [`compliance-checklist.md`](./compliance-checklist.md) —
all 152 tracked IDs covering the **142-point (v2) master checklist**, with
live status. Nothing is "done" until that file says so with evidence.

---

## File Index

| File | Scope | IDs |
|---|---|---|
| [`security-authentication.md`](./security-authentication.md) | Secrets, auth, authz, DB security, API/input hardening, web attacks, payments, rate limiting, infra config, logging, supply chain, AI safety | SEC-001 … SEC-063 (63) |
| [`mobile.md`](./mobile.md) | Mobile bundle, secure storage, deep links, biometrics, ATT | MOB-064 … MOB-068 (5) |
| [`backend-performance.md`](./backend-performance.md) | Query audits, N+1, indexing, connection lifecycle, blob hygiene, cascading deletions, third-party purges | PERF-069 … PERF-076 (8) |
| [`legal-compliance-gcc-gdpr.md`](./legal-compliance-gcc-gdpr.md) | GCC PDPL (BH/AE/SA) + GDPR: policies, cookies, data rights, deletion mechanics, minors, AI/cross-border processing, breach plan | LEG-075 … LEG-093 (19) |
| [`seo-metadata-production.md`](./seo-metadata-production.md) | Domain, metadata/OG/schema, semantic HTML, crawler files, SSR output, console hygiene, bundle budget | SEO-096 … SEO-109 (14) |
| [`conversion-content.md`](./conversion-content.md) | Landing page quality, CTAs, copy, speed, trust signals | CRO-085 … CRO-104 (20) |
| [`ui-ux-frontend.md`](./ui-ux-frontend.md) | Mobile UX, metadata, pages, messages, polish | UIX-105 … UIX-119 (15) |
| [`analytics-monitoring.md`](./analytics-monitoring.md) | Uptime, error tracking, SEO console, analytics, experiments | OPS-120 … OPS-127 (8) |
| [`tooling-costs.md`](./tooling-costs.md) | What each external dependency costs: free paths, free tiers, paid triggers | cost map for all tools referenced above |
| [`compliance-checklist.md`](./compliance-checklist.md) | Master status ledger for all of the above | All 152 |

**Automated verification:** `scripts/audit-compliance.ps1` implements every
`[AUTO]` check (secrets, injection patterns, storage misuse, headers inputs,
SEO metadata, sitemap/robots, bundle sizes…). Run it after changes:

```powershell
powershell -File scripts/audit-compliance.ps1 -Target <project-folder> [-Deep]
```

Exit code `2` = FAIL findings exist; `0` = clean (review WARNs).

**Library integrity check:** `scripts/verify-library.ps1` machine-verifies
that all 152 IDs exist exactly once, ranges are complete, the ledger is in
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
SEC   Security, Authentication & Infrastructure    001–063
MOB   Mobile App Specifics                         064–068
PERF  Backend Performance & Audits                 069–076
LEG   Legal, Compliance & Data Privacy             075–093
SEO   SEO, Metadata & Production Config            096–109
CRO   Website Conversions & Content                085–104
UIX   UI, UX & Frontend                            105–119
OPS   Analytics, Monitoring & Post-Launch          120–127
```

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
scope and marked ➖ consolidated in the ledger.

To add future requirements: append the next unused number in the correct
category file and mirror the row in the checklist. Never renumber or reuse.
Deviations need an Exceptions Register entry at the bottom of the relevant
file.

---

## Verification Legend

Every requirement row carries exactly one primary verification method:

| Tag | Meaning |
|---|---|
| `[AUTO]` | Machine-checked by `scripts/audit-compliance.ps1` or CI. Zero judgment involved. |
| `[AGENT]` | An AI agent verifies during development/review and must attach concrete evidence (file:line, test name, command output). |
| `[MANUAL]` | Human action in a cloud console, legal document, or external service. Agent can prepare but cannot attest. |

An item counts as compliant **only** when its verification method has been
executed and the evidence recorded in `compliance-checklist.md`.

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
2. Implement the change **and** satisfy every related requirement ID.
3. Run the automated audit (command above). Fix every `FAIL`; justify every
   remaining `WARN`.
4. In your summary/commit message, cite affected requirement IDs
   (e.g., `Implements SEC-028, LEG-079`).
5. Update `compliance-checklist.md`: set status and paste evidence
   (file path + line, test id, audit output snippet, screenshot reference).
   **No evidence ⇒ not done.**

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
