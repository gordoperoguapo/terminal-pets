# terminal-pets: Mote and friends from the upcoming Kuni app
# https://github.com/gordoperoguapo/terminal-pets
# Code: MIT license. Character designs: all rights reserved (see LICENSE).

$script:PetCsi = [string][char]27 + '['
$script:PetUpper = [string][char]0x2580
$script:PetLower = [string][char]0x2584
$script:PetSkinFile = Join-Path $PSScriptRoot 'pet-skin.txt'

function script:Read-PetSkins([string]$Path) {
    $skins = [ordered]@{}
    $skin = $null
    $inBody = $false
    foreach ($line in Get-Content $Path) {
        $line = $line.Trim()
        if ($inBody) {
            if ($line -eq 'end') { $inBody = $false } else { $skin.Body += $line }
            continue
        }
        if (-not $line -or $line.StartsWith('#')) { continue }
        $key, $rest = $line -split '\s+', 2
        switch ($key) {
            'skin'   { $skin = @{ Body = @(); Colors = @{} }; $skins[$rest] = $skin }
            'about'  { $skin.Blurb = $rest }
            'face'   {
                $top, $eyes, $mouth, $blush = $rest -split '\s+'
                $skin.FaceTop = [int]$top; $skin.Eyes = $eyes; $skin.Mouth = $mouth; $skin.Blush = $blush -eq 'blush'
            }
            'colors' { foreach ($pair in $rest -split '\s+') { $k, $v = $pair -split '='; $skin.Colors[$k] = $v } }
            'body'   { if ($rest -match '^like\s+(\S+)$') { $skin.Body = $skins[$Matches[1]].Body } else { $inBody = $true } }
        }
    }
    $skins
}

$script:PetSkins = Read-PetSkins (Join-Path $PSScriptRoot 'skins.txt')

function script:Get-PetSkinNames { $script:PetSkins.Keys }

function script:Test-PetSkinName([string]$Name) {
    if ($script:PetSkins.Contains($Name)) { return $true }
    throw "Unknown skin '$Name'. Choose from: $(@(Get-PetSkinNames) -join ', ')"
}

function script:New-PetSprite([string]$Skin = 'Mote', [int]$Look = 0, [switch]$Blink) {
    $s = $script:PetSkins[$Skin]
    $ft = $s.FaceTop
    $g = @()
    foreach ($row in $s.Body) { $g += , $row.ToCharArray() }
    foreach ($eye in 2, 7) {
        $x = $eye + $Look
        $out = if ($eye -eq 2) { -1 } else { 1 }
        switch ($s.Eyes) {
            'rumble' {
                $g[$ft - 2][$x + $out] = 'E'; $g[$ft - 1][$x] = 'E'; $g[$ft - 1][$x - $out] = 'E'
                if ($Blink) { $g[$ft + 1][$x] = 'E'; $g[$ft + 1][$x + $out] = 'E' }
                else { $g[$ft][$x] = 'G'; $g[$ft + 1][$x] = 'R' }
            }
            'sleepy' {
                $g[$ft][$x - 1] = 'E'; $g[$ft][$x + 1] = 'E'; $g[$ft + 1][$x] = 'E'
            }
            default {
                if ($Blink) {
                    $g[$ft][$x] = 'E'; $g[$ft + 1][$x - 1] = 'E'; $g[$ft + 1][$x + 1] = 'E'
                } elseif ($s.Eyes -eq 'star') {
                    $g[$ft][$x] = 'I'; $g[$ft + 1][$x] = 'J'
                } else {
                    $g[$ft][$x] = 'E'; $g[$ft + 1][$x] = 'E'
                }
            }
        }
    }
    if ($s.Blush) { $g[$ft + 2][1] = 'P'; $g[$ft + 2][8] = 'P' }
    if ($s.Mouth -eq 'fangs') {
        foreach ($c in 3, 4, 5, 6) { $g[$ft + 2][$c + $Look] = 'E' }
        $g[$ft + 3][3 + $Look] = 'W'; $g[$ft + 3][6 + $Look] = 'W'
    } else {
        $g[$ft + 3][4 + $Look] = 'E'; $g[$ft + 3][5 + $Look] = 'E'
    }
    , @($g | ForEach-Object { -join $_ })
}

