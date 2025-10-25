# Mac Controlla - App Store Deployment Guide

Simple guide for deploying iOS and macOS apps to App Store Connect using automation.

## Quick Deploy (First Time)

```bash
# 1. iOS Build
./scripts/archive_and_upload.sh

# 2. macOS Build
./scripts/archive_and_upload_macos.sh

# 3. Upload iOS screenshots
python3 scripts/deploy.py --screenshots

# 4. Upload macOS screenshots (if you have new ones)
python3 scripts/upload_macos_screenshots.py
```

Then complete manual steps in App Store Connect (see below).

---

## File Structure

```
AirType/
├── scripts/                           # Deployment scripts
│   ├── archive_and_upload.sh         # Build iOS app
│   ├── archive_and_upload_macos.sh   # Build macOS app
│   ├── deploy.py                     # Metadata/screenshot automation
│   ├── upload_macos_screenshots.py   # macOS screenshot upload
│   ├── ExportOptions.plist           # iOS export config
│   └── ExportOptions-macOS.plist     # macOS export config
│
├── deployment/                        # API modules
│   ├── api.py                        # App Store Connect API client
│   ├── bundle.py                     # Bundle ID registration
│   ├── metadata.py                   # Metadata upload
│   ├── screenshots.py                # Screenshot upload
│   ├── version.py                    # Version management
│   └── config.py                     # API credentials
│
├── fastlane/
│   ├── AuthKey_3M7GV93JWG.p8        # API key (private)
│   ├── metadata/en-US/              # App Store text files
│   │   ├── name.txt
│   │   ├── subtitle.txt
│   │   ├── description.txt
│   │   ├── keywords.txt
│   │   ├── promotional_text.txt
│   │   └── support_url.txt
│   │
│   └── screenshots/
│       ├── en-US/                   # iOS screenshots
│       │   ├── 1_iphone67-*.png    # iPhone 6.9" (1320x2868)
│       │   ├── 2_iphone61-*.png    # iPhone 6.1" (1179x2556)
│       │   └── 3_ipad-*.png        # iPad Pro (2048x2732)
│       │
│       └── macos/                   # macOS screenshots
│           └── 4_mac-*.png          # Desktop (1440x900)
│
└── AirType/
    ├── Info.plist                    # App configuration
    └── AirType-macOS.entitlements   # macOS sandbox config
```

---

## Commands

### Build iOS App
```bash
./scripts/archive_and_upload.sh
```
Archives iOS app with automatic signing and uploads to App Store Connect.

### Build macOS App
```bash
./scripts/archive_and_upload_macos.sh
```
Archives macOS app with sandbox enabled and uploads to App Store Connect.

### Upload Metadata
```bash
python3 scripts/deploy.py --metadata
```
Uploads app name, description, keywords, etc. from `fastlane/metadata/en-US/`.

### Upload iOS Screenshots
```bash
python3 scripts/deploy.py --screenshots
```
Uploads all iOS screenshots to App Store Connect automatically.

### Upload macOS Screenshots
```bash
python3 scripts/upload_macos_screenshots.py
```
Uploads all macOS screenshots from `fastlane/screenshots/macos/`.

---

## Screenshot Requirements

### iOS
- **iPhone 6.9" Display** (1320x2868) - Required
- **iPhone 6.1" Display** (1179x2556) - Required
- **iPad Pro 12.9"** (2048x2732) - Required

Name files: `1_iphone67-1.png`, `2_iphone61-1.png`, `3_ipad-1.png`

### macOS
- **Desktop Display** (1440x900 or 2880x1800) - Required

Name files: `4_mac-1.png`, `4_mac-2.png`, etc.

---

## Manual Steps (App Store Connect)

These cannot be automated via API:

1. **App Privacy** - Configure data collection settings
2. **Age Rating** - Set to 4+
3. **Subscription Setup**:
   - Configure pricing ($0.99/month)
   - Set up 7-day free trial (introductory offer)
   - **Add localization for introductory offer** (Display Name: "7-Day Free Trial", Description: "Try all Pro features free for 7 days")
   - Add review screenshot
4. **Subscription Linking** - Add subscription to In-App Purchases section for both iOS and macOS versions
5. **Submit for Review** - Click submit button

**Note**: Subscription introductory offer localization cannot be automated via API as of Oct 2025. The API supports reading/creating offers but not localizing them. This must be done manually in App Store Connect.

---

## Configuration

### API Credentials (`deployment/config.py`)
- Key ID: `3M7GV93JWG`
- Issuer ID: `196f43aa-4520-4178-a7df-68db3cf7ee76`
- Key file: `fastlane/AuthKey_3M7GV93JWG.p8`

### App Info
- Bundle ID: `com.christianokeke.maccontrolla`
- Team ID: `TUG3BHLSM4`
- iOS App ID: `6754469628`
- Subscription: Monthly ($0.99) with 7-day trial

### Contact Info (App Review)
- Name: Christian Okeke
- Phone: +1 940 337 6016
- Email: okekec21@gmail.com

---

## Updating for New Version

When releasing version 1.1:

```bash
# 1. Update version in Xcode project

# 2. Build iOS
./scripts/archive_and_upload.sh

# 3. Build macOS
./scripts/archive_and_upload_macos.sh

# 4. Upload new screenshots (if changed)
python3 scripts/deploy.py --screenshots
python3 scripts/upload_macos_screenshots.py

# 5. Update metadata (if changed)
python3 scripts/deploy.py --metadata

# 6. Submit in App Store Connect
```

---

## Troubleshooting

### Build fails
- Run: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
- Check signing certificates are valid in Xcode

### Screenshot upload fails
- Verify screenshots exist in correct folders
- Check file naming: `1_iphone67-*.png`, `2_iphone61-*.png`, `3_ipad-*.png`, `4_mac-*.png`
- Ensure version is in PREPARE_FOR_SUBMISSION state

### API authentication fails
- Verify `fastlane/AuthKey_3M7GV93JWG.p8` exists
- Check API key is valid in App Store Connect → Users and Access → Keys

---

## Current Status (Oct 25, 2025)

### iOS Version 1.0
- ✅ Build uploaded (Build 1)
- ✅ Screenshots uploaded (11 screenshots)
- ✅ Metadata uploaded
- ✅ App Review Detail configured
- ✅ Subscription created ($0.99/month, 7-day trial)
- ⚠️ Ready to submit (after linking subscription)

### macOS Version 1.0
- ✅ Build uploaded (Build 1)
- ✅ Screenshots uploaded (3 screenshots)
- ✅ Metadata uploaded
- ✅ App Review Detail configured
- ⚠️ Ready to submit (after linking subscription)

---

**Next**: Link subscription to both versions in App Store Connect, then submit for review.
