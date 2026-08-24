<#
.SYNOPSIS
    Machine-verifies the integrity of the requirements library itself:
    every ID present exactly once, every range complete, ledger in sync
    with category files, changelogs maintained, v2 merge mappings intact.

.DESCRIPTION
    This is the anti-hallucination backstop for the governance system:
    an agent (or human) claiming "all 152 requirements are tracked" is
    proven right or wrong here, mechanically.

    Exit codes: 0 = verified, 1 = structural error, 2 = verification failed.
#>

[CmdletBinding()]
param(
    [string]$LibRoot = ''
)

$ErrorActionPreference = 'Stop'
$script:Fails = 0

if (-not $LibRoot) {
    $base = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
    $LibRoot = Join-Path $base '..\docs\requirements'
}

function Assert-Fact {
    param([string]$Name, [bool]$Condition, [string]$Detail = '')
    if ($Condition) {
        Write-Host (" PASS  {0}" -f $Name) -ForegroundColor Green
    } else {
        Write-Host (" FAIL  {0}  {1}" -f $Name, $Detail) -ForegroundColor Red
        $script:Fails++
    }
}

if (-not (Test-Path -LiteralPath $LibRoot -PathType Container)) {
    Write-Error "Library root not found: $LibRoot"
    exit 1
}
$LibRoot = (Resolve-Path -LiteralPath $LibRoot).Path
Write-Host ""
Write-Host " Requirements Library Integrity Verification"
Write-Host (" Library: $LibRoot")
Write-Host (" Date: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
Write-Host ""

$categoryFiles = @{
    'security-authentication.md' = @{ Prefix = 'SEC'; From = 1;  To = 75  }
    'mobile.md'                  = @{ Prefix = 'MOB'; From = 64; To = 68  }
    'backend-performance.md'     = @{ Prefix = 'PERF'; From = 69; To = 76 }
    'legal-compliance-gcc-gdpr.md' = @{ Prefix = 'LEG'; From = 75; To = 93 }
    'seo-metadata-production.md' = @{ Prefix = 'SEO'; From = 96; To = 109 }
    'conversion-content.md'      = @{ Prefix = 'CRO'; From = 85; To = 104 }
    'ui-ux-frontend.md'          = @{ Prefix = 'UIX'; From = 105; To = 119 }
    'analytics-monitoring.md'    = @{ Prefix = 'OPS'; From = 120; To = 127 }
}

$idRowRegex      = '^\|\s*(SEC|MOB|PERF|LEG|SEO|CRO|UIX|OPS)-(\d{3})\s*\|'
$expectedTotal   = 0
$allCategoryIds  = New-Object System.Collections.Generic.List[string]

foreach ($file in $categoryFiles.Keys | Sort-Object) {
    $meta = $categoryFiles[$file]
    $path = Join-Path $LibRoot $file
    $label = "{0} [{1}]" -f $file, $meta.Prefix

    if (-not (Test-Path -LiteralPath $path)) {
        Assert-Fact $label $false 'FILE MISSING'
        continue
    }

    $content  = Get-Content -LiteralPath $path -Raw
    $idsInFile = @()
    foreach ($line in (Get-Content -LiteralPath $path)) {
        if ($line -match $idRowRegex -and $Matches[1] -eq $meta.Prefix) {
            $idsInFile += [int]$Matches[2]
        }
    }

    $expectedRange = @($meta.From..$meta.To)
    $missing = @($expectedRange | Where-Object { $_ -notin $idsInFile })
    $extra   = @($idsInFile | Where-Object { $_ -notin $expectedRange })
    $dupes   = @($idsInFile | Group-Object | Where-Object Count -gt 1)

    Assert-Fact "$label range complete" ($missing.Count -eq 0 -and $extra.Count -eq 0) `
        $(if ($missing.Count) { "missing $($meta.Prefix)-$(($missing | ForEach-Object { $_.ToString('000') }) -join ',')" }
          elseif ($extra.Count) { "unexpected $($meta.Prefix)-$(($extra | ForEach-Object { $_.ToString('000') }) -join ',')" } else { '' })

    Assert-Fact "$label no duplicate IDs" ($dupes.Count -eq 0)

    Assert-Fact "$label changelog maintained" ($content -match '(?m)^##\s*Changelog')

    foreach ($i in $idsInFile) { $allCategoryIds.Add("$($meta.Prefix)-" + $i.ToString('000')) }
    $expectedTotal += $expectedRange.Count
}

# --- Ledger sync -----------------------------------------------------------
$checklistPath = Join-Path $LibRoot 'compliance-checklist.md'
if (-not (Test-Path -LiteralPath $checklistPath)) {
    Assert-Fact 'compliance-checklist.md exists' $false 'FILE MISSING'
} else {
    $ledgerIds = @()
    foreach ($line in (Get-Content -LiteralPath $checklistPath)) {
        if ($line -match $idRowRegex) { $ledgerIds += ($Matches[1] + '-' + $Matches[2]) }
    }

    $inLedgerNotCategories = @($ledgerIds | Where-Object { $_ -notin $allCategoryIds })
    $inCategoriesNotLedger = @($allCategoryIds | Where-Object { $_ -notin $ledgerIds })
    $ledgerDupes = @($ledgerIds | Group-Object | Where-Object Count -gt 1)

    Assert-Fact 'ledger covers every category ID' ($inCategoriesNotLedger.Count -eq 0) `
        $(if ($inCategoriesNotLedger.Count) { 'missing: ' + ($inCategoriesNotLedger -join ', ') } else { '' })
    Assert-Fact 'ledger has no unknown IDs' ($inLedgerNotCategories.Count -eq 0) `
        $(if ($inLedgerNotCategories.Count) { 'unknown: ' + ($inLedgerNotCategories -join ', ') } else { '' })
    Assert-Fact 'ledger has no duplicate rows' ($ledgerDupes.Count -eq 0)
}

# --- Totals ----------------------------------------------------------------
Assert-Fact "total tracked IDs = $expectedTotal (expect 164)" `
    ($expectedTotal -eq 164 -and $allCategoryIds.Count -eq 164) `
    "categories yielded $($allCategoryIds.Count)"

# --- v3 additions present ---------------------------------------------------
$v3Ids = @('SEC-064','SEC-065','SEC-066','SEC-067','SEC-068','SEC-069',
           'SEC-070','SEC-071','SEC-072','SEC-073','SEC-074','SEC-075')
$missingV3 = @($v3Ids | Where-Object { $_ -notin $allCategoryIds })
Assert-Fact 'v3 additions (SEC-064..075) present' ($missingV3.Count -eq 0) `
    $(if ($missingV3.Count) { 'missing: ' + ($missingV3 -join ', ') } else { '' })

# --- v2 merge mappings present in README -----------------------------------
$readmePath = Join-Path $LibRoot 'README.md'
$readme = Get-Content -LiteralPath $readmePath -Raw -ErrorAction SilentlyContinue
$requiredMappings = @('112', '113', '115', '116', '118', '127', '132', '134', '154')
$missingMaps = @($requiredMappings | Where-Object { $readme -notmatch [regex]::Escape($_) })
Assert-Fact 'README documents v2 merge mappings' ($missingMaps.Count -eq 0) `
    $(if ($missingMaps.Count) { 'missing markers: ' + ($missingMaps -join ', ') } else { '' })

# --- Secrets hygiene inside the library itself (SEC-002/003) ---------------
$secretHits = @()
Get-ChildItem -LiteralPath $LibRoot -Filter '*.md' -File | ForEach-Object {
    $hits = @(Select-String -LiteralPath $_.FullName -Pattern `
        'sk[-_](live|test)[-_][0-9a-zA-Z]{12,}|AKIA[0-9A-Z]{16}|ghp_[0-9a-zA-Z]{30,}|-----BEGIN [A-Z ]*PRIVATE KEY-----' `
        -ErrorAction SilentlyContinue)
    foreach ($h in $hits) {
        $secretHits += ('{0}:{1}' -f $_.Name, $h.LineNumber)
    }
}
Assert-Fact 'library contains no secret material' ($secretHits.Count -eq 0) `
    ($secretHits -join ', ')

# ---------------------------------------------------------------------------
Write-Host ""
if ($script:Fails -gt 0) {
    Write-Host (" VERIFICATION FAILED - $script:Fails problem(s).") -ForegroundColor Red
    exit 2
} else {
    Write-Host " VERIFICATION PASSED - library structure is sound." -ForegroundColor Green
    exit 0
}
