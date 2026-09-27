# terminal-pets one-line installer
# irm https://raw.githubusercontent.com/gordoperoguapo/terminal-pets/main/web-install.ps1 | iex

& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    $dest = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA 'terminal-pets' } else { Join-Path $HOME '.terminal-pets' }
    $work = Join-Path ([IO.Path]::GetTempPath()) ('terminal-pets-' + [guid]::NewGuid().ToString('N'))
    $zip = "$work.zip"
    $policy = Get-ExecutionPolicy
    $processPolicy = Get-ExecutionPolicy -Scope Process

    Write-Host ''
    Write-Host '  terminal-pets' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  Downloading...' -NoNewline
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest 'https://github.com/gordoperoguapo/terminal-pets/archive/refs/heads/main.zip' -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath $work -Force
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Copy-Item -Path (Join-Path $work 'terminal-pets-main\*') -Destination $dest -Recurse -Force
    } catch {
        Write-Host ' failed' -ForegroundColor Red
        throw
    } finally {
        Remove-Item -Path $zip, $work -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host ' done' -ForegroundColor Green

    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    try {
        & (Join-Path $dest 'install.ps1')
    } finally {
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy $processPolicy -Force
    }

    if ($policy -in 'Restricted', 'AllSigned', 'Undefined') {
        Write-Host ''
        Write-Host "  PowerShell is set to block scripts, so your pet won't load in new windows yet." -ForegroundColor Yellow
        Write-Host '  To allow it, run this once:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned' -ForegroundColor Yellow
    }
}
