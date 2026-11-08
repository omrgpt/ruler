# Ruler Project Hook

This file wires <PROJECT_NAME> to the Ruler compliance library. It is a
pointer, not a copy: the library lives at
**https://github.com/omrgpt/ruler** (canonical, always current). Never paste
requirement text here — link instead — so rule updates propagate everywhere
without editing every project.

## How to fetch the requirements (any agent, any machine)

With GitHub access (works from any project folder):

```bash
# one-time shallow clone of just the rulebook
gh repo clone omrgpt/ruler "$TEMP/ruler" -- --depth 1
#   -> rules live in $TEMP/ruler/docs/requirements/*.md
#   -> machine audit: powershell -File $TEMP/ruler/scripts/audit-compliance.ps1 -Target <project-folder>
# or fetch a single requirement file without cloning:
gh api repos/omrgpt/ruler/contents/docs/requirements/security-authentication.md -H "Accept: application/vnd.github.raw"
```

Local checkout (this PC): `C:\Users\PC\Documents\ruler` — use it if present;
it is kept in sync with GitHub and is faster. If both exist and disagree,
**GitHub wins**.

## Requirements & Compliance Governance (mandatory)

The master compliance checklist tracks **190 stable IDs** (v4). Agents apply only requirements relevant to each project's features, platform, and deployment; record a reason for anything not applicable.

| Area | File in `docs/requirements/` | IDs |
|---|---|---|
| Security, auth, web vulnerabilities, pipeline | security-authentication.md | SEC-001…087 |
| Mobile apps | mobile.md | MOB-064…069 |
| Backend performance & deletion mechanics | backend-performance.md | PERF-069…080 |
| Legal, GCC PDPL / GDPR, minors, AI privacy | legal-compliance-gcc-gdpr.md | LEG-075…100 |
| SEO, metadata & production config | seo-metadata-production.md | SEO-096…109 |
| Conversion & content | conversion-content.md | CRO-085…104 |
| UI, UX & frontend | ui-ux-frontend.md | UIX-105…119 |
| Analytics & monitoring | analytics-monitoring.md | OPS-120…129 |
| Tool costs & paid-plan behavior | tooling-costs.md | cost map |

### Security testing and remediation

For each project, select checks suited to its technology, features, and the
change being made. Inspect the code and run the Ruler audit; use available
secret, dependency, static-analysis and application security tools where
appropriate. Use Strix for authorized security testing when available and
suitable for the target, and other relevant tools for coverage it does not
provide. Do not assume a tool is installed or invent a successful result.
Scope active tests to authorized targets, preferably a local or test environment.

Review each finding, verify whether it affects this project, fix confirmed
issues in the project, and rerun the relevant check or reproduction to verify
the fix. Record false positives and reasons. If a check, tool, target, or fix
is unavailable or cannot be verified, record it as unverified with the reason
and next step. Do not claim a clean scan proves complete security. Record the
tool, version where available, scope, result, evidence, fix and retest in the
project's RULER-REPORT.md. Do not copy credentials, sensitive data, or raw
scanner output containing them into the report.

### Hard rules

1. **Read before you write.** Before touching code in an area, read the
   matching requirement file(s) from the library (see fetch methods above).
2. **Cite IDs.** Commits/PRs/change summaries must cite the requirement IDs
   implemented or affected (e.g., `Implements SEC-028, LEG-079`).
3. **Keep project results in the project.** Create or update `RULER-REPORT.md`
   in this project's root after each review. Use `templates/project-report.md` from Ruler as a guide.
   Record the date, project revision, exact Ruler commit SHA, scope, applicable
   IDs, results, evidence, skipped checks with reasons, and work still unverified.
   If a revision is unavailable, say `unknown`; never guess. Do not put project
   results in the Ruler repository. Never claim a requirement is satisfied
   without concrete evidence. Avoid copying secrets or personal data into reports.
   Use Strix or other available tools where relevant and authorized; record the
   tool, scope and result. Unavailable or unrun tools stay unverified.
   The audit starts an IN PROGRESS review and lists every requirement as
   UNVERIFIED. After checks, fixes and retests, complete each row: APPLIES or
   N/A with reason; PASS, FAIL, PARTIAL or UNVERIFIED with evidence and next
   step. Record project findings and Ruler mistakes (false positives, misses,
   wrong scope, skipped checks and errors). Preserve earlier reviews. Never
   label a review complete while checks remain unverified; name those checks.
   Use the Caveman skill for the report when available. If unavailable, write
   concise plain language. Never omit evidence, uncertainty or safety details.
4. **Run the audit after changes** covered by SEC/UIX/LEG items:
   `powershell -File <ruler>/scripts/audit-compliance.ps1 -Target <project-folder>`
   All FAIL findings must be fixed; remaining WARNs must be justified against
   their cited IDs. Summarize checks that passed, failed, warned, or were skipped
   in the project report; separately list manual and agent reviews not performed.
   A passing script does not mean every requirement was checked. The audit
   auto-detects web vs non-web targets; force with
   `-ProjectType Web|Library` only when auto-detection is wrong.
5. **No secrets in documentation.** Rules live in the library; credentials
   live only in gitignored `.env` files / secret managers (SEC-002, SEC-003).
6. **IDs are permanent.** To propose new requirements, append the next unused
   ID in the correct category file IN THE RULER REPO and mirror the row in
   its master checklist — never renumber or reuse. Deviations need an entry
   in the Exceptions Register of the relevant file.
