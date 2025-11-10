# PowerShell script to prepare screenshots for Microsoft Store
# Copies and resizes existing screenshots for Windows Store listing

$sourceDir = "..\deployment\screenshots"
$destDir = ".\Screenshots"

# Create destination directory
if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
}

Write-Host "Preparing Microsoft Store screenshots..." -ForegroundColor Green
Write-Host ""

# Add System.Drawing assembly for image processing
Add-Type -AssemblyName System.Drawing

# Function to resize image maintaining aspect ratio
function Resize-Image {
    param(
        [string]$inputPath,
        [string]$outputPath,
        [int]$targetWidth
    )

    $img = [System.Drawing.Image]::FromFile($inputPath)

    # Calculate new height maintaining aspect ratio
    $aspectRatio = $img.Height / $img.Width
    $targetHeight = [int]($targetWidth * $aspectRatio)

    # Create new bitmap
    $newImg = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
    $graphics = [System.Drawing.Graphics]::FromImage($newImg)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($img, 0, 0, $targetWidth, $targetHeight)

    # Save
    $newImg.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Cleanup
    $graphics.Dispose()
    $newImg.Dispose()
    $img.Dispose()

    Write-Host "  Created: $outputPath ($targetWidth x $targetHeight)" -ForegroundColor Cyan
}

Write-Host "Processing macOS receiver screenshots (same UI as Windows)..." -ForegroundColor Yellow
# Copy macOS screenshots (receiver UI - same as Windows receiver)
$macScreenshots = Get-ChildItem "$sourceDir\macos\*.png" | Sort-Object Name
$counter = 1
foreach ($screenshot in $macScreenshots) {
    $outputFile = "$destDir\windows-receiver-$counter.png"
    Resize-Image -inputPath $screenshot.FullName -outputPath $outputFile -targetWidth 1920
    $counter++
}

Write-Host ""
Write-Host "Processing iOS controller screenshots..." -ForegroundColor Yellow
# Copy iOS screenshots (controller UI - shows what users control WITH)
$iosScreenshots = Get-ChildItem "$sourceDir\en-US\1_iphone67-*.png" | Sort-Object Name | Select-Object -First 3
$counter = 1
foreach ($screenshot in $iosScreenshots) {
    $outputFile = "$destDir\ios-controller-$counter.png"
    Resize-Image -inputPath $screenshot.FullName -outputPath $outputFile -targetWidth 1366
    $counter++
}

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Host "   Screenshots Ready for Upload!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Screenshots saved to: $destDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Upload these to Microsoft Store:" -ForegroundColor Yellow
Get-ChildItem $destDir -Filter "*.png" | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
}
Write-Host ""
Write-Host "Recommended upload order:" -ForegroundColor Yellow
Write-Host "1. windows-receiver-1.png (main Windows app screen)" -ForegroundColor White
Write-Host "2. ios-controller-1.png (iPhone controller)" -ForegroundColor White
Write-Host "3. ios-controller-2.png (joystick in action)" -ForegroundColor White
Write-Host "4. windows-receiver-2.png (alternative view)" -ForegroundColor White
Write-Host ""
