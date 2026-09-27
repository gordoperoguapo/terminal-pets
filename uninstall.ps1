$ErrorActionPreference = 'Stop'
$marker = '# terminal-pets'
$profilePath = $PROFILE.CurrentUserCurrentHost

function Get-ProfileEncoding([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { return New-Object Text.UTF8Encoding $true }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { return [Text.Encoding]::Unicode }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) { return [Text.Encoding]::BigEndianUnicode }
    if ($PSVersionTable.PSEdition -eq 'Core') { return New-Object Text.UTF8Encoding $false }
    [Text.Encoding]::Default
}

if (-not (Test-Path $profilePath)) {
    Write-Host "No profile found at $profilePath; nothing to remove."
    return
}

$encoding = Get-ProfileEncoding $profilePath
$lines = [IO.File]::ReadAllText($profilePath, $encoding) -split "`r?`n"
$kept = @($lines | Where-Object { $_ -notmatch [regex]::Escape($marker) })

if ($kept.Count -eq $lines.Count) {
    Write-Host "terminal-pets wasn't in your profile ($profilePath)."
} else {
    [IO.File]::WriteAllText($profilePath, ($kept -join "`r`n"), $encoding)
    Write-Host "Removed terminal-pets from $profilePath. Open a new window to finish."
    Write-Host "You can now delete this folder."
}