function script:ConvertTo-PetLines([string[]]$Rows, [hashtable]$Colors) {
    $csi = $script:PetCsi
    $rgb = @{}
    foreach ($k in $Colors.Keys) {
        $hex = $Colors[$k]
        $rgb[$k] = '{0};{1};{2}' -f [Convert]::ToInt32($hex.Substring(0, 2), 16), [Convert]::ToInt32($hex.Substring(2, 2), 16), [Convert]::ToInt32($hex.Substring(4, 2), 16)
    }
    $lines = New-Object System.Collections.Generic.List[string]
    for ($r = 0; $r -lt $Rows.Count; $r += 2) {
        $top = $Rows[$r]
        $bot = if ($r + 1 -lt $Rows.Count) { $Rows[$r + 1] } else { '.' * $top.Length }
        $sb = New-Object System.Text.StringBuilder
        for ($c = 0; $c -lt $top.Length; $c++) {
            $t = $rgb[[string]$top[$c]]
            $b = $rgb[[string]$bot[$c]]
            if (-not $t -and -not $b) { [void]$sb.Append("${csi}0m ") }
            elseif (-not $b)          { [void]$sb.Append("${csi}0;38;2;${t}m$($script:PetUpper)") }
            elseif (-not $t)          { [void]$sb.Append("${csi}0;38;2;${b}m$($script:PetLower)") }
            else                      { [void]$sb.Append("${csi}38;2;${t};48;2;${b}m$($script:PetUpper)") }
        }
        [void]$sb.Append("${csi}0m")
        $lines.Add($sb.ToString())
    }
    , $lines.ToArray()
}

$script:PetFrameCache = @{}
function script:Get-PetFrames([string]$Skin) {
    if ($script:PetFrameCache[$Skin]) { return $script:PetFrameCache[$Skin] }
    $colors = $script:PetSkins[$Skin].Colors
    $place = {
        param([string[]]$Sprite, [int]$Offset)
        $height = $Sprite.Count + 2 + ($Sprite.Count % 2)
        $rows = @('.' * $Sprite[0].Length) * $height
        for ($i = 0; $i -lt $Sprite.Count; $i++) { $rows[$Offset + $i] = $Sprite[$i] }
        ConvertTo-PetLines $rows $colors
    }
    $f = @{}
    foreach ($look in -1, 0, 1) {
        $sprite = New-PetSprite $Skin -Look $look
        foreach ($off in 0, 1, 2) { $f["$look,$off"] = & $place $sprite $off }
    }
    $blink = New-PetSprite $Skin -Blink
    $f['blink'] = & $place $blink 2
    $f['blinkHop'] = & $place $blink 0
    $script:PetFrameCache[$Skin] = $f
    $f
}

function script:Write-PetFrame([string[]]$Frame, [int]$Left, [int]$Top) {
    for ($i = 0; $i -lt $Frame.Count; $i++) {
        [Console]::SetCursorPosition($Left, $Top + $i)
        [Console]::Write($Frame[$i])
    }
}

function script:Get-CurrentPetSkin {
    $name = $null
    if (Test-Path $script:PetSkinFile) { $name = (Get-Content $script:PetSkinFile -TotalCount 1).Trim() }
    if ($name -and $script:PetSkins.Contains($name)) { $script:PetSkins.Keys | Where-Object { $_ -eq $name } } else { 'Mote' }
}

function Get-PetSkin {
    $current = Get-CurrentPetSkin
    foreach ($name in $script:PetSkins.Keys) {
        [pscustomobject]@{
            Skin    = $name
            About   = $script:PetSkins[$name].Blurb
            Current = if ($name -eq $current) { '<-' } else { '' }
        }
    }
}

function Set-PetSkin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter({ param($cmd, $param, $word) @(Get-PetSkinNames) -like "$word*" })]
        [ValidateScript({ Test-PetSkinName $_ })]
        [string]$Skin
    )
    $Skin = $script:PetSkins.Keys | Where-Object { $_ -eq $Skin }
    Set-Content -Path $script:PetSkinFile -Value $Skin
    Show-PetBanner -Skin $Skin
}

