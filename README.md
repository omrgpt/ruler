# Ruler

**The ruler every AI agent measures code against.** A master compliance
list (190 stable requirement IDs as of v4, 2026-08-24) covering security, authentication,
GCC PDPL / GDPR legal compliance, SEO/production config, conversion quality,
UI/UX, and post-launch operations — plus the automation that proves it.

Built to be dropped next to your code so that **any** AI agent — Codex,
Claude Code, Gemini CLI, Cursor, opencode — reads the same rules before
writing a single line.

## What's inside

| Path | Purpose |
|---|---|
| `AGENTS.md` | Entry point every agent auto-reads: governance rules + file index |
| `docs/requirements/*.md` | The 190 requirements, each with rule text + a verification method (`[AUTO]` / `[AGENT]` / `[MANUAL]`) |
| `docs/requirements/compliance-checklist.md` | Master ledger: status + evidence per requirement |
| `docs/requirements/tooling-costs.md` | Free/paid map + what to reconfigure when you upgrade a plan |
| `scripts/audit-compliance.ps1` | 29 automated machine checks (grep/git/npm/DNS-free static layer) covering part of the `[AUTO]` items; the rest of the `[AUTO]` tags are executed as agent-run or CI probes per each row's verification column |
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

## Usage

```powershell
# audit a project against the requirements
powershell -File scripts/audit-compliance.ps1 -Target <project-folder> [-Deep]

# verify the library structure itself
powershell -File scripts/verify-library.ps1
```

Agents: read `AGENTS.md` first — it contains the mandatory workflow
(read-before-write, cite IDs, attach evidence, run the audit).

## Status

Personal governance system, actively used. Content provided as-is,
no warranty.
