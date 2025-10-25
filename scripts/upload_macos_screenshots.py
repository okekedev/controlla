#!/usr/bin/env python3
"""Upload macOS screenshots to App Store Connect"""

import sys
sys.path.insert(0, 'deployment')

from deployment.api import AppStoreAPI
from deployment.screenshots import upload_screenshots

# Initialize API
api = AppStoreAPI()

# Get app ID (bundle ID is the same for iOS and macOS)
print("🔍 Finding app...")
apps = api.get("apps?filter[bundleId]=com.christianokeke.maccontrolla")

if not apps.get("data"):
    print("❌ App not found")
    sys.exit(1)

app_id = apps["data"][0]["id"]
bundle_id = apps["data"][0]["attributes"]["bundleId"]
print(f"✅ Found app: {bundle_id} ({app_id})")

# Get macOS version
print("\n🔍 Getting macOS version...")
versions = api.get(f"apps/{app_id}/appStoreVersions?filter[platform]=MAC_OS")

if not versions.get("data"):
    print("❌ No macOS version found")
    sys.exit(1)

mac_version_id = versions["data"][0]["id"]
version_string = versions["data"][0]["attributes"]["versionString"]
print(f"✅ Found version: {version_string} ({mac_version_id})")

# Upload screenshots
print("\n📸 Uploading macOS screenshots...")
success = upload_screenshots(api, mac_version_id, "fastlane/screenshots/macos")

if success:
    print("\n✅ macOS screenshots uploaded successfully!")
else:
    print("\n❌ Some screenshots failed to upload")
    sys.exit(1)
