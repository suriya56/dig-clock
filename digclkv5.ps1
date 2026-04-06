$digitArt = @{
    0 = @"
######
##  ##
##  ##
##  ##
######
"@
    1 = @"
    ##
    ##
    ##
    ##
    ##
"@
    2 = @"
######
    ##
######
##
######
"@
    3 = @"
######
    ##
######
    ##
######
"@
    4 = @"
##  ##
##  ##
######
    ##
    ##
"@
    5 = @"
######
##
######
    ##
######
"@
    6 = @"
######
##
######
##  ##
######
"@
    7 = @"
######
    ##
    ##
    ##
    ##
"@
    8 = @"
######
##  ##
######
##  ##
######
"@
    9 = @"
######
##  ##
######
    ##
    ##
"@
    ':' = @'
  
##

##
  
'@
}

function Get-ClosestConsoleColor {
    param([int]$r, [int]$g, [int]$b)
    $colorMap = @{
        'Black'      = @(0, 0, 0)
        'DarkBlue'   = @(0, 0, 128)
        'DarkGreen'  = @(0, 128, 0)
        'DarkCyan'   = @(0, 128, 128)
        'DarkRed'    = @(128, 0, 0)
        'DarkMagenta'= @(128, 0, 128)
        'DarkYellow' = @(128, 128, 0)
        'Gray'       = @(128, 128, 128)
        'DarkGray'   = @(64, 64, 64)
        'Blue'       = @(0, 0, 255)
        'Green'      = @(0, 255, 0)
        'Cyan'       = @(0, 255, 255)
        'Red'        = @(255, 0, 0)
        'Magenta'    = @(255, 0, 255)
        'Yellow'     = @(255, 255, 0)
        'White'      = @(255, 255, 255)
    }
    $minDist = [double]::MaxValue
    $closest = 'Yellow'
    foreach ($name in $colorMap.Keys) {
        $cr = $colorMap[$name][0]
        $cg = $colorMap[$name][1]
        $cb = $colorMap[$name][2]
        $dist = [Math]::Sqrt(($r-$cr)*($r-$cr) + ($g-$cg)*($g-$cg) + ($b-$cb)*($b-$cb))
        if ($dist -lt $minDist) {
            $minDist = $dist
            $closest = $name
        }
    }
    return $closest
}

function Show-DigitalClock {
    $format='HH:mm' # HH:mm for 24 hour format, hh:mm for 12 hour format
    $dateformat='dddd, dd MMMM,yyyy' # date format
    $showdate=$true # $true to show date, $false to hide date

    $walColorFile = Join-Path $env:USERPROFILE ".cache\wal\colors"
    $color = "Yellow"
    if (Test-Path $walColorFile) {
        $colors = Get-Content $walColorFile
        if ($colors.Count -gt 6) {
            $hex = $colors[6].Trim()
            if ($hex -match '^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$') {
                $r = [int]::Parse($matches[1], 'HexNumber')
                $g = [int]::Parse($matches[2], 'HexNumber')
                $b = [int]::Parse($matches[3], 'HexNumber')
                $color = Get-ClosestConsoleColor $r $g $b
            }
        }
    }
    
    while ($true) {
        $hour = (Get-Date).Hour
        $minute = (Get-Date).Minute

        $hourDigit1 = [int]([math]::Floor($hour / 10))
        $hourDigit2 = $hour % 10
        $minuteDigit1 = [int]([math]::Floor($minute / 10))
        $minuteDigit2 = $minute % 10

  
        $m2 = $($digitArt[$minuteDigit2]) -split "`r?`n"
        $m1 = $($digitArt[$minuteDigit1]) -split "`r?`n"
        $col = $($digitArt[':']) -split "`r?`n"
        $space = " " * ($col[0].Length)
        $h1 = $($digitArt[$hourDigit1]) -split "`r?`n"
        $h2 = $($digitArt[$hourDigit2]) -split "`r?`n"
        $maxLineLength = [Math]::Max([Math]::Max($h1[0].Length, $h2[0].Length), [Math]::Max($m1[0].Length, $m2[0].Length))

        Clear-Host

        $terminalWidth = [System.Console]::WindowWidth
        $totalWidth = ($h1[0].Length + $space.Length + $h2[0].Length + $space.Length + $col[0].Length + $m1[0].Length + $space.Length + $m2[0].Length)
        $leftPadding = [math]::Round(($terminalWidth - $totalWidth) / 2)
        if ($leftPadding -lt 0) { $leftPadding = 0 }

        for ($i = 0; $i -lt 5; $i++)
        {
            $line = $h1[$i] + $space + $h2[$i] + $space + $col[$i] + $space + $m1[$i] + $space + $m2[$i]
            Write-Host (" " * $leftPadding + $line) -ForegroundColor $color
               }
        
        if($showdate) {
            $dateString = (get-date -format $dateformat)
            $datePadding = [math]::Round(($terminalWidth - $dateString.Length) / 2)
            if ($datePadding -lt 0) { $datePadding = 0 }
            Write-Host (" " * $datePadding + $dateString) -ForegroundColor $color
        }
        Start-Sleep -Seconds 1
    }
}

Show-DigitalClock

