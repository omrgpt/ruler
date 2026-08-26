<#
.SYNOPSIS
    Wires a project to the Ruler compliance library by writing its AGENTS.md hook.

.DESCRIPTION
    Copies templates/project-AGENTS.md into <Target>\AGENTS.md with the project
    name substituted, creating a self-healing pointer to the canonical library
    at https://github.com/omrgpt/ruler. Existing AGENTS.md files are never
    overwritten unless -Force is given (a timestamped .bak is kept).

    The written hook instructs every future agent to fetch requirements from
    GitHub (or the local Documents\ruler checkout when present), so projects
    never depend on copied rule text going stale.

.PARAMETER Target
    Project folder to wire. Defaults to the current directory.

.PARAMETER Name
    Human project name embedded in the hook. Defaults to the target folder name.

.PARAMETER Force
    Overwrite an existing AGENTS.md (backup kept as AGENTS.md.bak-<timestamp>).

.EXAMPLE
    powershell -File scripts\link-project.ps1 -Target C:\code\my-app
#>
[CmdletBinding()]
param(
    [string]$Target = (Get-Location).Path,
    [string]$Name,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$template = Join-Path $repoRoot 'templates\project-AGENTS.md'

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    Write-Error "Target folder not found: $Target"
    exit 1
}
if (-not (Test-Path -LiteralPath $template)) {
    Write-Error "Template missing: $template"
    exit 1
}
$Target = (Resolve-Path -LiteralPath $Target).Path
if (-not $Name) { $Name = Split-Path -Leaf $Target }

$dest = Join-Path $Target 'AGENTS.md'
if ((Test-Path -LiteralPath $dest) -and -not $Force) {
    Write-Host " AGENTS.md already exists at $dest"
    Write-Host " Nothing changed. Re-run with -Force to replace (backup kept)."
    exit 0
}
if (Test-Path -LiteralPath $dest) {
    $bak = "$dest.bak-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
    Copy-Item -LiteralPath $dest -Destination $bak
    Write-Host " Backed up existing AGENTS.md -> $(Split-Path -Leaf $bak)"
}

$content = (Get-Content -LiteralPath $template -Raw) -replace '<PROJECT_NAME>', $Name
Set-Content -LiteralPath $dest -Encoding UTF8 -Value $content
Write-Host (" Wired {0} -> Ruler library ({1})" -f $Name, 'https://github.com/omrgpt/ruler')
Write-Host " Next: commit AGENTS.md in the project so every agent inherits it."
exit 0
