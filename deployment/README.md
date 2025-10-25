# Deployment System - Technical Documentation

App Store Connect automation using the official API.

## System Overview

**Language**: Python 3
**API**: App Store Connect REST API (v1)
**Authentication**: JWT with API key

**What's Automated**:
- Bundle ID registration
- Metadata upload (text, URLs)
- Screenshot upload (iOS and macOS)
- Build attachment
- App review detail configuration
- Subscription creation

**Not Automated** (Apple API limitations):
- App privacy settings
- Age rating
- Final submission

---

## Module Structure

```
deployment/
├── api.py              # Base API client with JWT auth
├── config.py           # API credentials
├── bundle.py           # Bundle ID registration
├── metadata.py         # Metadata upload to version localizations
├── screenshots.py      # Screenshot upload with chunked transfer
├── version.py          # Version and build management
└── build.py            # Build attachment helpers
```

### api.py
Core HTTP client for App Store Connect API.

**Methods**:
- `get(endpoint)` - GET request
- `post(endpoint, data)` - POST request
- `patch(endpoint, data)` - PATCH request
- `delete(endpoint)` - DELETE request

**Authentication**: JWT token generated from:
- Private key (`AuthKey_*.p8`)
- Key ID and Issuer ID
- Token valid for 20 minutes

### screenshots.py
Handles screenshot upload via multi-step process.

**Display Types**:
- `APP_IPHONE_69` - iPhone 6.9" (1320x2868)
- `APP_IPHONE_61` - iPhone 6.1" (1179x2556)
- `APP_IPAD_PRO_129` - iPad Pro 12.9" (2048x2732)
- `APP_DESKTOP` - macOS (1440x900)

**Upload Process**:
1. Get version localization ID
2. Create/find screenshot set for display type
3. Reserve screenshot slot (POST `/appScreenshots`)
4. Upload file chunks to signed URLs (PUT)
5. Commit with checksum (PATCH `/appScreenshots/{id}`)

**File Naming**:
- iOS: `1_iphone67-*.png`, `2_iphone61-*.png`, `3_ipad-*.png`
- macOS: `4_mac-*.png`

### metadata.py
Uploads app metadata to version-level localizations.

**Endpoints**:
- `GET /apps/{id}/appStoreVersions` - Find version
- `GET /appStoreVersions/{id}/appStoreVersionLocalizations` - Get localization
- `PATCH /appStoreVersionLocalizations/{id}` - Update metadata

**Metadata Fields**:
- `name` - App name (30 chars max)
- `subtitle` - Subtitle (30 chars max)
- `description` - Full description
- `keywords` - Comma-separated (100 chars max)
- `promotionalText` - Featured text (170 chars max)
- `supportURL` - Support website

---

## Build Scripts

### archive_and_upload.sh (iOS)
```bash
xcodebuild archive \
  -project AirType.xcodeproj \
  -scheme AirType \
  -destination "generic/platform=iOS" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=TUG3BHLSM4

xcodebuild -exportArchive \
  -exportOptionsPlist ExportOptions-iOS.plist

xcrun altool --upload-app \
  --type ios \
  --apiKey 3M7GV93JWG \
  --apiIssuer 196f43aa-4520-4178-a7df-68db3cf7ee76
```

### archive_and_upload_macos.sh (macOS)
```bash
xcodebuild archive \
  -destination "generic/platform=macOS" \
  CODE_SIGN_ENTITLEMENTS=AirType/AirType-macOS.entitlements \
  ENABLE_APP_SANDBOX=YES

xcodebuild -exportArchive \
  -exportOptionsPlist ExportOptions-macOS.plist
```

**Key Differences**:
- macOS requires entitlements file
- macOS requires `ENABLE_APP_SANDBOX=YES`
- macOS exports as `.pkg` instead of `.ipa`

---

## Configuration

### API Credentials (config.py)
```python
KEY_ID = "3M7GV93JWG"
ISSUER_ID = "196f43aa-4520-4178-a7df-68db3cf7ee76"
KEY_FILE = "fastlane/AuthKey_3M7GV93JWG.p8"
BASE_URL = "https://api.appstoreconnect.apple.com/v1"
```

### App Info
- Bundle ID: `com.christianokeke.maccontrolla`
- Team ID: `TUG3BHLSM4`
- App ID: `6754469628`

---

## Usage

### Full Deployment
```bash
# iOS
./scripts/archive_and_upload.sh
python3 scripts/deploy.py --screenshots

# macOS
./scripts/archive_and_upload_macos.sh
python3 scripts/upload_macos_screenshots.py
```

### Individual Commands
```bash
# Metadata only
python3 scripts/deploy.py --metadata

# Screenshots only
python3 scripts/deploy.py --screenshots           # iOS
python3 scripts/upload_macos_screenshots.py       # macOS

# Setup only (bundle ID)
python3 scripts/deploy.py --setup
```

---

## API Endpoints Used

### Apps
- `GET /apps` - List apps
- `GET /apps/{id}/appStoreVersions` - Get versions

### Versions
- `POST /appStoreVersions` - Create version
- `PATCH /appStoreVersions/{id}` - Update version
- `GET /appStoreVersions/{id}/appStoreVersionLocalizations` - Get localizations

### Builds
- `GET /apps/{id}/builds` - List builds
- `POST /buildBetaDetails` - Create beta detail
- `POST /betaBuildLocalizations` - Create beta localization
- `PATCH /appStoreVersions/{id}/relationships/build` - Attach build

### Screenshots
- `POST /appScreenshotSets` - Create screenshot set
- `GET /appScreenshotSets/{id}/appScreenshots` - List screenshots
- `POST /appScreenshots` - Reserve screenshot slot
- `PATCH /appScreenshots/{id}` - Commit upload
- `DELETE /appScreenshots/{id}` - Delete screenshot

### Subscriptions
- `POST /subscriptionGroups` - Create group
- `POST /subscriptions` - Create subscription

### Review
- `POST /appStoreReviewDetails` - Create review detail
- `PATCH /appStoreReviewDetails/{id}` - Update review detail

---

## Error Handling

Common errors and solutions:

### 409 Conflict
Resource already exists - check if it can be reused or needs deletion.

### 401 Unauthorized
JWT token expired or invalid - regenerate token.

### 422 Unprocessable Entity
Invalid data format - check required fields and character limits.

### Platform Filtering Required
When querying versions, always filter by platform:
```python
api.get(f"apps/{app_id}/appStoreVersions?filter[platform]=IOS")
```

---

## Limitations

**Cannot be automated via API**:
- App Privacy questionnaire
- Age Rating questionnaire
- Subscription pricing configuration
- Intro offer configuration
- **Intro offer localization** (Display Name, Description) - API can create offers but not localize them
- Final "Submit for Review" button

These must be completed manually in App Store Connect.

**Research Note (Oct 2025)**: The App Store Connect API includes endpoints for reading and creating subscription introductory offers (`GET /v1/subscriptions/{id}/introductoryOffers`), but does not support creating or updating localizations for those offers. Localization must be added manually in App Store Connect UI.

---

## Security Notes

- API key file (`AuthKey_*.p8`) should never be committed to git
- JWT tokens expire after 20 minutes
- All requests use HTTPS
- API key has full App Store Connect access - protect it carefully
