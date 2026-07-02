param(
    [ValidateSet("status", "ensure-baseline", "write-temp", "restore", "restore-after")]
    [string]$Mode = "status",
    [string]$ConfigPath = (Join-Path $env:USERPROFILE ".codex\config.toml"),
    [string]$PromptPath,
    [string]$SpecPath,
    [int]$DelaySeconds = 180
)

$ErrorActionPreference = "Stop"
$ExpectedPromptFileName = "compact-better.md"
$StateFileName = "compact-better.state.json"
$Utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Read-Utf8 {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path, $Utf8Strict)
}

function Write-Utf8 {
    param(
        [string]$Path,
        [string]$Text
    )
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Get-InlinePromptMatch {
    param([string]$ConfigText)
    $pattern = '(?ms)(?<prefix>^\s*compact_prompt\s*=\s*"""\r?\n)(?<body>.*?)(?<suffix>\r?\n"""\s*(?:\r?\n|$))'
    return [regex]::Match($ConfigText, $pattern)
}

function Resolve-PromptPath {
    param([string]$RawPath)
    if ([System.IO.Path]::IsPathRooted($RawPath)) {
        return [System.IO.Path]::GetFullPath($RawPath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $ConfigPath) $RawPath))
}

function Get-PromptSurface {
    if (!(Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        throw "Config not found: $ConfigPath"
    }

    $configText = Read-Utf8 -Path $ConfigPath
    $inlineMatch = Get-InlinePromptMatch -ConfigText $configText
    if ($inlineMatch.Success -and ![string]::IsNullOrWhiteSpace($inlineMatch.Groups["body"].Value)) {
        throw "Inline compact_prompt is still active in config.toml. Export it to an archive file and remove the inline block; otherwise Codex ignores compact-better.md."
    }

    $filePattern = '(?m)^\s*experimental_compact_prompt_file\s*=\s*[''"]([^''"]+)[''"]\s*$'
    $fileMatch = [regex]::Match($configText, $filePattern)
    if (!$fileMatch.Success) {
        throw "Missing experimental_compact_prompt_file in config.toml. compact-better controls only the file-backed prompt."
    }

    $promptPath = Resolve-PromptPath -RawPath $fileMatch.Groups[1].Value
    if ([System.IO.Path]::GetFileName($promptPath) -ne $ExpectedPromptFileName) {
        throw "compact-better expected prompt file '$ExpectedPromptFileName' but config points to: $promptPath"
    }
    if (!(Test-Path -LiteralPath $promptPath -PathType Leaf)) {
        throw "Prompt file not found: $promptPath"
    }

    return [pscustomobject]@{
        surfaceType = "file"
        targetPath = $promptPath
        configPath = $ConfigPath
        promptText = Read-Utf8 -Path $promptPath
    }
}

function Get-BaselinePath {
    param([object]$Surface)
    return (Join-Path (Split-Path -Parent $Surface.targetPath) "compact-better.baseline.md")
}

function Get-StatePath {
    param([object]$Surface)
    return (Join-Path (Split-Path -Parent $Surface.targetPath) $StateFileName)
}

function Get-TimestampBackupPath {
    param([object]$Surface)
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    return (Join-Path (Split-Path -Parent $Surface.targetPath) "compact-better.backup-$stamp.md")
}

function Get-FileHashSha256 {
    param([string]$Path)
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Normalize-PromptText {
    param([string]$Text)
    return ($Text -replace "`r`n", "`n").TrimEnd()
}

function Read-StateFile {
    param([string]$Path)
    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    try {
        return (Read-Utf8 -Path $Path | ConvertFrom-Json)
    } catch {
        throw "State file is not valid JSON: $Path"
    }
}

function Remove-StateFile {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        Remove-Item -LiteralPath $Path -Force
    }
}

function Write-StateFile {
    param(
        [string]$Path,
        [object]$State
    )
    Write-Utf8 -Path $Path -Text (($State | ConvertTo-Json -Depth 6) + "`r`n")
}

function Set-PromptText {
    param(
        [object]$Surface,
        [string]$PromptText
    )
    Write-Utf8 -Path $Surface.targetPath -Text ($PromptText.TrimEnd() + "`r`n")
}

function Get-State {
    $surface = Get-PromptSurface
    $baseline = Get-BaselinePath -Surface $surface
    $statePath = Get-StatePath -Surface $surface
    $promptText = $surface.promptText
    $targetHash = Get-FileHashSha256 -Path $surface.targetPath
    $baselineHash = Get-FileHashSha256 -Path $baseline
    $hasBaseline = Test-Path -LiteralPath $baseline -PathType Leaf
    $matchesBaseline = $hasBaseline -and ($targetHash -eq $baselineHash)
    $stateFile = Read-StateFile -Path $statePath
    $hasState = $null -ne $stateFile
    $stateTempHash = if ($hasState) { $stateFile.tempHash } else { $null }
    $stateMatchesTarget = $hasState -and ($stateTempHash -eq $targetHash)
    $promptState = if ($matchesBaseline) {
        "baseline"
    } elseif ($stateMatchesTarget) {
        "temp"
    } else {
        "unknown"
    }

    return [pscustomobject]@{
        mode = $Mode
        surfaceType = $surface.surfaceType
        configPath = $ConfigPath
        targetPath = $surface.targetPath
        baselinePath = $baseline
        statePath = $statePath
        promptState = $promptState
        hasBaseline = $hasBaseline
        hasState = $hasState
        stateMatchesTarget = $stateMatchesTarget
        matchesBaseline = $matchesBaseline
        targetHash = $targetHash
        baselineHash = $baselineHash
        tempHash = $stateTempHash
        backupPath = if ($hasState) { $stateFile.backupPath } else { $null }
        createdAt = if ($hasState) { $stateFile.createdAt } else { $null }
        restoreAt = if ($hasState) { $stateFile.restoreAt } else { $null }
        hasTempMarker = $false
    }
}

function Write-State {
    param(
        [object]$State,
        [string]$Action
    )
    $State | Add-Member -NotePropertyName action -NotePropertyValue $Action -Force
    $State | ConvertTo-Json -Depth 6
}

function Restore-Baseline {
    $surface = Get-PromptSurface
    $baseline = Get-BaselinePath -Surface $surface
    $statePath = Get-StatePath -Surface $surface
    if (!(Test-Path -LiteralPath $baseline -PathType Leaf)) {
        throw "No baseline backup found: $baseline"
    }

    Set-PromptText -Surface $surface -PromptText (Read-Utf8 -Path $baseline)
    Remove-StateFile -Path $statePath
    Write-State -State (Get-State) -Action "restored"
}

function Get-WritePromptPath {
    if (![string]::IsNullOrWhiteSpace($PromptPath)) {
        return $PromptPath
    }
    if (![string]::IsNullOrWhiteSpace($SpecPath)) {
        return $SpecPath
    }
    throw "PromptPath is required for write-temp."
}

if ($Mode -eq "status") {
    Write-State -State (Get-State) -Action "status"
    exit 0
}

if ($Mode -eq "ensure-baseline") {
    $surface = Get-PromptSurface
    $state = Get-State
    if (!$state.hasBaseline) {
        Write-Utf8 -Path $state.baselinePath -Text ($surface.promptText.TrimEnd() + "`r`n")
        Remove-StateFile -Path $state.statePath
        Write-State -State (Get-State) -Action "baseline-created"
        exit 0
    }

    if (!$state.matchesBaseline) {
        Restore-Baseline
        exit 0
    }

    Remove-StateFile -Path $state.statePath
    Write-State -State (Get-State) -Action "baseline-ok"
    exit 0
}

if ($Mode -eq "write-temp") {
    $writePromptPath = Get-WritePromptPath
    if (!(Test-Path -LiteralPath $writePromptPath -PathType Leaf)) {
        throw "PromptPath not found: $writePromptPath"
    }

    powershell -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Mode ensure-baseline -ConfigPath $ConfigPath | Out-Null
    $surface = Get-PromptSurface
    $state = Get-State
    if (!$state.hasBaseline) {
        throw "Baseline backup missing after ensure-baseline."
    }

    $baselineText = Read-Utf8 -Path $state.baselinePath
    $finalPromptText = Read-Utf8 -Path $writePromptPath
    if ([string]::IsNullOrWhiteSpace($finalPromptText)) {
        throw "PromptPath is empty: $writePromptPath"
    }
    if ($finalPromptText -match "COMPACT-BETTER TEMP SPEC") {
        throw "Final prompt must not contain compact-better internal marker text."
    }
    if (!(Normalize-PromptText -Text $finalPromptText).StartsWith((Normalize-PromptText -Text $baselineText))) {
        throw "Final prompt must start with the clean compact-better baseline prompt."
    }

    $backupPath = Get-TimestampBackupPath -Surface $surface
    Copy-Item -LiteralPath $surface.targetPath -Destination $backupPath
    Set-PromptText -Surface $surface -PromptText $finalPromptText
    $newState = Get-State
    $createdAt = [DateTime]::UtcNow
    $restoreAt = $createdAt.AddSeconds($DelaySeconds)
    $privateState = [pscustomobject]@{
        version = 1
        targetPath = $surface.targetPath
        baselinePath = $state.baselinePath
        baselineHash = $state.baselineHash
        tempHash = $newState.targetHash
        backupPath = $backupPath
        createdAt = $createdAt.ToString("o")
        restoreAt = $restoreAt.ToString("o")
    }
    Write-StateFile -Path $state.statePath -State $privateState
    $writtenState = Get-State
    $writtenState | Add-Member -NotePropertyName timestampBackupPath -NotePropertyValue $backupPath -Force
    Write-State -State $writtenState -Action "temp-written"
    exit 0
}

if ($Mode -eq "restore") {
    Restore-Baseline
    exit 0
}

if ($Mode -eq "restore-after") {
    if ($DelaySeconds -lt 1) {
        throw "DelaySeconds must be positive."
    }
    Start-Sleep -Seconds $DelaySeconds
    $state = Get-State
    if ($state.hasState) {
        if (!$state.matchesBaseline) {
            Restore-Baseline
            exit 0
        }
        Remove-StateFile -Path $state.statePath
        Write-State -State (Get-State) -Action "already-baseline-state-cleared"
        exit 0
    }
    if ($state.matchesBaseline) {
        Write-State -State $state -Action "no-temp-state-noop"
        exit 0
    }
    throw "Prompt is not baseline and no compact-better state metadata exists: $($state.targetPath)"
}
