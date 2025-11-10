# PowerShell script to build MSIX package for Microsoft Store submission
# Run this after Windows SDK is installed

Write-Host "Building AirControlla MSIX Package..." -ForegroundColor Green
Write-Host ""

# Step 1: Build the app
Write-Host "Step 1: Building Release version..." -ForegroundColor Cyan
Set-Location ".\AirControllaWindows"
dotnet publish -c Release -r win-x64 -p:SelfContained=true -p:PublishSingleFile=false

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green
Write-Host ""

# Step 2: Find makeappx.exe from Windows SDK
Write-Host "Step 2: Locating Windows SDK tools..." -ForegroundColor Cyan

$sdkPath = "C:\Program Files (x86)\Windows Kits\10\bin"
if (Test-Path $sdkPath) {
    $versions = Get-ChildItem $sdkPath | Where-Object { $_.Name -match '^\d+\.\d+' } | Sort-Object Name -Descending
    if ($versions.Count -gt 0) {
        $latestVersion = $versions[0].Name
        $makeappx = "$sdkPath\$latestVersion\x64\makeappx.exe"

        if (Test-Path $makeappx) {
            Write-Host "✅ Found makeappx.exe at: $makeappx" -ForegroundColor Green
        } else {
            Write-Host "❌ makeappx.exe not found. Please install Windows SDK." -ForegroundColor Red
            Write-Host "Download from: https://developer.microsoft.com/windows/downloads/windows-sdk/" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "❌ No Windows SDK version found." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Windows SDK not installed." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Prepare package directory
Write-Host "Step 3: Preparing package directory..." -ForegroundColor Cyan

$publishDir = "bin\Release\net8.0-windows10.0.19041.0\win-x64\publish"
$packageDir = "bin\Release\MSIXPackage"
$outputMsix = "bin\Release\AirControlla.msix"

# Create package directory structure
if (Test-Path $packageDir) {
    Remove-Item $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null

# Copy published files
Copy-Item -Path "$publishDir\*" -Destination $packageDir -Recurse -Force

# Copy manifest and assets (rename to AppxManifest.xml as required by makeappx)
Copy-Item "Package.appxmanifest" -Destination "$packageDir\AppxManifest.xml" -Force
Copy-Item -Path "Assets" -Destination $packageDir -Recurse -Force

Write-Host "✅ Package directory prepared" -ForegroundColor Green
Write-Host ""

# Step 4: Create MSIX package
Write-Host "Step 4: Creating MSIX package..." -ForegroundColor Cyan

& $makeappx pack /d $packageDir /p $outputMsix /o

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ MSIX packaging failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ MSIX package created successfully!" -ForegroundColor Green
Write-Host ""

# Show results
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Host "   MSIX Package Ready for Upload!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Package location:" -ForegroundColor Cyan
Write-Host "  $outputMsix" -ForegroundColor White
Write-Host ""
$fileInfo = Get-Item $outputMsix
Write-Host "Package size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Go to Partner Center: https://partner.microsoft.com/dashboard/apps-and-games/overview"
Write-Host "2. Open your 'AirControlla for PC' app"
Write-Host "3. Click 'Start submission'"
Write-Host "4. Upload this MSIX file in the 'Packages' section"
Write-Host ""
