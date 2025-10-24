# Controlla Deployment System

TRUE automation for App Store submissions using the App Store Connect API (2025).

## What's Automated

✅ **Bundle ID Registration** - Automatic via API
✅ **Metadata Upload** - Description, keywords, URLs, etc.
✅ **Build Creation** - xcodebuild automation
✅ **Build Upload** - altool with JWT authentication
✅ **Version Management** - Create versions via API
✅ **Review Submission** - Submit for App Store review

⚠️ **One-Time Manual Step**: Creating the app in App Store Connect (Apple API limitation)

## Setup

### 1. Install Dependencies

```bash
pip3 install 'PyJWT[crypto]' cryptography requests
```

### 2. Configure API Key

API key is already configured in `deployment/config.py`:
- Key ID: `3M7GV93JWG`
- Issuer ID: `196f43aa-4520-4178-a7df-68db3cf7ee76`
- Key File: `fastlane/AuthKey_3M7GV93JWG.p8`

### 3. Create App (One-Time)

Since Apple's API doesn't support `POST /v1/apps`, you must create the app manually:

1. Go to https://appstoreconnect.apple.com
2. My Apps → + → New App
3. Name: **Controlla**
4. Bundle ID: **com.christianokeke.Controlla** (will be in dropdown after running setup)
5. SKU: **controlla-2025**

## Usage

### Full Deployment

```bash
./deploy.py
```

This runs the complete workflow:
1. Registers bundle ID (if needed)
2. Verifies app exists
3. Uploads metadata
4. Prompts for version/build numbers
5. Builds IPA
6. Uploads to App Store Connect
7. Creates version
8. Optionally submits for review

### Setup Only

```bash
./deploy.py --setup
```

Registers bundle ID and verifies app exists. Run this first to check everything is configured.

### Metadata Only

```bash
./deploy.py --metadata
```

Uploads metadata from `fastlane/metadata/en-US/` without building.

### Build Only

```bash
./deploy.py --build 1.0.0 1
```

Builds and uploads version 1.0.0 build 1.

## Architecture

```
deployment/
├── __init__.py          # Module exports
├── api.py               # App Store Connect API client (JWT auth)
├── bundle.py            # Bundle ID registration
├── build.py             # Xcode build & altool upload
├── metadata.py          # Metadata upload
├── version.py           # Version creation & review submission
└── config.py            # Configuration

deploy.py                # Main entry point
```

## How It Works

### Authentication

Uses JWT (JSON Web Token) with App Store Connect API key:

```python
from deployment import AppStoreAPI

api = AppStoreAPI()  # Auto-generates JWT from .p8 file
result = api.get("apps?filter[bundleId]=com.christianokeke.Controlla")
```

### Bundle ID Registration

```python
POST /v1/bundleIds
{
  "data": {
    "type": "bundleIds",
    "attributes": {
      "name": "Controlla",
      "identifier": "com.christianokeke.Controlla",
      "platform": "IOS"
    }
  }
}
```

### Build Upload

Uses `altool` with API key authentication:

```bash
xcrun altool --upload-app \
  -f build/AirType.ipa \
  --apiKey 3M7GV93JWG \
  --apiIssuer 196f43aa-4520-4178-a7df-68db3cf7ee76
```

### Version Creation

```python
POST /v1/appStoreVersions
{
  "data": {
    "type": "appStoreVersions",
    "attributes": {"versionString": "1.0.0"},
    "relationships": {
      "app": {"data": {"type": "apps", "id": app_id}}
    }
  }
}
```

## Metadata Files

Metadata is read from `fastlane/metadata/en-US/`:

- `name.txt` - App name
- `subtitle.txt` - Subtitle
- `description.txt` - Full description
- `keywords.txt` - Keywords (comma-separated)
- `promotional_text.txt` - Promotional text
- `release_notes.txt` - What's new
- `privacy_url.txt` - Privacy policy URL
- `support_url.txt` - Support URL
- `marketing_url.txt` - Marketing URL

## Troubleshooting

### "Bundle ID not found"
Run `./deploy.py --setup` first to register the bundle ID.

### "App not found"
You need to create the app manually in App Store Connect (one-time step).

### Build upload fails
Check that:
- Xcode is installed
- Signing certificates are valid
- App Store Connect agreement is accepted

### API authentication fails
Verify the API key file exists at `fastlane/AuthKey_3M7GV93JWG.p8`.

## Future Enhancements

- Screenshot upload automation
- Subscription management
- TestFlight distribution
- Webhook integration for build status
- Multi-platform support (macOS, tvOS)
