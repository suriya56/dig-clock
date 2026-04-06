$digitArt = @{
    0 = @"
  ██████
  ██  ██
  ██  ██
  ██  ██
  ██████
"@
    1 = @"
      ██
      ██
      ██
      ██
      ██
"@
    2 = @"
  ██████
      ██
  ██████
  ██
  ██████
"@
    3 = @"
  ██████
      ██
  ██████
      ██
  ██████
"@
    4 = @"
  ██  ██
  ██  ██
  ██████
      ██
      ██
"@
    5 = @"
  ██████
  ██
  ██████
      ██
  ██████
"@
    6 = @"
  ██████
  ██
  ██████
  ██  ██
  ██████
"@
    7 = @"
  ██████
      ██
      ██
      ██
      ██
"@
    8 = @"
  ██████
  ██  ██
  ██████
  ██  ██
  ██████
"@
    9 = @"
  ██████
  ██  ██
  ██████
      ██
      ██
"@
    ':' = @"

  ██

  ██

"@
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
    [Console]::CursorVisible = $false
    $format='hh:mm' # HH:mm for 24 hour format, hh:mm for 12 hour format
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
        $terminalHeight = [System.Console]::WindowHeight

        $clockHeight = 5
        $topPadding = [math]::Floor(($terminalHeight - $clockHeight) / 2)
        if ($topPadding -lt 0) { $topPadding = 0 }

        for ($p = 0; $p -lt $topPadding; $p++) {
            Write-Host ""
        }

        for ($i = 0; $i -lt 5; $i++)
        {
            $timeLine = $h1[$i].PadRight($maxLineLength) + $space + $h2[$i].PadRight($maxLineLength) + $space + $col[$i].PadRight($maxLineLength) + $m1[$i].PadRight($maxLineLength) + $space + $m2[$i].PadRight($maxLineLength)
            $totalPadding = [math]::Round(($terminalWidth - $timeLine.Length) / 2)
            if ($totalPadding -lt 0) { $totalPadding = 0 }
            Write-Host (" " * $totalPadding + $timeLine) -ForegroundColor $color
               }

        if($showdate) {
            $dateString = (Get-Date -Format $dateformat)
            $datePadding = [math]::Round(($terminalWidth - $dateString.Length) / 2) - $space.Length
            if ($datePadding -lt 0) { $datePadding = 0 }
            Write-Host ""
            Write-Host (" " * $datePadding + $dateString) -ForegroundColor $color
        }
        Start-Sleep -Seconds 5
    }
}

Show-DigitalClock
