[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$OutputDirectory = "dist"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$cleanVersion = $Version.TrimStart("v")
$tocPath = Join-Path $repoRoot "BetterMusic.toc"
$tocVersionLine = Select-String -LiteralPath $tocPath -Pattern '^## Version: (.+)$'

if ($null -eq $tocVersionLine) {
    throw "BetterMusic.toc has no Version metadata."
}

$tocVersion = $tocVersionLine.Matches[0].Groups[1].Value.Trim()
if ($tocVersion -ne $cleanVersion) {
    throw "Requested version $cleanVersion does not match TOC version $tocVersion."
}

$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory
} else {
    Join-Path $repoRoot $OutputDirectory
}

$stageRoot = Join-Path $resolvedOutput "stage"
$addonStage = Join-Path $stageRoot "BetterMusic"
$archivePath = Join-Path $resolvedOutput "ClassicMusic-Midnight-v$cleanVersion.zip"
$releaseFiles = @(
    "BetterMusic.toc",
    "Localization.lua",
    "Data.lua",
    "Core.lua",
    "Settings.lua"
)

if (Test-Path -LiteralPath $stageRoot) {
    Remove-Item -LiteralPath $stageRoot -Recurse -Force
}
if (Test-Path -LiteralPath $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
}

New-Item -ItemType Directory -Path $addonStage -Force | Out-Null
foreach ($file in $releaseFiles) {
    $source = Join-Path $repoRoot $file
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Required release file is missing: $file"
    }
    Copy-Item -LiteralPath $source -Destination $addonStage
}

Compress-Archive -LiteralPath $addonStage -DestinationPath $archivePath
Remove-Item -LiteralPath $stageRoot -Recurse -Force
Write-Output $archivePath
