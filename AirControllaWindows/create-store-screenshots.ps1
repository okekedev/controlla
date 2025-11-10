# PowerShell script to create Microsoft Store screenshots
# Creates composite images and resizes for optimal Store display

Add-Type -AssemblyName System.Drawing

$destDir = ".\Screenshots"
if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
}

Write-Host "Creating Microsoft Store screenshots..." -ForegroundColor Green
Write-Host ""

# === Screenshot 1: Main composite (Mac receiver + iPhone overlay) ===
Write-Host "Creating main composite screenshot..." -ForegroundColor Yellow

$macScreenshot = "..\deployment\screenshots\macos\4_mac-1.png"
$iphoneScreenshot = "..\deployment\screenshots\en-US\1_iphone67-1.png"

# Load images
$macImg = [System.Drawing.Image]::FromFile((Resolve-Path $macScreenshot))
$iphoneImg = [System.Drawing.Image]::FromFile((Resolve-Path $iphoneScreenshot))

# Create canvas (1920x1080 - 16:9 for Store)
$canvas = New-Object System.Drawing.Bitmap(1920, 1080)
$graphics = [System.Drawing.Graphics]::FromImage($canvas)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Fill with gradient background (blue)
$blueBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(245, 247, 250))
$graphics.FillRectangle($blueBrush, 0, 0, 1920, 1080)

# Draw Mac screenshot (receiver) - centered and scaled to fit
$macWidth = 1200
$macHeight = [int]($macImg.Height * ($macWidth / $macImg.Width))
$macX = (1920 - $macWidth) / 2
$macY = (1080 - $macHeight) / 2
$graphics.DrawImage($macImg, $macX, $macY, $macWidth, $macHeight)

# Draw iPhone screenshot (controller) - scaled and positioned in bottom right
$iphoneWidth = 300
$iphoneHeight = [int]($iphoneImg.Height * ($iphoneWidth / $iphoneImg.Width))
$iphoneX = 1920 - $iphoneWidth - 100
$iphoneY = 1080 - $iphoneHeight - 50
$graphics.DrawImage($iphoneImg, $iphoneX, $iphoneY, $iphoneWidth, $iphoneHeight)

# Save
$outputPath = "$destDir\1-main-composite.png"
$canvas.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "  ✓ Created: 1-main-composite.png (1920x1080)" -ForegroundColor Green

# Cleanup
$graphics.Dispose()
$canvas.Dispose()
$macImg.Dispose()
$iphoneImg.Dispose()
$blueBrush.Dispose()

# === Screenshot 2: iPhone controller close-up ===
Write-Host "Creating iPhone controller screenshot..." -ForegroundColor Yellow

$iphoneImg2 = [System.Drawing.Image]::FromFile((Resolve-Path "..\deployment\screenshots\en-US\1_iphone67-2.png"))
$canvas2 = New-Object System.Drawing.Bitmap(1920, 1080)
$graphics2 = [System.Drawing.Graphics]::FromImage($canvas2)
$graphics2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Background
$blueBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(245, 247, 250))
$graphics2.FillRectangle($blueBrush2, 0, 0, 1920, 1080)

# Center iPhone screenshot
$phone2Width = 600
$phone2Height = [int]($iphoneImg2.Height * ($phone2Width / $iphoneImg2.Width))
$phone2X = (1920 - $phone2Width) / 2
$phone2Y = (1080 - $phone2Height) / 2
$graphics2.DrawImage($iphoneImg2, $phone2X, $phone2Y, $phone2Width, $phone2Height)

$outputPath2 = "$destDir\2-iphone-controller.png"
$canvas2.Save($outputPath2, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "  ✓ Created: 2-iphone-controller.png (1920x1080)" -ForegroundColor Green

$graphics2.Dispose()
$canvas2.Dispose()
$iphoneImg2.Dispose()
$blueBrush2.Dispose()

# === Screenshot 3: Windows receiver ===
Write-Host "Creating Windows receiver screenshot..." -ForegroundColor Yellow

$macImg3 = [System.Drawing.Image]::FromFile((Resolve-Path "..\deployment\screenshots\macos\4_mac-2.png"))
$canvas3 = New-Object System.Drawing.Bitmap(1920, 1080)
$graphics3 = [System.Drawing.Graphics]::FromImage($canvas3)
$graphics3.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Background
$blueBrush3 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(245, 247, 250))
$graphics3.FillRectangle($blueBrush3, 0, 0, 1920, 1080)

# Center receiver screenshot
$rec3Width = 1400
$rec3Height = [int]($macImg3.Height * ($rec3Width / $macImg3.Width))
$rec3X = (1920 - $rec3Width) / 2
$rec3Y = (1080 - $rec3Height) / 2
$graphics3.DrawImage($macImg3, $rec3X, $rec3Y, $rec3Width, $rec3Height)

$outputPath3 = "$destDir\3-windows-receiver.png"
$canvas3.Save($outputPath3, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "  ✓ Created: 3-windows-receiver.png (1920x1080)" -ForegroundColor Green

$graphics3.Dispose()
$canvas3.Dispose()
$macImg3.Dispose()
$blueBrush3.Dispose()

Write-Host ""
