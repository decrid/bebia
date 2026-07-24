param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$appIconDirectory = Join-Path $projectRoot 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
$launchImageDirectory = Join-Path $projectRoot 'ios\Runner\Assets.xcassets\LaunchImage.imageset'
$contentsPath = Join-Path $appIconDirectory 'Contents.json'

if (-not (Test-Path -LiteralPath $contentsPath)) {
    throw "iOS AppIcon catalog was not found at $contentsPath"
}

function New-BebiaGraphics {
    param([System.Drawing.Bitmap] $Bitmap)

    $graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality =
        [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    return $graphics
}

function Draw-BebiaMark {
    param(
        [System.Drawing.Graphics] $Graphics,
        [float] $Scale,
        [float] $OffsetX,
        [float] $OffsetY
    )

    $foreground = [System.Drawing.ColorTranslator]::FromHtml('#FFF8ED')
    $accent = [System.Drawing.ColorTranslator]::FromHtml('#F09A82')
    $pen = [System.Drawing.Pen]::new($foreground, 8 * $Scale)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $accentBrush = [System.Drawing.SolidBrush]::new($accent)

    try {
        $point = {
            param([float] $X, [float] $Y)
            return [System.Drawing.PointF]::new(
                $OffsetX + ($X * $Scale),
                $OffsetY + ($Y * $Scale)
            )
        }

        $Graphics.DrawLine(
            $pen,
            (& $point 37 24),
            (& $point 37 84)
        )
        $Graphics.DrawBezier(
            $pen,
            (& $point 38 31),
            (& $point 64 21),
            (& $point 78 31),
            (& $point 76 45)
        )
        $Graphics.DrawBezier(
            $pen,
            (& $point 76 45),
            (& $point 75 54),
            (& $point 65 58),
            (& $point 42 56)
        )
        $Graphics.DrawBezier(
            $pen,
            (& $point 42 56),
            (& $point 72 53),
            (& $point 82 65),
            (& $point 76 78)
        )
        $Graphics.DrawBezier(
            $pen,
            (& $point 76 78),
            (& $point 70 91),
            (& $point 50 88),
            (& $point 38 80)
        )
        $Graphics.FillEllipse(
            $accentBrush,
            $OffsetX + (53.5 * $Scale),
            $OffsetY + (63.5 * $Scale),
            11 * $Scale,
            11 * $Scale
        )
    }
    finally {
        $pen.Dispose()
        $accentBrush.Dispose()
    }
}

function New-BebiaAppIcon {
    param(
        [int] $Pixels,
        [string] $OutputPath
    )

    $bitmap = [System.Drawing.Bitmap]::new(
        $Pixels,
        $Pixels,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = New-BebiaGraphics -Bitmap $bitmap
    try {
        $background = [System.Drawing.ColorTranslator]::FromHtml('#2F6B5A')
        $graphics.Clear($background)
        Draw-BebiaMark -Graphics $graphics -Scale ($Pixels / 108) -OffsetX 0 -OffsetY 0
        $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function New-BebiaLaunchImage {
    param(
        [int] $Scale,
        [string] $OutputPath
    )

    $width = 168 * $Scale
    $height = 185 * $Scale
    $tileSize = 108 * $Scale
    $bitmap = [System.Drawing.Bitmap]::new(
        $width,
        $height,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = New-BebiaGraphics -Bitmap $bitmap
    $tileBrush =
        [System.Drawing.SolidBrush]::new(
            [System.Drawing.ColorTranslator]::FromHtml('#2F6B5A')
        )
    $tilePath = [System.Drawing.Drawing2D.GraphicsPath]::new()

    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $left = ($width - $tileSize) / 2
        $top = ($height - $tileSize) / 2
        $radius = 30 * $Scale
        $diameter = 2 * $radius
        $tilePath.AddArc($left, $top, $diameter, $diameter, 180, 90)
        $tilePath.AddArc(
            $left + $tileSize - $diameter,
            $top,
            $diameter,
            $diameter,
            270,
            90
        )
        $tilePath.AddArc(
            $left + $tileSize - $diameter,
            $top + $tileSize - $diameter,
            $diameter,
            $diameter,
            0,
            90
        )
        $tilePath.AddArc(
            $left,
            $top + $tileSize - $diameter,
            $diameter,
            $diameter,
            90,
            90
        )
        $tilePath.CloseFigure()
        $graphics.FillPath($tileBrush, $tilePath)
        Draw-BebiaMark `
            -Graphics $graphics `
            -Scale $Scale `
            -OffsetX $left `
            -OffsetY $top
        $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $tilePath.Dispose()
        $tileBrush.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$catalog = Get-Content -Raw -LiteralPath $contentsPath | ConvertFrom-Json
foreach ($image in $catalog.images) {
    if ([string]::IsNullOrWhiteSpace($image.filename)) {
        continue
    }
    $points = [double](($image.size -split 'x')[0])
    $scale = [int](($image.scale -replace 'x', ''))
    $pixels = [int][Math]::Round($points * $scale)
    $outputPath = Join-Path $appIconDirectory $image.filename
    New-BebiaAppIcon -Pixels $pixels -OutputPath $outputPath
}

New-BebiaLaunchImage `
    -Scale 1 `
    -OutputPath (Join-Path $launchImageDirectory 'LaunchImage.png')
New-BebiaLaunchImage `
    -Scale 2 `
    -OutputPath (Join-Path $launchImageDirectory 'LaunchImage@2x.png')
New-BebiaLaunchImage `
    -Scale 3 `
    -OutputPath (Join-Path $launchImageDirectory 'LaunchImage@3x.png')

Write-Host 'Bebia iOS app icon and launch image assets were generated.'
