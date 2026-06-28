param(
    [ValidateSet("init", "refresh", "status", "cancel")]
    [string]$Action
)

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

function Select-MenuItem {
    param(
        [Parameter(Mandatory = $true)][object[]]$Options,
        [Parameter(Mandatory = $true)][string]$Prompt
    )

    if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected) {
        Write-Host $Prompt
        for ($i = 0; $i -lt $Options.Count; $i++) {
            Write-Host "  $($i + 1). $($Options[$i].Label)"
        }
        $answer = Read-Host "Choose 1-$($Options.Count)"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $Options[$Options.Count - 1]
        }
        if ($answer -match '^\d+$') {
            $index = [int]$answer - 1
            if ($index -ge 0 -and $index -lt $Options.Count) {
                return $Options[$index]
            }
        }
        return $Options[$Options.Count - 1]
    }

    Write-Host $Prompt
    Write-Host "Use Up/Down, Enter to select, or 1-$($Options.Count)."
    $selected = 0
    $startTop = [Console]::CursorTop

    while ($true) {
        [Console]::SetCursorPosition(0, $startTop)
        for ($i = 0; $i -lt $Options.Count; $i++) {
            $prefix = if ($i -eq $selected) { "> " } else { "  " }
            $line = "$prefix$($i + 1). $($Options[$i].Label)"
            $width = [Math]::Max(1, [Console]::WindowWidth - 1)
            if ($line.Length -gt $width) {
                $line = $line.Substring(0, $width)
            }
            else {
                $line = $line.PadRight($width)
            }

            if ($i -eq $selected) {
                Write-Host $line -ForegroundColor Black -BackgroundColor Gray
            }
            else {
                Write-Host $line
            }
        }

        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" {
                $selected = ($selected + $Options.Count - 1) % $Options.Count
            }
            "DownArrow" {
                $selected = ($selected + 1) % $Options.Count
            }
            "Enter" {
                Write-Host ""
                return $Options[$selected]
            }
            "Escape" {
                Write-Host ""
                return $Options[$Options.Count - 1]
            }
            default {
                $digit = $key.KeyChar.ToString()
                if ($digit -match '^\d$') {
                    $index = [int]$digit - 1
                    if ($index -ge 0 -and $index -lt $Options.Count) {
                        Write-Host ""
                        return $Options[$index]
                    }
                }
            }
        }
    }
}

function Pause-BeforeExit {
    if ([Console]::IsInputRedirected -or [Console]::IsOutputRedirected) {
        return
    }

    Write-Host ""
    Read-Host "Press Enter to exit" | Out-Null
}

function Get-CacheState {
    param([Parameter(Mandatory = $true)][string]$CacheRoot)

    $manifestPath = Join-Path $CacheRoot "manifest.json"
    $manifest = $null
    if (Test-Path -LiteralPath $manifestPath) {
        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    }

    [pscustomobject]@{
        CacheRoot = $CacheRoot
        ManifestPath = $manifestPath
        IsInitialized = $null -ne $manifest
        Manifest = $manifest
    }
}

function Write-CacheState {
    param([Parameter(Mandatory = $true)]$State)

    Write-Host "Cache root: $($State.CacheRoot)"
    if (-not $State.IsInitialized) {
        Write-Host "Status:     not initialized"
        return
    }

    Write-Host "Status:     initialized"
    Write-Host "Created:    $($State.Manifest.created_at)"
    Write-Host "Sources:    $($State.Manifest.source_count)"
    if ($State.Manifest.PSObject.Properties.Name -contains "last_refreshed_at") {
        Write-Host "Refreshed:  $($State.Manifest.last_refreshed_at)"
    }
    if ($State.Manifest.PSObject.Properties.Name -contains "last_change_detected") {
        Write-Host "Changed:    $($State.Manifest.last_change_detected)"
    }
    if ($State.Manifest.PSObject.Properties.Name -contains "last_refresh_had_failures") {
        Write-Host "Failures:   $($State.Manifest.last_refresh_had_failures)"
    }
    if ($State.Manifest.PSObject.Properties.Name -contains "last_report") {
        Write-Host "Report:     $($State.Manifest.last_report)"
    }
}

function Find-PythonCommand {
    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($python) {
        return "python"
    }

    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($py) {
        return "py"
    }

    throw "Could not find python or py on PATH."
}

function Invoke-DocWatch {
    param(
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $watchScript = Join-Path $RepoRoot "dev-tools\pixellab-doc-watch.py"
    if (-not (Test-Path -LiteralPath $watchScript)) {
        throw "Could not find watcher script: $watchScript"
    }

    $pythonCommand = Find-PythonCommand
    Write-Host "> $pythonCommand dev-tools/pixellab-doc-watch.py $($Arguments -join ' ')" -ForegroundColor DarkGray

    Push-Location -LiteralPath $RepoRoot
    try {
        & $pythonCommand $watchScript @Arguments
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    if ($exitCode -eq 2) {
        Write-Host ""
        Write-Host "Refresh completed and detected documentation changes." -ForegroundColor Yellow
        return
    }

    if ($exitCode -ne 0) {
        throw "pixellab-doc-watch.py failed with exit code $exitCode"
    }
}

function Invoke-Main {
    $scriptDir = Split-Path -Parent $PSCommandPath
    $repoRoot = Get-NormalizedPath (Split-Path -Parent $scriptDir)
    $cacheRoot = Join-Path $repoRoot ".local\pixellab-doc-watch"

    Write-Host "Repo root:  $repoRoot"
    Write-Host ""

    $state = Get-CacheState -CacheRoot $cacheRoot
    Write-CacheState -State $state
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($script:Action)) {
        if ($state.IsInitialized) {
            $options = @(
                [pscustomobject]@{ Action = "refresh"; Label = "Refresh and compare docs" },
                [pscustomobject]@{ Action = "status"; Label = "Show cache status" },
                [pscustomobject]@{ Action = "cancel"; Label = "Cancel" }
            )
        }
        else {
            $options = @(
                [pscustomobject]@{ Action = "init"; Label = "Initialize local docs cache" },
                [pscustomobject]@{ Action = "refresh"; Label = "Refresh and compare docs (auto-initializes)" },
                [pscustomobject]@{ Action = "cancel"; Label = "Cancel" }
            )
        }

        $selection = Select-MenuItem -Options $options -Prompt "Choose a PixelLab docs cache action:"
    }
    else {
        $selection = [pscustomobject]@{ Action = $script:Action; Label = $script:Action }
    }
    Write-Host "Selected: $($selection.Label)"
    Write-Host ""

    switch ($selection.Action) {
        "cancel" {
            Write-Host "No changes made."
            return
        }
        "init" {
            if ($state.IsInitialized) {
                Write-Host "Local PixelLab docs cache is already initialized."
                return
            }
            Invoke-DocWatch -RepoRoot $repoRoot -Arguments @("init")
            Write-Host ""
            Write-Host "Initialized local PixelLab docs cache." -ForegroundColor Green
        }
        "refresh" {
            Invoke-DocWatch -RepoRoot $repoRoot -Arguments @("refresh")
            Write-Host ""
            Write-Host "Refresh complete. Run status to see the latest report path." -ForegroundColor Green
        }
        "status" {
            Invoke-DocWatch -RepoRoot $repoRoot -Arguments @("status")
        }
        default {
            throw "Unknown action: $($selection.Action)"
        }
    }
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
