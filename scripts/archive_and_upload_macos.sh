#!/bin/bash
set -e

echo "======================================================================"
echo "  Mac Controlla - macOS Archive and Upload"
echo "======================================================================"

echo ""
echo "🔨 Building macOS archive with automatic signing..."
xcodebuild archive \
  -project AirType.xcodeproj \
  -scheme AirType \
  -configuration Release \
  -archivePath build/Controlla-macOS.xcarchive \
  -destination "generic/platform=macOS" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=TUG3BHLSM4 \
  CODE_SIGN_ENTITLEMENTS=AirType/AirType-macOS.entitlements \
  ENABLE_APP_SANDBOX=YES \
  -allowProvisioningUpdates

echo ""
echo "📦 Exporting for Mac App Store..."
xcodebuild -exportArchive \
  -archivePath build/Controlla-macOS.xcarchive \
  -exportPath build/macos \
  -exportOptionsPlist ExportOptions-macOS.plist \
  -allowProvisioningUpdates

echo ""
echo "⬆️  Uploading macOS app to App Store Connect..."
export API_PRIVATE_KEYS_DIR="./fastlane"
xcrun altool \
  --upload-app \
  -f build/macos/*.pkg \
  --type macos \
  --apiKey 3M7GV93JWG \
  --apiIssuer 196f43aa-4520-4178-a7df-68db3cf7ee76

echo ""
echo "✅ macOS upload complete!"
echo "   Check App Store Connect in 5-10 minutes for build processing"
