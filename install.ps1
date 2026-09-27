$ErrorActionPreference = 'Stop'
$petScript = Join-Path $PSScriptRoot 'pet.ps1'
$marker = '# terminal-pets'
$profilePath = $PROFILE.CurrentUserCurrentHost

if (Get-Command Unblock-File -ErrorAction SilentlyContinue) {
    Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 | Unblock-File
}

function Get-ProfileEncoding([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { return New-Object Text.UTF8Encoding $true }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { return [Text.Encoding]::Unicode }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) { return [Text.Encoding]::BigEndianUnicode }
    if ($PSVersionTable.PSEdition -eq 'Core') { return New-Object Text.UTF8Encoding $false }
    [Text.Encoding]::Default
}

if (-not (Test-Path $profilePath)) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
    [IO.File]::WriteAllText($profilePath, '')
}

$encoding = Get-ProfileEncoding $profilePath
$text = [IO.File]::ReadAllText($profilePath, $encoding)

if ($text -match [regex]::Escape($marker)) {
    Write-Host "terminal-pets is already in your profile ($profilePath)."
} else {
    $line = ". `"$petScript`"   $marker"
    $newText = if ($text.Length -gt 0 -and -not $text.EndsWith("`n")) { $text + "`r`n" + $line + "`r`n" } else { $text + $line + "`r`n" }
    [IO.File]::WriteAllText($profilePath, $newText, $encoding)
    Write-Host "Added terminal-pets to $profilePath"
}

Write-Host ''
. $petScript
Write-Host "Open a new PowerShell window any time to see your pet. Try 'pet' or 'Get-PetSkin'."
Write-Host "Keep this folder where it is; your profile loads the pet from here."
