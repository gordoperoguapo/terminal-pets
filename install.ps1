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

Write-Host '  Adding to your PowerShell profile...' -NoNewline
if ($text -match [regex]::Escape($marker)) {
    Write-Host ' already there' -ForegroundColor Green
} else {
    $line = ". `"$petScript`"   $marker"
    $newText = if ($text.Length -gt 0 -and -not $text.EndsWith("`n")) { $text + "`r`n" + $line + "`r`n" } else { $text + $line + "`r`n" }
    [IO.File]::WriteAllText($profilePath, $newText, $encoding)
    Write-Host ' done' -ForegroundColor Green
}

Write-Host ''
. $petScript
Write-Host '  All set! Open a new window any time and try: pet, Get-PetSkin, Set-PetSkin Rumble' -ForegroundColor Green
if ($env:LOCALAPPDATA -and -not $PSScriptRoot.StartsWith($env:LOCALAPPDATA)) {
    Write-Host "  Your profile loads the pet from $PSScriptRoot, so keep that folder." -ForegroundColor DarkGray
}
Write-Host ''
