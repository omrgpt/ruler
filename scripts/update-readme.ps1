# Regenerate the README tracker from the master checklist.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$readme = Join-Path $root 'README.md'
$ledger = Join-Path $root 'docs/requirements/compliance-checklist.md'
$start = '<!-- requirements:start -->'
$end = '<!-- requirements:end -->'
$names = [ordered]@{
    SEC = 'Security and authentication'
    MOB = 'Mobile apps'
    PERF = 'Performance and data'
    LEG = 'Privacy and legal'
    SEO = 'Search and production'
    CRO = 'Content and conversion'
    UIX = 'Design and usability'
    OPS = 'Monitoring and operations'
}
$groups = @{}
foreach ($key in $names.Keys) { $groups[$key] = [System.Collections.Generic.List[string]]::new() }
foreach ($line in Get-Content -LiteralPath $ledger -Encoding UTF8) {
    if ($line -match '^\|\s*((SEC|MOB|PERF|LEG|SEO|CRO|UIX|OPS)-\d{3})\s*\|\s*(.*?)\s*\|\s*(☐|🔶|✅|➖|⛔)\s*\|') {
        $groups[$Matches[2]].Add("| $($Matches[1]) | $($Matches[3]) | $($Matches[4]) |")
    }
}
if (($groups.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum -eq 0) { throw 'No checklist rows found.' }
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add($start)
$lines.Add('## Requirement tracker')
$lines.Add('')
$lines.Add('Short descriptions and status marks below come from the [master checklist](docs/requirements/compliance-checklist.md), which has evidence and notes. Updates to that checklist refresh this list after changes reach the main branch.')
$lines.Add('')
$lines.Add('☐ Not started · 🔶 In progress · ✅ Evidence recorded · ⛔ Failing · ➖ Not applicable or combined')
$lines.Add('')
$lines.Add('Status marks reflect the shared checklist and its named projects; they do not establish compliance for every project. A passing automated audit covers only some requirements.')
$lines.Add('')
foreach ($key in $names.Keys) {
    if ($groups[$key].Count -eq 0) { continue }
    $lines.Add("### $($names[$key]) ($key)")
    $lines.Add('')
    $lines.Add('| ID | What it covers | Status |')
    $lines.Add('|---|---|---|')
    foreach ($row in $groups[$key]) { $lines.Add($row) }
    $lines.Add('')
}
$lines.Add($end)
$text = (Get-Content -LiteralPath $readme -Raw -Encoding UTF8) -replace "`r`n", "`n"
$pattern = '(?s)' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
if (-not [regex]::IsMatch($text, $pattern)) { throw 'README tracker markers missing.' }
$replacement = $lines -join "`n"
$updated = [regex]::Replace($text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $replacement }, 1)
if ($text -cne $updated) { [System.IO.File]::WriteAllText($readme, $updated, [System.Text.UTF8Encoding]::new($false)) }
