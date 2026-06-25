Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-NormalizedPath {
    param([AllowNull()][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    $cleanPath = $Path -replace '^\\\\\?\\', ''
    try {
        return [System.IO.Path]::GetFullPath($cleanPath).TrimEnd('\', '/')
    }
    catch {
        return $cleanPath.TrimEnd('\', '/')
    }
}

function Invoke-Codex {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [switch]$Json
    )

    Write-Host "> codex $($Arguments -join ' ')" -ForegroundColor DarkGray
    $output = & codex @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $text = ($output | Out-String).Trim()

    if ($exitCode -ne 0) {
        if ($text) {
            Write-Host $text
        }
        throw "codex command failed with exit code $exitCode"
    }

    if ($Json) {
        if ([string]::IsNullOrWhiteSpace($text)) {
            return $null
        }
        return $text | ConvertFrom-Json
    }

    return $text
}

function Get-RepositorySource {
    param([Parameter(Mandatory = $true)][string]$Repository)

    if ($Repository -match 'github\.com[:/]([^/]+)/([^/.]+)(?:\.git)?/?$') {
        return "$($Matches[1])/$($Matches[2])"
    }

    return $Repository
}

function Get-CodexCachePath {
    param(
        [Parameter(Mandatory = $true)][string]$MarketplaceName,
        [Parameter(Mandatory = $true)][string]$PluginName,
        [Parameter(Mandatory = $true)][string]$Version
    )

    return Join-Path $env:USERPROFILE ".codex\plugins\cache\$MarketplaceName\$PluginName\$Version"
}

function Get-CachebusterVersion {
    param([Parameter(Mandatory = $true)][string]$Version)

    $baseVersion = $Version.Split("+", 2)[0]
    $stamp = [DateTime]::UtcNow.ToString("yyyyMMddHHmmss")
    return "$baseVersion+codex.dev-$stamp"
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Text
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Install-DevelopmentLocal {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string]$PluginSelector
    )

    $codexManifestPath = Join-Path $RepoRoot ".codex-plugin\plugin.json"
    if (-not (Test-Path -LiteralPath $codexManifestPath)) {
        throw "Could not find Codex plugin manifest: $codexManifestPath"
    }

    $originalManifestText = Get-Content -LiteralPath $codexManifestPath -Raw
    try {
        $codexManifest = $originalManifestText | ConvertFrom-Json
        $codexManifest.version = Get-CachebusterVersion -Version ([string]$codexManifest.version)
        $nextManifestText = ($codexManifest | ConvertTo-Json -Depth 50) + [Environment]::NewLine
        Write-Utf8NoBom -Path $codexManifestPath -Text $nextManifestText

        Write-Host "  Cachebuster: $($codexManifest.version)"
        Invoke-Codex -Arguments @("plugin", "marketplace", "add", $RepoRoot, "--json") -Json | Out-Null
        Invoke-Codex -Arguments @("plugin", "add", $PluginSelector, "--json") -Json | Out-Null
    }
    finally {
        Write-Utf8NoBom -Path $codexManifestPath -Text $originalManifestText
    }
}

function Test-JsonProperty {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Confirm-Switch {
    param(
        [Parameter(Mandatory = $true)][string]$Prompt,
        [bool]$DefaultNo = $true
    )

    $suffix = if ($DefaultNo) { "[y/N]" } else { "[Y/n]" }
    $answer = Read-Host "$Prompt $suffix"

    if ([string]::IsNullOrWhiteSpace($answer)) {
        return -not $DefaultNo
    }

    return $answer -match '^(y|yes)$'
}

function Pause-BeforeExit {
    Write-Host ""
    Read-Host "Press Enter to exit" | Out-Null
}

function Invoke-Main {
$scriptDir = Split-Path -Parent $PSCommandPath
$repoRoot = Get-NormalizedPath (Split-Path -Parent $scriptDir)
$manifestPath = Join-Path $repoRoot "plugin.json"

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Could not find plugin.json next to repo root: $repoRoot"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$pluginName = [string]$manifest.name
$repository = [string]$manifest.repository

if ([string]::IsNullOrWhiteSpace($pluginName)) {
    throw "plugin.json must include a name."
}

if ([string]::IsNullOrWhiteSpace($repository)) {
    throw "plugin.json must include a repository URL to switch back to production."
}

$pluginSelector = "$pluginName@$pluginName"
$remoteSource = Get-RepositorySource -Repository $repository

Write-Host "Repo root: $repoRoot"
Write-Host "Plugin:   $pluginName"
Write-Host ""

$pluginList = Invoke-Codex -Arguments @("plugin", "list", "--json") -Json
$installedPlugin = @($pluginList.installed) |
    Where-Object { $_.name -eq $pluginName -or $_.pluginId -eq $pluginSelector } |
    Select-Object -First 1

$marketplaceList = Invoke-Codex -Arguments @("plugin", "marketplace", "list", "--json") -Json
$installedMarketplace = @($marketplaceList.marketplaces) |
    Where-Object { $_.name -eq $pluginName } |
    Select-Object -First 1

$installedPath = $null
$marketplacePath = $null
$installedVersion = $null

if ((Test-JsonProperty -Object $installedPlugin -Name "source") -and
    (Test-JsonProperty -Object $installedPlugin.source -Name "path")) {
    $installedPath = Get-NormalizedPath ([string]$installedPlugin.source.path)
}

if ($installedPlugin) {
    $installedVersion = [string]$installedPlugin.version
}

if ((Test-JsonProperty -Object $installedMarketplace -Name "marketplaceSource") -and
    $installedMarketplace.marketplaceSource.sourceType -eq "local") {
    $marketplacePath = Get-NormalizedPath ([string]$installedMarketplace.marketplaceSource.source)
}

$isLocalSource = ($installedPath -eq $repoRoot) -or ($marketplacePath -eq $repoRoot)
$hasCachebuster = $installedVersion -match '\+codex\.'
$isLocalDev = $isLocalSource -and $hasCachebuster
$isStaleLocalDev = $isLocalSource -and -not $hasCachebuster

if ($installedPlugin) {
    Write-Host "Current install:"
    Write-Host "  Plugin ID:   $($installedPlugin.pluginId)"
    Write-Host "  Version:     $($installedPlugin.version)"
    if ($installedVersion) {
        $cachePath = Get-CodexCachePath -MarketplaceName $installedPlugin.marketplaceName -PluginName $pluginName -Version $installedVersion
        Write-Host "  Cache path:  $cachePath"
    }
    if ($installedPath) {
        Write-Host "  Source path: $installedPath"
    }
    else {
        Write-Host "  Source path: (not local path)"
    }
}
else {
    Write-Host "Current install: not installed"
}

if ($installedMarketplace) {
    $marketplaceSource = if (Test-JsonProperty -Object $installedMarketplace -Name "marketplaceSource") {
        "$($installedMarketplace.marketplaceSource.sourceType): $($installedMarketplace.marketplaceSource.source)"
    }
    else {
        $installedMarketplace.root
    }
    Write-Host "  Marketplace: $marketplaceSource"
}

$currentMode = if ($isLocalDev) {
    "development local"
}
elseif ($isStaleLocalDev) {
    "development local (stale cache)"
}
else {
    "production remote"
}
Write-Host "  Mode:        $currentMode"

Write-Host ""

if ($isLocalDev) {
    $targetName = "production remote"
    $targetMarketplaceSource = $remoteSource
    $targetKind = "production"
}
elseif ($isStaleLocalDev) {
    $targetName = "development local refresh"
    $targetMarketplaceSource = $repoRoot
    $targetKind = "development"
}
else {
    $targetName = "development local"
    $targetMarketplaceSource = $repoRoot
    $targetKind = "development"
}

if (-not (Confirm-Switch -Prompt "Switch $pluginName to ${targetName}?")) {
    Write-Host "No changes made."
    return
}

if ($installedPlugin) {
    Invoke-Codex -Arguments @("plugin", "remove", $installedPlugin.pluginId, "--json") -Json | Out-Null
}

if ($installedMarketplace) {
    Invoke-Codex -Arguments @("plugin", "marketplace", "remove", $installedMarketplace.name, "--json") -Json | Out-Null
}

if ($targetKind -eq "development") {
    Install-DevelopmentLocal -RepoRoot $targetMarketplaceSource -PluginSelector $pluginSelector
}
else {
    Invoke-Codex -Arguments @("plugin", "marketplace", "add", $targetMarketplaceSource, "--json") -Json | Out-Null
    Invoke-Codex -Arguments @("plugin", "add", $pluginSelector, "--json") -Json | Out-Null
}

Write-Host ""
Write-Host "Switched $pluginName to $targetName." -ForegroundColor Green
Write-Host "Restart Codex or open a fresh thread before testing @pixellab-pip."
}

$exitCode = 0
try {
    Invoke-Main
}
catch {
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    $exitCode = 1
}
finally {
    Pause-BeforeExit
}

exit $exitCode