function Show-PetBanner {
    [CmdletBinding()]
    param(
        [ArgumentCompleter({ param($cmd, $param, $word) @(Get-PetSkinNames) -like "$word*" })]
        [ValidateScript({ Test-PetSkinName $_ })]
        [string]$Skin = (Get-CurrentPetSkin),
        [switch]$NoAnimation
    )
    $csi = $script:PetCsi
    $f = Get-PetFrames $Skin
    $art = $f['0,2']
    $shell = if ($PSVersionTable.PSEdition -eq 'Core') { 'PowerShell' } else { 'Windows PowerShell' }
    $info = @('') * $art.Count
    $mid = [int][Math]::Floor($art.Count / 2) - 1
    $info[$mid]     = "${csi}1m$shell${csi}0m ${csi}90mv$($PSVersionTable.PSVersion)${csi}0m"
    $info[$mid + 1] = "${csi}90m$env:USERNAME @ $env:COMPUTERNAME${csi}0m"
    $info[$mid + 2] = "${csi}90m$((Get-Location).Path)${csi}0m"
    for ($i = 0; $i -lt $art.Count; $i++) { Write-Host ('  ' + $art[$i] + '    ' + $info[$i]) }
    Write-Host ''

    if ($NoAnimation -or [Console]::IsOutputRedirected) { return }
    try {
        $top = [Console]::CursorTop - $art.Count - 1
        $oldCursor = [Console]::CursorVisible
        [Console]::CursorVisible = $false
        $seq = '0,2', '0,1', '0,0', '0,0', '0,1', '0,2', '0,2', '0,1', '0,0', '0,1', '0,2', '0,2',
               '0,2', 'blink', 'blink', 'blink', '0,2', '0,2', '0,2', 'blink', '0,2'
        foreach ($name in $seq) {
            if ([Console]::KeyAvailable) { break }
            Write-PetFrame $f[$name] 2 $top
            Start-Sleep -Milliseconds 70
        }
        Write-PetFrame $art 2 $top
        [Console]::SetCursorPosition(0, $top + $art.Count + 1)
        [Console]::CursorVisible = $oldCursor
    } catch { }
}

function Start-Pet {
    [CmdletBinding()]
    param(
        [ArgumentCompleter({ param($cmd, $param, $word) @(Get-PetSkinNames) -like "$word*" })]
        [ValidateScript({ Test-PetSkinName $_ })]
        [string]$Skin = (Get-CurrentPetSkin),
        [int]$Speed = 110
    )
    $csi = $script:PetCsi
    $f = Get-PetFrames $Skin
    $h = $f['0,2'].Count
    $w = $script:PetSkins[$Skin].Body[0].Length

    1..$h | ForEach-Object { Write-Host '' }
    $top = [Console]::CursorTop - $h
    $maxX = [Math]::Max(1, [Console]::WindowWidth - $w - 1)

    $x = 0; $dir = 1; $step = 0; $rest = 0; $mood = 'calm'; $hop = 0
    $rand = New-Object Random
    $oldCursor = [Console]::CursorVisible
    [Console]::CursorVisible = $false
    try {
        while (-not [Console]::KeyAvailable) {
            $step++
            if ($rest -gt 0) {
                $rest--
                switch ($mood) {
                    'happy'   { $frame = if ($step % 4 -lt 2) { $f['blinkHop'] } else { $f['blink'] } }
                    'curious' { $frame = $f["$([int][Math]::Sign([Math]::Sin($step / 5))),2"] }
                    default   { $frame = if ($rest % 16 -lt 2) { $f['blink'] } else { $f['0,2'] } }
                }
            } else {
                $x += $dir
                if ($x -ge $maxX) { $x = $maxX; $dir = -1 }
                if ($x -le 0)     { $x = 0;     $dir = 1 }
                if ($hop -gt 0) {
                    $hop--
                    $off = 0
                } else {
                    $off = if ($step % 4 -lt 2) { 2 } else { 1 }
                    if ($rand.Next(40) -eq 0) { $hop = 3 }
                }
                $frame = $f["$dir,$off"]
                if ($rand.Next(70) -eq 0) {
                    $rest = 20 + $rand.Next(30)
                    $mood = @('calm', 'happy', 'curious')[$rand.Next(3)]
                }
            }

            $pad = ' ' * $x
            for ($i = 0; $i -lt $h; $i++) {
                [Console]::SetCursorPosition(0, $top + $i)
                [Console]::Write($pad + $frame[$i] + "${csi}K")
            }
            Start-Sleep -Milliseconds $Speed
        }
        [void][Console]::ReadKey($true)
    } finally {
        [Console]::Write("${csi}0m")
        [Console]::CursorVisible = $oldCursor
        [Console]::SetCursorPosition(0, $top + $h)
    }
}
Set-Alias -Name pet -Value Start-Pet

if ($PetBanner -ne $false) { Show-PetBanner }
