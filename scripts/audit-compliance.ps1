<#
.SYNOPSIS
    Automated compliance auditor implementing the [AUTO] verification methods
    defined in docs/requirements/*.md.

.DESCRIPTION
    Scans a target folder for machine-detectable violations of the security,
    legal, and quality requirements tracked in docs/requirements/compliance-checklist.md.

    Exit codes:
      0 = PASS (no FAIL-severity findings; warnings may exist)
      1 = usage / environment error
      2 = FAIL (at least one FAIL-severity finding)

.PARAMETER Target
    Folder to audit. Defaults to the current directory.

.PARAMETER Deep
    Additionally runs `npm audit --omit=dev` in every project containing a
    package.json (requires node/npm on PATH). Maps to SEC-042.

.PARAMETER SkipGit
    Skips repository-level checks (.env tracking, .gitignore coverage).

.EXAMPLE
    powershell -File scripts\audit-compliance.ps1 -Target C:\code\my-site -Deep
#>

[CmdletBinding()]
param(
    [string]$Target = (Get-Location).Path,
    [switch]$Deep,
    [switch]$SkipGit,
    [switch]$IncludeToolDirs
)

$ErrorActionPreference = 'Continue'
$script:ExitCode = 0

function Resolve-Rel([string]$FullPath) {
    try {
        $t = (Resolve-Path -LiteralPath $Target).Path.TrimEnd('\')
        if ($FullPath.StartsWith($t, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $FullPath.Substring($t.Length).TrimStart('\')
        }
    } catch { }
    return $FullPath
}

function Get-Context {
    param([string]$Path, [int]$LineNumber, [int]$Radius = 2)
    try {
        $lines = Get-Content -LiteralPath $Path -ErrorAction Stop
        $start = [Math]::Max(0, $LineNumber - 1 - $Radius)
        $end   = [Math]::Min($lines.Count - 1, $LineNumber - 1 + $Radius)
        if ($end -lt $start) { return '' }
        return ($lines[$start..$end] -join ' ')
    } catch { return '' }
}

function Add-Finding {
    param(
        [string]$Check,
        [ValidateSet('FAIL', 'WARN', 'INFO')]
        [string]$Severity,
        [string]$File,
        [int]$Line,
        [string]$Text,
        [string]$ReqIds
    )
    $script:Findings += [pscustomobject]@{
        Check    = $Check
        Severity = $Severity
        File     = $File
        Line     = $Line
        Text     = ($Text -replace '\s+', ' ').Trim()
        ReqIds   = $ReqIds
    }
}

function Write-Banner([string]$Title) {
    Write-Host ""
    Write-Host ("=" * 78) -ForegroundColor DarkGray
    Write-Host " $Title" -ForegroundColor White
    Write-Host ("=" * 78) -ForegroundColor DarkGray
}

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    Write-Error "Target folder not found: $Target"
    exit 1
}
$Target = (Resolve-Path -LiteralPath $Target).Path

$script:Findings = New-Object System.Collections.Generic.List[object]
$checkResults = New-Object System.Collections.Generic.List[string]

Write-Host ""
Write-Host " Compliance Audit  |  target: $Target"
Write-Host (" Date: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))

# ---------------------------------------------------------------------------
# Collect candidate files once.
# ---------------------------------------------------------------------------
$scanExts = @(
    '.js', '.jsx', '.mjs', '.cjs', '.ts', '.tsx', '.vue', '.svelte',
    '.py', '.php', '.rb', '.go', '.java', '.kt', '.swift', '.cs',
    '.html', '.htm', '.css', '.scss', '.sass', '.less',
    '.json', '.yaml', '.yml', '.toml', '.sql', '.sh', '.ps1', '.psm1',
    '.env', '.bak', '.config', '.ini', '.cfg', '.xml', '.md', '.txt', '.log'
)
$skipDirRegex = '(\\|/)(node_modules|\.git|\.hg|\.svn|\.next|\.nuxt|\.output|dist|build|out|coverage|vendor|bower_components|__pycache__|\.venv|venv|env|\.tox|site-packages|\.turbo|\.cache|\.idea|\.vs)(\\|/)'

$allFiles = @(Get-ChildItem -LiteralPath $Target -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object {
        $n = $_.FullName
        ($n -notmatch $skipDirRegex) -and (
            $IncludeToolDirs -or
            ($n -notmatch '(^|[\\/])(\.agents|docsqueeze-repo|agentport)([\\/]|$)')
        ) -and (
            ($scanExts -contains $_.Extension.ToLowerInvariant()) -or
            ($_.Name -like '.env*')
        )
    })

Write-Host (" Files in scan scope: " + $allFiles.Count)

function Invoke-GrepCheck {
    param(
        [string]$Name,
        [string]$Pattern,
        [string]$Severity,
        [string]$ReqIds,
        [string[]]$Extensions = @(),
        [string[]]$ExcludeRegex = @(),
        [string]$SkipLineIfMatch = '',
        [int]$ContextRadius = 0,
        [string]$ContextSkipIfMatch = '',
        [System.Text.RegularExpressions.RegexOptions]$Options =
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    $files = $allFiles
    if ($Extensions.Count -gt 0) {
        $files = @($files | Where-Object { $Extensions -contains $_.Extension.ToLowerInvariant() })
    }
    if ($files.Count -eq 0) { return }

    $paths = @($files | ForEach-Object { $_.FullName })
    $matchesFound = @()
    try {
        $matchesFound = @(Select-String -LiteralPath $paths -Pattern $Pattern -AllMatches -ErrorAction SilentlyContinue)
    } catch {
        $checkResults.Add("SKIP  $Name  (scanner error: $($_.Exception.Message))")
        return
    }

    $reported = 0
    foreach ($m in $matchesFound) {
        if ($m.Line -match '(?i)\bnoqa\b') { continue }
        if ($SkipLineIfMatch -and ($m.Line -match $SkipLineIfMatch)) { continue }
        if ($ContextRadius -gt 0 -and $ContextSkipIfMatch) {
            $ctx = Get-Context -Path $m.Path -LineNumber $m.LineNumber -Radius $ContextRadius
            if ($ctx -match $ContextSkipIfMatch) { continue }
        }
        $rel = Resolve-Rel $m.Path
        $excluded = $false
        foreach ($rx in $ExcludeRegex) {
            if ($rel -match $rx) { $excluded = $true; break }
        }
        if ($excluded) { continue }
        $lineText = $m.Line
        if ($lineText.Length -gt 200) { $lineText = $lineText.Substring(0, 200) + " [...]" }
        Add-Finding -Check $Name -Severity $Severity -File $rel -Line $m.LineNumber -Text $lineText -ReqIds $ReqIds
        $reported++
        if ($reported -ge 40) {
            Add-Finding -Check $Name -Severity 'INFO' -File '-' -Line 0 `
                -Text "(output truncated at 40 findings for $Name)" -ReqIds ''
            break
        }
    }

    if ($reported -gt 0) {
        $checkResults.Add(("{0,-6} {1,-22} {2,4} finding(s)   [{3}]" -f $Severity, $Name, $reported, $ReqIds))
    } else {
        $checkResults.Add("PASS  $Name")
    }
}

# ===========================================================================
# GIT CHECKS (SEC-002, SEC-015)
# ===========================================================================
Write-Banner "Repository checks"

if (-not $SkipGit) {
    $gitDir = Join-Path $Target '.git'
    if (Test-Path -LiteralPath $gitDir) {
        $trackedEnvs = @(& git -C $Target ls-files --name-only 2>$null |
            Where-Object {
                $leaf = Split-Path $_ -Leaf
                ($leaf -like '.env*' -and $leaf -notlike '*.example' -and $leaf -notlike '*.template') -or
                ($leaf -match '(?i)^.*\.(pem|pfx|p12)$') -or
                ($_ -match '(?i)(credentials?|secrets?)\.(json|ya?ml|ini)$')
            })
        if ($trackedEnvs.Count -gt 0) {
            foreach ($te in $trackedEnvs) {
                Add-Finding -Check 'GIT-TRACKED-SECRETS' -Severity 'FAIL' -File $te -Line 0 `
                    -Text 'Secret-bearing file is tracked by git' -ReqIds 'SEC-002, SEC-015'
            }
            $checkResults.Add(("FAIL  {0,-22} {1,4} finding(s)   [SEC-002, SEC-015]" -f 'GIT-TRACKED-SECRETS', $trackedEnvs.Count))
        } else {
            $checkResults.Add("PASS  GIT-TRACKED-SECRETS")
        }

        $giPath = Join-Path $Target '.gitignore'
        $hasEnvRule = $false
        if (Test-Path -LiteralPath $giPath) {
            $giContent = (Get-Content -LiteralPath $giPath -ErrorAction SilentlyContinue) -join "`n"
            if ($giContent -match '(?m)(^|[\s,])\.env([\s,]|$)|\.env\*|^\.env$') { $hasEnvRule = $true }
        }
        if (-not $hasEnvRule) {
            Add-Finding -Check 'GITIGNORE-ENV' -Severity 'WARN' -File '.gitignore' -Line 0 `
                -Text '.gitignore has no explicit .env rule - add ".env*" before any commit' -ReqIds 'SEC-002'
            $checkResults.Add("WARN  GITIGNORE-ENV         [.gitignore lacks .env rule]")
        } else {
            $checkResults.Add("PASS  GITIGNORE-ENV")
        }
    } else {
        $checkResults.Add("SKIP  git checks             (no .git at target root)")
    }
} else {
    $checkResults.Add("SKIP  git checks             (-SkipGit)")
}

# ===========================================================================
# SOURCE CHECKS
# ===========================================================================
Write-Banner "Source code scans"

# SEC-001 / SEC-003 / SEC-016 : high-confidence third-party token formats
Invoke-GrepCheck -Name 'SECRET-TOKENS' -ReqIds 'SEC-001, SEC-003, SEC-016' -Severity 'FAIL' `
    -Pattern 'sk-(live|test)-[0-9a-zA-Z]{12,}|rk-(live|test)-[0-9a-zA-Z]{12,}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[0-9a-zA-Z]{30,}|gho_[0-9a-zA-Z]{30,}|github_pat_[0-9a-zA-Z_]{30,}|xox[bpars]-[0-9a-zA-Z-]{18,}|glpat-[0-9a-zA-Z_-]{18,}|sk-[a-f0-9]{32,}|AIza[0-9A-Za-z_-]{30,}|eyJhbGciOi[A-Za-z0-9_-]{40,}\.eyJ[A-Za-z0-9_-]{20,}\.|-----BEGIN [A-Z ]*PRIVATE KEY-----'

# SEC-001 / SEC-003 : generic secret-looking assignments (heuristic -> WARN for triage)
Invoke-GrepCheck -Name 'SECRET-ASSIGNMENT' -ReqIds 'SEC-001, SEC-003' -Severity 'WARN' `
    -Pattern '(?i)\b(password|passwd|pwd|secret|api[_-]?key|apikey|access[_-]?token|auth[_-]?token|client[_-]?secret|private[_-]?key)\b[''\"]*\s*[:=]\s*[''\"][^''\"\r\n]{8,}[''\"]' `
    -ExcludeRegex '^docs[/\\]requirements[/\\]|\.min\.|testdata|fixtures?[/\\]|[/\\]((i18n)|(locales?)|(lang)|(translations))[/\\]' `
    -SkipLineIfMatch '(?i)autocomplete'

# SEC-047 / SEC-009 : privileged backend key referenced outside server-side folders
Invoke-GrepCheck -Name 'PRIVILEGED-KEY-IN-CLIENT' -ReqIds 'SEC-009, SEC-047' -Severity 'FAIL' `
    -Pattern '(?i)(supabase[_-]?service[_-]?role|SERVICE_ROLE|service[_-]?account|FIREBASE[_-]?ADMIN|admin[_-]?sdk|master[_-]?key|root[_-]?password)' `
    -ExcludeRegex '^(server|backend|functions|api|workers?|scripts|cron|jobs|tools|migrations?|supabase)[/\\]|[/\\](server|backend|functions|api|workers?|scripts|cron|jobs|tools|migrations?|supabase)[/\\]|^docs[/\\]requirements[/\\]'

# SEC-028 : session/auth tokens in web storage
Invoke-GrepCheck -Name 'TOKEN-IN-WEB-STORAGE' -ReqIds 'SEC-028' -Severity 'FAIL' -Extensions @('.js','.jsx','.mjs','.cjs','.ts','.tsx','.vue','.svelte','.html','.htm') `
    -Pattern '(localStorage|sessionStorage)\s*\.\s*(set|get)Item\s*\(\s*[''\"][^''\"]*(token|jwt|auth|session|refresh|credential)[^''\"]*[''\"]'

# SEC-021 : raw HTML sinks
# Multi-line aware: template literals often put the esc() sanitizer on lines
# BELOW the .innerHTML sink line, so we scan an 8-line window around each hit
# for a sanitizer call before reporting. Sinks with no sanitizer nearby are
# real triage items (SEC-021).
Invoke-GrepCheck -Name 'RAW-HTML-SINK' -ReqIds 'SEC-021' -Severity 'WARN' -Extensions @('.js','.jsx','.mjs','.cjs','.ts','.tsx','.vue','.svelte','.html','.htm') `
    -Pattern 'dangerouslySetInnerHTML|\.innerHTML\s*=|document\.write(ln)?\s*\(|v-html\s*=' `
    -SkipLineIfMatch '=\s*[''\"]{2};?' `
    -ContextRadius 8 -ContextSkipIfMatch 'esc\s*\(|escHtml\s*\(|escapeHtml\s*\(|DOMPurify' `
    -ExcludeRegex '\.min\.|[/\\]assets[/\\]javascripts'

# SEC-059 : dynamic code execution
Invoke-GrepCheck -Name 'DYNAMIC-EVAL' -ReqIds 'SEC-059, SEC-017' -Severity 'FAIL' -Extensions @('.js','.jsx','.mjs','.cjs','.ts','.tsx','.vue','.svelte','.py','.php','.rb') `
    -Pattern '\beval\s*\(|new\s+Function\s*\(|\bexec\s*\(\s*f[''\"]|\bos\.system\s*\(|shell=True|child_process.*exec\s*\(\s*(`|[''\"].*\+)' `
    -ExcludeRegex '\.min\.|[/\\]assets[/\\]javascripts'

# SEC-019 : SQL built by concatenation
Invoke-GrepCheck -Name 'SQL-CONCATENATION' -ReqIds 'SEC-019' -Severity 'FAIL' -Extensions @('.js','.jsx','.mjs','.cjs','.ts','.tsx','.py','.php','.rb','.cs','.go','.java') `
    -Pattern '(?i)(select\s+.{1,80}\s+from\s|insert\s+into\s|update\s+[a-z_`."]+\s+set\s|delete\s+from\s)[^;\r\n]{0,100}?(\+\s*[a-z_$]|\$\{|%\s*s\s*[''\"])|(?i)f[''\"]\s*(select|insert|update|delete)\s'

# SEC-013 : logging secret-like variables
Invoke-GrepCheck -Name 'LOG-MAY-LEAK-SECRET' -ReqIds 'SEC-013' -Severity 'WARN' `
    -Pattern '(?i)(console\.(log|info|warn|error|debug)|logger?\.(info|warn|error|debug)|print)\s*\([^)\r\n]{0,160}\b(password|passwd|secret|api[_-]?key|token|credential|authorization)\b'

# SEC-035 : default credentials in code
Invoke-GrepCheck -Name 'DEFAULT-CREDENTIALS' -ReqIds 'SEC-035' -Severity 'WARN' `
    -Pattern '(?i)[''\"]?(admin|root|superuser|test)[''\"]?\s*[:=]\s*[''\"](admin|root|123456|12345678|password|passw0rd|letmein|qwerty|admin123|changeme)[''\"]'

# SEC-031 / SEC-054 : plaintext external URLs
Invoke-GrepCheck -Name 'PLAINTEXT-HTTP-URL' -ReqIds 'SEC-054' -Severity 'WARN' -Extensions @('.js','.jsx','.mjs','.cjs','.ts','.tsx','.vue','.svelte','.html','.htm','.css','.scss','.json','.yaml','.yml','.py','.php','.rb') `
    -Pattern 'http://(?!localhost[:/\)]|127\.0\.0\.1|0\.0\.0\.0|(www\.)?(w3\.org|schema|purl\.org|apache\.org|json-schema\.org|example\.(com|org)))' `
    -SkipLineIfMatch '^\s*(//|\*|/\*)' `
    -ExcludeRegex '^docs[/\\]requirements[/\\]|\.min\.|[/\\]assets[/\\]javascripts'

# SEC-012 : leftover debugger statements
Invoke-GrepCheck -Name 'DEBUGGER-STATEMENT' -ReqIds 'SEC-012' -Severity 'FAIL' -Extensions @('.js','.jsx','.mjs','.cjs','.ts','.tsx','.vue','.svelte') `
    -Pattern '^\s*debugger\s*;?\s*$|;\s*debugger\s*;'

# LEG-083 : pre-ticked consent/marketing checkboxes
# Flags only genuine defaults: boolean `checked` attribute (no value) or React
# defaultChecked. State-bound expressions (checked={someState}) are skipped -
# the static scan cannot know their initial value, and LEG-083 is verified at
# runtime by the agent instead.
$preTickHits = @()
$cbFiles = @($allFiles | Where-Object { @('.html','.htm','.jsx','.tsx','.js','.ts','.vue','.svelte','.php') -contains $_.Extension.ToLowerInvariant() })
if ($cbFiles.Count -gt 0) {
    try {
        $preTickHits = @(Select-String -LiteralPath @($cbFiles | ForEach-Object { $_.FullName }) `
            -Pattern '(?i)<input[^>]*\bchecked(?!\s*=)[^>]*>|defaultChecked(?!\s*=\s*\{\s*false)' -AllMatches -ErrorAction SilentlyContinue)
    } catch { $preTickHits = @() }
}
$preTickReported = 0
foreach ($hit in $preTickHits) {
    $ctxLines = Get-Content -LiteralPath $hit.Path -ErrorAction SilentlyContinue
    if ($null -eq $ctxLines) { continue }
    $start = [Math]::Max(0, $hit.LineNumber - 4)
    $end   = [Math]::Min($ctxLines.Count - 1, $hit.LineNumber + 2)
    $context = ($ctxLines[$start..$end] -join ' ')
    if ($context -match '(?i)(news(letter)?|marketing|promo|subscri|consent|offer|communit|updates|agree|tos|terms|privacy)') {
        $rel = Resolve-Rel $hit.Path
        $lt = $hit.Line; if ($lt.Length -gt 200) { $lt = $lt.Substring(0, 200) + " [...]" }
        Add-Finding -Check 'PRE-TICKED-CONSENT' -Severity 'WARN' -File $rel -Line $hit.LineNumber -Text $lt -ReqIds 'LEG-083'
        $preTickReported++
    }
}
if ($preTickReported -gt 0) {
    $checkResults.Add(("WARN  {0,-22} {1,4} finding(s)   [LEG-083]" -f 'PRE-TICKED-CONSENT', $preTickReported))
} else {
    $checkResults.Add("PASS  PRE-TICKED-CONSENT")
}

# UIX-118 / UIX-119 : phone numbers / email addresses must be tappable
$telCount  = 0
$mailCount = 0
$contactFiles = @($allFiles | Where-Object { @('.html','.htm','.jsx','.tsx','.vue','.svelte','.php') -contains $_.Extension.ToLowerInvariant() })
if ($contactFiles.Count -gt 0) {
    $paths = @($contactFiles | ForEach-Object { $_.FullName })
    $telHits   = @(Select-String -LiteralPath $paths -Pattern '\btel:[+0-9]' -AllMatches -ErrorAction SilentlyContinue)
    $mailHits  = @(Select-String -LiteralPath $paths -Pattern '\bmailto:' -AllMatches -ErrorAction SilentlyContinue)
    $barePhone = @(Select-String -LiteralPath $paths -Pattern '>(\+\d[\d\s\-()]{6,}\d)<' -AllMatches -ErrorAction SilentlyContinue)
    $bareMail  = @(Select-String -LiteralPath $paths -Pattern '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}' -AllMatches -ErrorAction SilentlyContinue)

    $telCount = $telHits.Count
    $mailCount = $mailHits.Count

    # A bare match is only a finding when the SAME LINE (and, for multi-line
    # anchors, the two lines above) has no tel:/mailto: wrapper and the line
    # is not a config key / date / comment.
    $contactFindings = @()
    foreach ($bp in $barePhone) {
        if ($bp.Line -match '(tel:|mailto:)') { continue }
        if ($bp.Line -match '\d{4}-\d{2}-\d{2}') { continue }
        $ctx = Get-Context -Path $bp.Path -LineNumber $bp.LineNumber -Radius 2
        if ($ctx -match '(href\s*=\s*[''"]tel:)') { continue }
        $contactFindings += [pscustomobject]@{ M = $bp; ReqId = 'UIX-118' }
    }
    foreach ($bm in $bareMail) {
        if ($bm.Line -match '(mailto:|tel:)') { continue }
        if ($bm.Line -match '(?i)\b(email|phone)\b\s*[:=]') { continue }
        if ($bm.Line -match '^\s*(//|\*|/\*)') { continue }
        $ctx = Get-Context -Path $bm.Path -LineNumber $bm.LineNumber -Radius 2
        if ($ctx -match '(href\s*=\s*[''"]mailto:)') { continue }
        $contactFindings += [pscustomobject]@{ M = $bm; ReqId = 'UIX-119' }
    }

    if ($contactFindings.Count -gt 0) {
        foreach ($cf in ($contactFindings | Select-Object -First 40)) {
            $rel = Resolve-Rel $cf.M.Path
            $lt = $cf.M.Line; if ($lt.Length -gt 160) { $lt = $lt.Substring(0, 160) + " [...]" }
            Add-Finding -Check 'CONTACT-NOT-CLICKABLE' -Severity 'WARN' -File $rel -Line $cf.M.LineNumber -Text $lt -ReqIds $cf.ReqId
        }
        $checkResults.Add(("WARN  {0,-22} {1,4} finding(s)   [{2}]" -f 'CONTACT-NOT-CLICKABLE', $contactFindings.Count, 'UIX-118, UIX-119'))
    } else {
        $checkResults.Add("PASS  CONTACT-NOT-CLICKABLE  (tel: links: $telCount, mailto: links: $mailCount)")
    }
}

# UIX-116 : placeholder/stub content shipped
Invoke-GrepCheck -Name 'PLACEHOLDER-CONTENT' -ReqIds 'UIX-116' -Severity 'WARN' -Extensions @('.js','.jsx','.mjs','.cjs','.ts','.tsx','.vue','.svelte','.html','.htm','.mdx') `
    -Pattern '(?i)(lorem ipsum|placeholder text goes here|TODO:?\s*(fix|implement|remove before launch)|FIXME|XXX:\s*remove)' `
    -ExcludeRegex '(^|[/\\])(tests?|__tests__|fixtures?|mocks?|spec)[/\\]|\.test\.|\.spec\.|node_modules|^docs[/\\]requirements[/\\]'

# ===========================================================================
# SEO, METADATA & PRODUCTION CONFIG CHECKS (SEO-096..109)
# ===========================================================================
Write-Banner "SEO & production config scans"

$htmlFiles = @($allFiles | Where-Object { @('.html', '.htm') -contains $_.Extension.ToLowerInvariant() })

# SEO-097 : default boilerplate titles
Invoke-GrepCheck -Name 'BOILERPLATE-TITLE' -ReqIds 'SEO-097' -Severity 'WARN' -Extensions @('.html', '.htm') `
    -Pattern '(?i)<title>\s*(vite\s*\+\s*react|create next app|react app|my react app|next\.js app|webpack app)\s*</title>'

# SEO-103 : <html lang=""> attribute present
$langMissing = 0
foreach ($hf in $htmlFiles) {
    $content = Get-Content -LiteralPath $hf.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }
    if ($content -match '<html[\s>]' -and $content -notmatch '<html[^>]*\blang\s*=') {
        Add-Finding -Check 'HTML-LANG-MISSING' -Severity 'WARN' -File (Resolve-Rel $hf.FullName) -Line 0 `
            -Text '<html> tag has no lang attribute' -ReqIds 'SEO-103'
        $langMissing++
    }
}
if ($langMissing -gt 0) {
    $checkResults.Add(("WARN  {0,-22} {1,4} file(s)      [SEO-103]" -f 'HTML-LANG-MISSING', $langMissing))
} else {
    $checkResults.Add("PASS  HTML-LANG-MISSING")
}

# SEO-099 : exactly one <h1> per page
$h1Issues = 0
foreach ($hf in $htmlFiles) {
    $h1Matches = @(Select-String -LiteralPath $hf.FullName -Pattern '<h1[\s>]' -AllMatches -ErrorAction SilentlyContinue)
    $count = 0
    foreach ($hm in $h1Matches) { $count += $hm.Matches.Count }
    if ($count -ne 1) {
        $reason = if ($count -eq 0) { 'no <h1> found' } else { "$count <h1> elements" }
        Add-Finding -Check 'H1-COUNT' -Severity 'WARN' -File (Resolve-Rel $hf.FullName) -Line 0 `
            -Text "page should contain exactly one h1 ($reason)" -ReqIds 'SEO-099'
        $h1Issues++
    }
}
if ($h1Issues -gt 0) {
    $checkResults.Add(("WARN  {0,-22} {1,4} page(s)     [SEO-099]" -f 'H1-COUNT', $h1Issues))
} else {
    $checkResults.Add("PASS  H1-COUNT")
}

# SEO-098 / SEO-100 / SEO-101 : site-wide presence of OG tags, canonical, structured data
if ($htmlFiles.Count -gt 0) {
    $htmlPaths = @($htmlFiles | ForEach-Object { $_.FullName })
    $ogHits    = @(Select-String -LiteralPath $htmlPaths -Pattern 'og:(title|image|description)["'']?\s*=' -AllMatches -ErrorAction SilentlyContinue)
    $canonHits = @(Select-String -LiteralPath $htmlPaths -Pattern 'rel\s*=\s*[''\"]canonical' -AllMatches -ErrorAction SilentlyContinue)
    $ldHits    = @(Select-String -LiteralPath $htmlPaths -Pattern 'application/ld\+json' -AllMatches -ErrorAction SilentlyContinue)

    if ($ogHits.Count -eq 0) {
        Add-Finding -Check 'NO-OG-TAGS' -Severity 'WARN' -File '(site-wide)' -Line 0 `
            -Text 'no Open Graph tags found in any static HTML - social link previews will be bare' -ReqIds 'SEO-098'
        $checkResults.Add("WARN  NO-OG-TAGS             [SEO-098]")
    } else {
        $checkResults.Add(("PASS  NO-OG-TAGS             ({0} og: tag lines)" -f $ogHits.Count))
    }

    if ($canonHits.Count -eq 0) {
        Add-Finding -Check 'NO-CANONICAL' -Severity 'WARN' -File '(site-wide)' -Line 0 `
            -Text 'no rel=canonical links found in any static HTML (framework-injected canonicals are verified by the agent instead)' -ReqIds 'SEO-100'
        $checkResults.Add("WARN  NO-CANONICAL           [SEO-100]")
    } else {
        $checkResults.Add(("PASS  NO-CANONICAL           ({0} canonical links)" -f $canonHits.Count))
    }

    if ($ldHits.Count -eq 0) {
        Add-Finding -Check 'NO-SCHEMA-MARKUP' -Severity 'INFO' -File '(site-wide)' -Line 0 `
            -Text 'no JSON-LD structured data found in static HTML' -ReqIds 'SEO-101'
        $checkResults.Add("INFO  NO-SCHEMA-MARKUP       [SEO-101]")
    } else {
        $checkResults.Add(("PASS  NO-SCHEMA-MARKUP       ({0} ld+json blocks)" -f $ldHits.Count))
    }
}

# SEO-102 / SEO-104 / SEO-105 : sitemap.xml, robots.txt, llms.txt presence/content
$servedRoots = @($Target, (Join-Path $Target 'public'), (Join-Path $Target 'static'), (Join-Path $Target 'dist'), (Join-Path $Target 'out')) |
    Where-Object { Test-Path -LiteralPath $_ -PathType Container }

$sitemap = $null
foreach ($root in $servedRoots) {
    $candidate = Join-Path $root 'sitemap.xml'
    if (Test-Path -LiteralPath $candidate) { $sitemap = $candidate; break }
}
if ($null -eq $sitemap) {
    Add-Finding -Check 'NO-SITEMAP' -Severity 'WARN' -File '(site-wide)' -Line 0 `
        -Text 'no sitemap.xml found in root/public/static/dist/out' -ReqIds 'SEO-102'
    $checkResults.Add("WARN  NO-SITEMAP             [SEO-102]")
} else {
    $checkResults.Add(("PASS  NO-SITEMAP             ({0})" -f (Resolve-Rel $sitemap)))
}

$robots = $null
foreach ($root in $servedRoots) {
    $candidate = Join-Path $root 'robots.txt'
    if (Test-Path -LiteralPath $candidate) { $robots = $candidate; break }
}
if ($null -eq $robots) {
    Add-Finding -Check 'ROBOTS-TXT' -Severity 'WARN' -File '(site-wide)' -Line 0 `
        -Text 'no robots.txt found - create one that allows the crawlers you want' -ReqIds 'SEO-104'
    $checkResults.Add("WARN  ROBOTS-TXT             (missing)")
} else {
    $robotsContent = (Get-Content -LiteralPath $robots -Raw -ErrorAction SilentlyContinue)
    if ($robotsContent -match '(?im)^\s*user-agent:\s*\*\s*$[\s\S]{0,120}?^\s*disallow:\s*/\s*$') {
        Add-Finding -Check 'ROBOTS-TXT' -Severity 'WARN' -File (Resolve-Rel $robots) -Line 0 `
            -Text 'robots.txt disallows ALL crawlers site-wide - intentional only for staging; fix before launch' -ReqIds 'SEO-104'
        $checkResults.Add("WARN  ROBOTS-TXT             (blocks all crawlers)")
    } else {
        $checkResults.Add(("PASS  ROBOTS-TXT             ({0})" -f (Resolve-Rel $robots)))
    }
}

$llmsTxt = $null
foreach ($root in $servedRoots) {
    $candidate = Join-Path $root 'llms.txt'
    if (Test-Path -LiteralPath $candidate) { $llmsTxt = $candidate; break }
}
if ($null -ne $llmsTxt) {
    Add-Finding -Check 'LLMS-TXT-PRESENT' -Severity 'INFO' -File (Resolve-Rel $llmsTxt) -Line 0 `
        -Text 'llms.txt exists - keep only if deliberately maintained for AI crawlers, otherwise remove' -ReqIds 'SEO-105'
    $checkResults.Add("INFO  LLMS-TXT-PRESENT       [SEO-105]")
} else {
    $checkResults.Add("PASS  LLMS-TXT-PRESENT       (none)")
}

