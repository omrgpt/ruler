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
