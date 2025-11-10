# Create Wide310x150Logo.png with proper dimensions
Add-Type -AssemblyName System.Drawing

$assetsPath = ".\AirControllaWindows\Assets"
$iconPath = ".\AirControllaWindows\icon.ico"

# Load the icon
$icon = [System.Drawing.Icon]::new($iconPath)
$iconBitmap = $icon.ToBitmap()

# Create wide logo (310x150) with icon centered
$wideLogo = [System.Drawing.Bitmap]::new(310, 150)
$graphics = [System.Drawing.Graphics]::FromImage($wideLogo)

# Fill with transparent or blue background
$blueBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(59, 130, 246))
$graphics.FillRectangle($blueBrush, 0, 0, 310, 150)

# Draw icon in center (icon will be 100x100)
$iconSize = 100
$iconX = (310 - $iconSize) / 2
$iconY = (150 - $iconSize) / 2
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.DrawImage($iconBitmap, $iconX, $iconY, $iconSize, $iconSize)

# Save
$wideLogo.Save("$assetsPath\Wide310x150Logo.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Cleanup
$graphics.Dispose()
$wideLogo.Dispose()
$iconBitmap.Dispose()
$icon.Dispose()
$blueBrush.Dispose()

Write-Host "Wide logo created: $assetsPath\Wide310x150Logo.png (310x150)" -ForegroundColor Green
