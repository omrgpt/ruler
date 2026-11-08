# Append a new review without overwriting earlier project evidence.
param(
    [Parameter(Mandatory)][string]$Target,
    [Parameter(Mandatory)][string]$RulerRoot,
    [Parameter(Mandatory)][string]$RulerVersion,
    [Parameter(Mandatory)][string]$ProjectType,
    [object[]]$Checks = @(),
    [object[]]$Findings = @()
)
$ErrorActionPreference = 'Stop'
$index = Join-Path $RulerRoot 'docs/requirements/compliance-checklist.md'
if (-not (Test-Path -LiteralPath $index)) { throw 'Requirements index missing; report not written.' }
$rules = @(Get-Content -LiteralPath $index -Encoding UTF8 | Where-Object {
    $_ -match '^\|\s*(SEC|MOB|PERF|LEG|SEO|CRO|UIX|OPS)-\d{3}\s*\|'
})
if ($rules.Count -eq 0) { throw 'Requirements index has no rows; report not written.' }
$path = Join-Path $Target 'RULER-REPORT.md'
$revision = 'unknown'
try {
    $root = & git -C $Target rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and (Resolve-Path $root).Path -eq (Resolve-Path $Target).Path) {
        $revision = & git -C $Target rev-parse HEAD 2>$null
        if ($LASTEXITCODE -ne 0) { $revision = 'unknown' }
        elseif (@(& git -C $Target status --porcelain --untracked-files=no 2>$null).Count -gt 0) {
            $revision += ' (tracked changes present)'
        }
    }
} catch { $revision = 'unknown' }
$lines = [System.Collections.Generic.List[string]]::new()
if (-not (Test-Path -LiteralPath $path)) {
    $lines.Add('# Ruler project report')
    $lines.Add('')
    $lines.Add('Project-only record. Never include secrets, personal data, or raw sensitive scan output.')
}
$lines.Add('')
$lines.Add('## Review ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'))
$lines.Add('')
$lines.Add('- Status: IN PROGRESS. Automated scan only; complete agent and manual review below.')
$lines.Add("- Ruler: $RulerVersion")
$lines.Add("- Project revision: $revision")
$lines.Add("- Scope: $ProjectType; target project only.")
$lines.Add('- Security tools, versions, and scope: Ruler static audit. Other tools: UNVERIFIED.')
$lines.Add('- Full coverage: UNVERIFIED. A passing check does not prove the whole requirement.')
$lines.Add('')
$lines.Add('### Security tool coverage')
$lines.Add('')
$lines.Add('Agent: record RUN, UNAVAILABLE, BLOCKED or N/A for each tool, with reason, version, scope, evidence and next step. Inclusion in Strix is not proof a tool ran.')
$lines.Add('')
$lines.Add('| Tool | Status | Evidence / next step |')
$lines.Add('|---|---|---|')
foreach ($tool in @('Strix','PentAGI','ZAP','Nuclei','Gitleaks','Trivy','OSV-Scanner','Opengrep','Semgrep','k6')) {
    $lines.Add(('| {0} | NOT RUN | UNVERIFIED |' -f $tool))
}
$lines.Add('')
$lines.Add('### Automated checks')
$lines.Add('')
foreach ($check in $Checks) { $lines.Add('- ' + (($check.ToString() -replace '[\r\n]+', ' ') -replace '\s+$', '')) }
$lines.Add('')
$lines.Add('### Project findings and retests')
$lines.Add('')
if ($Findings.Count -eq 0) { $lines.Add('- No automated findings. Other checks remain UNVERIFIED.') }
foreach ($finding in $Findings) {
    $location = $finding.File
    if ($finding.Line -gt 0) { $location += ':' + $finding.Line }
    $lines.Add(('- {0} {1}; {2}; IDs: {3}. Fix/retest: UNVERIFIED.' -f $finding.Severity, $finding.Check, $location, $finding.ReqIds))
}
$lines.Add('')
$lines.Add('### Ruler mistakes')
$lines.Add('')
$lines.Add('- UNVERIFIED. Review false positives, false negatives, wrong scope, skipped checks and tool errors. Record evidence and correction.')
$lines.Add('')
$lines.Add('### Every requirement')
$lines.Add('')
$lines.Add('Agent: assess every ID. State APPLIES or N/A with reason; PASS, FAIL, PARTIAL or UNVERIFIED. Record what was already present, added, changed or blocked, the test performed, evidence and next step. Do not infer full compliance from one scan.')
$lines.Add('')
$lines.Add('| ID | Applies / reason | Result / evidence |')
$lines.Add('|---|---|---|')
foreach ($rule in $rules) {
    if ($rule -match '^\|\s*((?:SEC|MOB|PERF|LEG|SEO|CRO|UIX|OPS)-\d{3})\s*\|') {
        $lines.Add(('| {0} | UNVERIFIED | UNVERIFIED |' -f $Matches[1]))
    }
}
$lines.Add('')
$lines.Add('Use Caveman skill when available. Write short, clear sentences. Keep IDs, evidence, uncertainty, dates and safety details.')
$lines.Add('After all available work and retests, replace IN PROGRESS with a truthful outcome. List release blockers, owner actions and unverified items; never claim complete coverage without evidence.')
$lines.Add('')
$text = ($lines -join "`n") + "`n"
if (Test-Path -LiteralPath $path) {
    [System.IO.File]::AppendAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
} else {
    [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($false))
}
Write-Host (" Project report: " + $path)