# SEO-109 : oversized JS/CSS bundles in served directories
$bundleExts = @('.js', '.mjs', '.css')
$bundles = @(Get-ChildItem -LiteralPath $Target -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object {
        ($bundleExts -contains $_.Extension.ToLowerInvariant()) -and
        ($_.FullName -notmatch $skipDirRegex) -and
        ($_.FullName -match '(\\|/)(public|static|dist|build|out)(\\|/)') -and
        ($_.Length -gt 500KB)
    })
if ($bundles.Count -gt 0) {
    foreach ($b in ($bundles | Sort-Object Length -Descending)) {
        Add-Finding -Check 'BUNDLE-SIZE' -Severity 'WARN' -File (Resolve-Rel $b.FullName) -Line 0 `
            -Text ("asset is {0:N1} KB - audit code-splitting/tree-shaking/compression" -f ($b.Length / 1KB)) -ReqIds 'SEO-109'
    }
    $checkResults.Add(("WARN  {0,-22} {1,4} asset(s)    [SEO-109]" -f 'BUNDLE-SIZE', $bundles.Count))
} else {
    $checkResults.Add("PASS  BUNDLE-SIZE            (no served asset > 500 KB)")
}

# SEC-075 : unpinned GitHub Actions (mutable tags allow supply-chain injection)
$workflowFiles = @(Get-ChildItem -LiteralPath $Target -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object {
        ($_.FullName -notmatch $skipDirRegex) -and
        ($_.FullName -match '[/\\]\.github[/\\]workflows[/\\]') -and
        (@('.yml', '.yaml') -contains $_.Extension.ToLowerInvariant())
    })
if ($workflowFiles.Count -gt 0) {
    $unpinned = @(Select-String -LiteralPath @($workflowFiles | ForEach-Object { $_.FullName }) `
        -Pattern '^\s*-?\s*uses:\s*\S+@(?!.*[a-f0-9]{40})\S+' -AllMatches -ErrorAction SilentlyContinue)
    if ($unpinned.Count -gt 0) {
        foreach ($u in ($unpinned | Select-Object -First 30)) {
            $rel = Resolve-Rel $u.Path
            $lt = $u.Line; if ($lt.Length -gt 160) { $lt = $lt.Substring(0, 160) + " [...]" }
            Add-Finding -Check 'UNPINNED-ACTION' -Severity 'WARN' -File $rel -Line $u.LineNumber -Text $lt -ReqIds 'SEC-075'
        }
        $checkResults.Add(("WARN  {0,-22} {1,4} finding(s)   [SEC-075]" -f 'UNPINNED-ACTION', $unpinned.Count))
    } else {
        $checkResults.Add("PASS  UNPINNED-ACTION")
    }
} else {
    $checkResults.Add("INFO  UNPINNED-ACTION       (no workflows found)")
}

