# Ruler project report

Keep this report in the project being reviewed, not in Ruler. Never include
secrets, personal data, or raw scanner output that may contain them.
Use the Caveman skill when available. Otherwise use concise, clear language.
Keep IDs, evidence, uncertainty, and safety details. Preserve earlier reviews.

## Review

- Date:
- Project and revision (or unknown):
- Ruler commit SHA (or unknown; note local changes):
- Scope and project type:
- Tools used and their scope:

## Summary

- Passed:
- Failed or warnings:
- Skipped or not applicable, with reasons:
- Still unverified, including manual and agent reviews not performed:

## Ruler mistakes

- False positives, missed issues, wrong scope, skipped checks, or errors:
- Evidence and correction, or UNVERIFIED:

## Security findings and retests

| Tool and version | Authorized scope | Finding and affected requirement | Fix or reason not applicable | Retest and evidence |
|---|---|---|---|---|

Record unavailable or unrun security tools under "Still unverified". Do not
mark a finding fixed until a relevant retest or reproducible check confirms it.

## Requirements and evidence

| Requirement ID | Applicability and reason | Result | Evidence or next step |
|---|---|---|---|

List every requirement ID. For each, state whether it applies and why; mark
PASS, FAIL, PARTIAL, or UNVERIFIED. Say whether the safeguard was already
present, added, changed, blocked, or N/A. Record the test or review performed,
evidence and next step. Only mark PASS when required checks have evidence.
Explain each N/A. The audit starts the
table with every ID unverified. Complete the review after checks and retests;
list release blockers, owner actions, and anything still unverified. A scan
cannot prove it found every mistake.
