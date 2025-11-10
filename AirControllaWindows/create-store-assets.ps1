# PowerShell script to create Microsoft Store assets from icon.ico
# This creates all required MSIX package images

$assetsPath = ".\AirControllaWindows\Assets"
$iconPath = ".\AirControllaWindows\icon.ico"

# Create Assets directory if it doesn't exist
if (!(Test-Path $assetsPath)) {
    New-Item -ItemType Directory -Path $assetsPath | Out-Null
}

Write-Host "Creating Microsoft Store assets..." -ForegroundColor Green

# Load the icon
Add-Type -AssemblyName System.Drawing
$icon = [System.Drawing.Icon]::new($iconPath)

# Function to save icon as PNG at specific size
function Save-IconAsPng {
    param(
        [string]$outputPath,
        [int]$size
    )

    $bitmap = [System.Drawing.Bitmap]::new($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($icon.ToBitmap(), 0, 0, $size, $size)
    $graphics.Dispose()
    $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()

    Write-Host "  Created: $outputPath ($size x $size)" -ForegroundColor Cyan
}

# Create required store assets
Save-IconAsPng "$assetsPath\StoreLogo.png" 50
Save-IconAsPng "$assetsPath\Square44x44Logo.png" 44
Save-IconAsPng "$assetsPath\Square150x150Logo.png" 150
Save-IconAsPng "$assetsPath\Wide310x150Logo.png" 310  # Note: Will be square, needs manual editing
Save-IconAsPng "$assetsPath\SplashScreen.png" 620

$icon.Dispose()

Write-Host "`nStore assets created successfully!" -ForegroundColor Green
Write-Host "`nNOTE: Wide310x150Logo.png needs to be manually edited to 310x150 pixels" -ForegroundColor Yellow
Write-Host "You can use an image editor to create a wide logo from your branding." -ForegroundColor Yellow
Write-Host "`nNext steps:" -ForegroundColor Green
Write-Host "1. Edit Wide310x150Logo.png to be 310x150 pixels (currently 310x310)"
Write-Host "2. Run: dotnet publish -p:WindowsPackageType=MSIX -p:RuntimeIdentifier=win-x64"
Write-Host "3. Upload the .msix file to Microsoft Partner Center"