# ===========================================================================
# BUILD ARTIFACT CHECKS (SEC-041)
# ===========================================================================
Write-Banner "Build artifact checks"

$sourcemapDirs = '(\\|/)(public|static|dist|build|out|export)(\\|/)'
$sourcemaps = @(Get-ChildItem -LiteralPath $Target -Recurse -File -Filter '*.map' -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch $skipDirRegex -and $_.FullName -match $sourcemapDirs })
if ($sourcemaps.Count -gt 0) {
    foreach ($sm in $sourcemaps) {
        Add-Finding -Check 'PUBLIC-SOURCEMAPS' -Severity 'WARN' -File (Resolve-Rel $sm.FullName) -Line 0 `
            -Text 'source map present in publicly served directory' -ReqIds 'SEC-041'
    }
    $checkResults.Add(("WARN  {0,-22} {1,4} finding(s)   [SEC-041]" -f 'PUBLIC-SOURCEMAPS', $sourcemaps.Count))
} else {
    $checkResults.Add("PASS  PUBLIC-SOURCEMAPS")
}

# env files physically present anywhere under target (even untracked) -> info for review
$dotenvFiles = @($allFiles | Where-Object { $_.Name -like '.env*' -and $_.Name -notlike '*.example' -and $_.Name -notlike '*.template' })
if ($dotenvFiles.Count -gt 0) {
    foreach ($df in $dotenvFiles) {
        Add-Finding -Check 'ENV-FILE-PRESENT' -Severity 'INFO' -File (Resolve-Rel $df.FullName) -Line 0 `
            -Text 'local .env file exists (fine if gitignored and values are prod-safe); verify it is not deployed with static hosting' -ReqIds 'SEC-002, SEC-034'
    }
    $checkResults.Add(("INFO  {0,-22} {1,4} file(s)      [SEC-002]" -f 'ENV-FILE-PRESENT', $dotenvFiles.Count))
} else {
    $checkResults.Add("INFO  ENV-FILE-PRESENT       (none found)")
}

