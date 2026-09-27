# terminal-pets: Mote and friends from the Kuni app
# https://github.com/gordoperoguapo/terminal-pets
# Code: MIT license. Character designs: all rights reserved (see LICENSE).

$script:PetCsi = [string][char]27 + '['
$script:PetUpper = [string][char]0x2580
$script:PetLower = [string][char]0x2584
$script:PetSkinFile = Join-Path $PSScriptRoot 'pet-skin.txt'

$moteBody = @(
    '..oooooo..',
    '.oHXXXXXo.',
    'oHXXXXXXXo',
    'oXXXXXXXXo',
    'oXXXXXXXXo',
    'oXXXXXXXXo',
    'oSXXXXXXSo',
    '.oSSSSSSo.',
    '.oo.oo.oo.'
)

$script:PetSkins = [ordered]@{
    Mote = @{
        Blurb = 'the original'; Body = $moteBody; FaceTop = 3; Eyes = 'mote'; Mouth = 'smile'; Blush = $true
        Colors = @{ o = 'cfb07a'; X = 'fdebc2'; H = 'fff9ea'; S = 'e2c48c'; E = '2a2340'; W = 'ffffff'; P = 'ffb0be' }
    }
    Mint = @{
        Blurb = 'a minty Mote'; Body = $moteBody; FaceTop = 3; Eyes = 'mote'; Mouth = 'smile'; Blush = $true
        Colors = @{ o = '4fa682'; X = 'b3f2d6'; H = 'e6fff3'; S = '62c79c'; E = '2a2340'; W = 'ffffff'; P = 'f0a8b4' }
    }
    Pink = @{
        Blurb = 'a pink Mote'; Body = $moteBody; FaceTop = 3; Eyes = 'mote'; Mouth = 'smile'; Blush = $true
        Colors = @{ o = 'cf7590'; X = 'ffc3d2'; H = 'ffe8ef'; S = 'e98fa6'; E = '2a2340'; W = 'ffffff'; P = 'f27d9b' }
    }
    Lavender = @{
        Blurb = 'a lavender Mote'; Body = $moteBody; FaceTop = 3; Eyes = 'mote'; Mouth = 'smile'; Blush = $true
        Colors = @{ o = '8a6fbd'; X = 'd4c0fa'; H = 'f2ebff'; S = 'a086de'; E = '2a2340'; W = 'ffffff'; P = 'f2a6c8' }
    }
    Rumble = @{
        Blurb = 'a tough little kaiju'; FaceTop = 5; Eyes = 'rumble'; Mouth = 'fangs'; Blush = $false
        Body = @(
            '.N..TT..N.',
            '..NooooN..',
            '.oHXXXXXo.',
            'oHXXXXXXXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oSXXBBXXSo',
            '.oSBBBBSo.',
            '.CoCooCoC.'
        )
        Colors = @{ o = '1c2340'; X = '58699a'; H = '7d90b8'; S = '404f7a'; N = 'd8cfbd'; T = '3fbfb0'; B = 'b9c6de'
                    C = 'e9e2d2'; W = 'ffffff'; G = 'ffc23a'; R = 'e57d12'; E = '141a30' }
    }
    Drizzle = @{
        Blurb = 'a little rain cloud'; FaceTop = 4; Eyes = 'star'; Mouth = 'smile'; Blush = $true
        Body = @(
            '...VVVV...',
            '..VUUUUV..',
            '.oVUUUUVo.',
            'oHXXDXXDXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oSXXXXXXSo',
            '.oSDSSDSo.',
            '.oo.oo.oo.'
        )
        Colors = @{ o = '5f6fcf'; X = 'b9c3f6'; H = 'e3e8ff'; S = '8a96dd'; D = '7a86d8'; U = 'f4f6ff'; V = '8f98d8'
                    I = '4b62d6'; J = '1d2a7a'; E = '2a2340'; P = 'e6a8c6' }
    }
    Ember = @{
        Blurb = 'a cozy flame'; FaceTop = 3; Eyes = 'star'; Mouth = 'smile'; Blush = $true
        Body = @(
            '..oooooo.F',
            'FoHXXXXXo.',
            'oHXXXXXXXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oSXXXXXXSo',
            '.oSSSSSSoF',
            'Foo.oo.oo.'
        )
        Colors = @{ o = 'c9621c'; X = 'ffae52'; H = 'ffd49a'; S = 'f07a22'; F = 'ffb347'
                    I = '3b3354'; J = '16122a'; E = '2a2340'; P = 'ff8248' }
    }
    Puff = @{
        Blurb = 'a sleepy cloud'; FaceTop = 3; Eyes = 'sleepy'; Mouth = 'smile'; Blush = $true
        Body = @(
            '..oo..oo..',
            '.oHHooXXo.',
            'oHXXXXXXXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oXXXXXXXXo',
            'oSXXXXXXSo',
            'oSSSSSSSSo',
            '.oo.oo.oo.'
        )
        Colors = @{ o = 'b8abe6'; X = 'f4f0ff'; H = 'ffffff'; S = 'cabff0'; E = '4a3f6e'; P = 'f9bbcc' }
    }
}
Remove-Variable moteBody

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
        [ValidateSet('Mote', 'Mint', 'Pink', 'Lavender', 'Rumble', 'Drizzle', 'Ember', 'Puff')]
        [string]$Skin
    )
    $Skin = $script:PetSkins.Keys | Where-Object { $_ -eq $Skin }
    Set-Content -Path $script:PetSkinFile -Value $Skin
    Show-PetBanner -Skin $Skin
}

function Show-PetBanner {
    [CmdletBinding()]
    param(
        [ValidateSet('Mote', 'Mint', 'Pink', 'Lavender', 'Rumble', 'Drizzle', 'Ember', 'Puff')]
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
        [ValidateSet('Mote', 'Mint', 'Pink', 'Lavender', 'Rumble', 'Drizzle', 'Ember', 'Puff')]
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
