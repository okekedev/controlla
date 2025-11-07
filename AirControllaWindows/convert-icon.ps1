Add-Type -AssemblyName System.Drawing

$baseDir = "C:\Users\Christian Okeke\Desktop\controlla"
$pngPath = Join-Path $baseDir "AirType\Assets.xcassets\AppIcon.appiconset\icon_256x256.png"
$icoPath = Join-Path $baseDir "AirControllaWindows\AirControllaWindows\icon.ico"

$img = [System.Drawing.Image]::FromFile($pngPath)
$bmp = New-Object System.Drawing.Bitmap $img
$icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())

$fs = [System.IO.File]::Create($icoPath)
$icon.Save($fs)
$fs.Close()

$img.Dispose()
$bmp.Dispose()

Write-Host "Icon created successfully at $icoPath"