# ===========================================================================
# DEEP MODE : dependency vulnerabilities (SEC-042)
# ===========================================================================
Write-Banner "Dependency vulnerability scan (-Deep)"

if ($Deep) {
    $npmAvailable = $false
    try { $null = & npm --version 2>$null; if ($LASTEXITCODE -eq 0) { $npmAvailable = $true } } catch { }
    if (-not $npmAvailable) {
        $checkResults.Add("SKIP  NPM-AUDIT              (npm not on PATH)")
    } else {
        $pkgFiles = @(Get-ChildItem -LiteralPath $Target -Recurse -File -Filter 'package.json' -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch $skipDirRegex })
        $auditedProjects = 0
        foreach ($pf in $pkgFiles) {
            $projDir = Split-Path $pf.FullName -Parent
            $relProj = Resolve-Rel $projDir
            $auditJson = $null
            try {
                $raw = & cmd /c "cd /d `"$projDir`" && npm audit --omit=dev --json 2>nul"
                $joined = ($raw -join "`n")
                if ($joined -match '^\s*\{') { $auditJson = $joined | ConvertFrom-Json }
            } catch { }
            if ($null -ne $auditJson -and $null -ne $auditJson.metadata.vulnerabilities) {
                $auditedProjects++
                $crit = [int]$auditJson.metadata.vulnerabilities.critical
                $high = [int]$auditJson.metadata.vulnerabilities.high
                $moderate = [int]$auditJson.metadata.vulnerabilities.moderate
                $low = [int]$auditJson.metadata.vulnerabilities.low
                if ($crit -gt 0) {
                    Add-Finding -Check 'NPM-AUDIT' -Severity 'FAIL' -File $relProj -Line 0 `
                        -Text "$crit critical production vulnerabilities (run npm audit for details)" -ReqIds 'SEC-042'
                    $checkResults.Add(("FAIL  {0,-22} crit={1} high={2} mod={3} low={4}   [{5}] ({6})" -f 'NPM-AUDIT', $crit, $high, $moderate, $low, 'SEC-042', $relProj))
                } elseif ($high -gt 0) {
                    Add-Finding -Check 'NPM-AUDIT' -Severity 'WARN' -File $relProj -Line 0 `
                        -Text "$high high production vulnerabilities" -ReqIds 'SEC-042'
                    $checkResults.Add(("WARN  {0,-22} crit={1} high={2} mod={3} low={4}   [{5}] ({6})" -f 'NPM-AUDIT', $crit, $high, $moderate, $low, 'SEC-042', $relProj))
                } else {
                    $checkResults.Add(("PASS  NPM-AUDIT              ({0})" -f $relProj) + ("  mod={0} low={1}" -f $moderate, $low))
                }
            }
        }
        if ($auditedProjects -eq 0 -and $pkgFiles.Count -gt 0) {
            $checkResults.Add("SKIP  NPM-AUDIT              (package.json found but audits returned no data)")
        }
    }
} else {
    $checkResults.Add("SKIP  NPM-AUDIT              (use -Deep to enable; SEC-042)")
}

