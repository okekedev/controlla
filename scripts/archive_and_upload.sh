#!/bin/bash
set -e

echo "======================================================================"
echo "  Mac Controlla - Archive and Upload to App Store Connect"
echo "======================================================================"

echo ""
echo "🔨 Building archive with automatic signing..."
xcodebuild archive \
  -project AirType.xcodeproj \
  -scheme AirType \
  -configuration Release \
  -archivePath build/Controlla.xcarchive \
  -destination "generic/platform=iOS" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=TUG3BHLSM4

echo ""
echo "📦 Exporting for App Store with automatic signing..."
xcodebuild -exportArchive \
  -archivePath build/Controlla.xcarchive \
  -exportPath build \
  -exportOptionsPlist scripts/ExportOptions.plist \
  -allowProvisioningUpdates

echo ""
echo "⬆️  Uploading to App Store Connect..."
export API_PRIVATE_KEYS_DIR="./deployment"
xcrun altool \
  --upload-app \
  -f build/AirType.ipa \
  --type ios \
  --apiKey 3M7GV93JWG \
  --apiIssuer 196f43aa-4520-4178-a7df-68db3cf7ee76

echo ""
echo "✅ Upload complete!"
echo "   Check App Store Connect in 5-10 minutes for build processing"
