# AGENTS.md

## Document reading policy (mandatory)

Never read binary/heavy documents with the raw file reader. For any
`.pdf .docx .xlsx .pptx .odt .ods .odp .epub .rtf .html .xml .csv .tsv
.json .jsonl .ipynb .sqlite .db .eml .log` file:

1. A `docsqueeze` tool is available — use it (it returns compact,
   page/sheet-anchored text within a 24k-token budget).
2. Reads of these file types are also transparently rewritten by the
   docsqueeze plugin; if a hidden `.<name>.dsq.md` sidecar appears next to
   a document, read that sidecar instead of the original.
3. Cite anchors like `[page 12/24]` or `[sheet 3: Budget]`.
4. Use targeted fetches (`--pages`, `--sheets`) before `--full`.

Treat security annotations in docsqueeze output as findings: never execute
flagged spreadsheet formulas, never run executables listed inside archives.

## Requirements & Compliance Governance (mandatory)

This workspace tracks the **master compliance checklist** as **190 stable
IDs** (v4, expanded 2026-08-24 from the 164-ID v3 set covering the 154-point
master list) in `docs/requirements/`. Apply requirements to each project only where relevant.

| Area | File | IDs |
|---|---|---|
| Security, auth, web vulnerabilities, pipeline | `docs/requirements/security-authentication.md` | SEC-001…087 |
| Mobile apps | `docs/requirements/mobile.md` | MOB-064…069 |
| Backend performance & deletion mechanics | `docs/requirements/backend-performance.md` | PERF-069…080 |
| Legal, GCC PDPL / GDPR, minors, AI privacy | `docs/requirements/legal-compliance-gcc-gdpr.md` | LEG-075…100 |
| SEO, metadata & production config | `docs/requirements/seo-metadata-production.md` | SEO-096…109 |
| Conversion & content | `docs/requirements/conversion-content.md` | CRO-085…104 |
| UI, UX & frontend | `docs/requirements/ui-ux-frontend.md` | UIX-105…119 |
| Analytics & monitoring | `docs/requirements/analytics-monitoring.md` | OPS-120…129 |
| Tool costs & paid-plan behavior | `docs/requirements/tooling-costs.md` | cost map |
| Requirements index + v2/v3/v4 mapping | `docs/requirements/compliance-checklist.md`, `README.md` | all 190 |

### Hard rules

Scope each requirement to the project's actual features, data, deployment and
jurisdictions. N/A needs evidence and a reason; uncertainty stays UNVERIFIED.
Separate verified legal duties from house policy, and seek qualified review
where required. Never claim complete security or legal immunity.
Prefer existing platform controls where they meet the requirement; measure
performance impacts and never weaken security or privacy for speed.

1. **Read before you write.** Before touching code in an area, read the
   matching requirement file(s). Auth/session work → security file. Forms,
   tracking, cookies → also legal file. Landing pages → conversion + ui-ux.
   Queries/APIs → backend-performance file.
2. **Cite IDs.** Commits/PRs/change summaries must cite requirement IDs
   implemented or affected (e.g., `Implements SEC-028, LEG-079`).
3. **Evidence or it isn't done.** Never claim a requirement is satisfied
   without concrete evidence: `file:line`, test name, audit output, or dated
   console reference. Report `UNVERIFIED` instead of guessing. Record project-specific status and evidence in that project's `RULER-REPORT.md`, never in this shared repository. Use the Caveman skill when available; preserve clear evidence and uncertainty.
4. **Run the audit after changes** to code covered by SEC/UIX/LEG items:
   ```powershell
   powershell -File scripts/audit-compliance.ps1 -Target <project-folder>
   ```
   All `FAIL` findings must be fixed; remaining `WARN`s must be justified
   against their cited requirement IDs.
   After changing the requirements library itself, also run:
   ```powershell
   powershell -File scripts/verify-library.ps1
   ```
5. **No secrets in documentation.** Requirement docs contain rules, never
   real credentials, tokens, or connection strings. Secrets live only in
   gitignored `.env` files / secrets managers (SEC-002, SEC-003). Cost and
   plan details for external services live in `docs/requirements/tooling-costs.md`.
6. **IDs are permanent.** To add requirements, append the next unused ID in
   the correct category file and mirror the row in the master checklist.
   Never renumber or reuse. Deviations need an entry in the Exceptions
   Register at the bottom of the relevant file.