# ===========================================================================
# SUMMARY
# ===========================================================================
Write-Banner "Per-check results"
foreach ($line in $checkResults) {
    $color = 'Gray'
    if ($line -like 'FAIL*') { $color = 'Red' }
    elseif ($line -like 'WARN*') { $color = 'Yellow' }
    elseif ($line -like 'PASS*') { $color = 'Green' }
    Write-Host (" " + $line) -ForegroundColor $color
}

$failCount = @($Findings | Where-Object { $_.Severity -eq 'FAIL' }).Count
$warnCount = @($Findings | Where-Object { $_.Severity -eq 'WARN' }).Count
$infoCount = @($Findings | Where-Object { $_.Severity -eq 'INFO' }).Count

Write-Banner ("Findings detail  (FAIL: $failCount  WARN: $warnCount  INFO: $infoCount)")
if ($Findings.Count -eq 0) {
    Write-Host " (none)" -ForegroundColor Green
} else {
    foreach ($f in ($Findings | Sort-Object -Property @{Expression={
        switch ($_.Severity) { 'FAIL' { 0 } 'WARN' { 1 } default { 2 } } }})) {
        $color = switch ($f.Severity) { 'FAIL' { 'Red' } 'WARN' { 'Yellow' } default { 'DarkGray' } }
        $loc = if ($f.File -eq '-') { '' } elseif ($f.Line -gt 0) { "{0}:{1}: " -f $f.File, $f.Line } else { "{0}: " -f $f.File }
        Write-Host (" [{0}] {1,-22} {2}" -f $f.Severity, $f.Check, $loc) -ForegroundColor $color -NoNewline
        Write-Host $f.Text -ForegroundColor $color
        if ($f.ReqIds) { Write-Host ("        requirement(s): " + $f.ReqIds) -ForegroundColor Cyan }
    }
}

Write-Banner "Result"
if ($failCount -gt 0) {
    Write-Host (" AUDIT FAILED - $failCount FAIL finding(s). Fix before release.") -ForegroundColor Red
    $script:ExitCode = 2
} else {
    Write-Host " AUDIT PASSED (no FAIL findings). Review WARN items against their requirement IDs." -ForegroundColor Green
}
Write-Host (" Next steps: record evidence in docs/requirements/compliance-checklist.md") -ForegroundColor DarkCyan

exit $script:ExitCode
