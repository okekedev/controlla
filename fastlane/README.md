# Controlla - Fastlane Automation

Automated App Store submission for Controlla.

## Prerequisites

1. **Apple Developer Account** (paid)
2. **App Store Connect access**
3. **Your credentials:**
   - Apple ID
   - Team ID (find at: https://developer.apple.com/account)

## Setup

### 1. Configure Your Apple ID

Set environment variables (recommended):

```bash
export APPLE_ID="your-apple-id@example.com"
export TEAM_ID="YOUR_TEAM_ID"
```

Or edit `Appfile` directly.

### 2. First-Time Setup

Create the app in App Store Connect:

```bash
fastlane setup
```

This will:
- Create the app listing
- Upload metadata
- Show subscription configuration instructions

### 3. Configure Subscription

Go to App Store Connect and configure:
- **Product ID:** `com.controlla.pro.monthly`
- **Subscription Group:** Controlla Pro
- **Price:** $0.99/month (Tier 1)
- **Free Trial:** 7 days
- **Family Sharing:** Enabled

Link: https://appstoreconnect.apple.com

## Usage

### Full Release

Build and upload to App Store:

```bash
fastlane release
```

You'll be prompted for:
- Version number (e.g., 1.0.0)
- Build number (e.g., 1)

### Beta Release

Upload to TestFlight:

```bash
fastlane beta
```

### Build Only

Just build the IPA:

```bash
fastlane build
```

### Upload Metadata Only

Update app description, keywords, etc:

```bash
fastlane upload_metadata
```

### Bump Version

Increment version and create git tag:

```bash
fastlane bump
```

## Files Structure

```
fastlane/
├── Appfile                          # Apple ID and app identifier
├── Fastfile                         # Automation lanes
├── README.md                        # This file
└── metadata/
    └── en-US/
        ├── name.txt                 # App name
        ├── subtitle.txt             # Subtitle (30 chars)
        ├── description.txt          # Full description
        ├── keywords.txt             # Keywords (comma-separated)
        ├── promotional_text.txt     # Promotional text (170 chars)
        ├── release_notes.txt        # What's new
        ├── support_url.txt          # Support URL
        ├── marketing_url.txt        # Marketing URL
        └── privacy_url.txt          # Privacy policy URL
```

## Troubleshooting

### Authentication Issues

```bash
fastlane fastlane-credentials remove --username your@email.com
fastlane release  # Will re-prompt for credentials
```

### Build Fails

1. Make sure Xcode is properly configured
2. Try: `fastlane build` to see detailed errors
3. Build manually in Xcode first to verify

### Upload Fails

- Check your Apple Developer account is active
- Verify certificates are valid
- Ensure app agreement is accepted in App Store Connect

## Next Steps

After `fastlane release`:

1. Go to App Store Connect
2. Add screenshots (manual for now)
3. Select build
4. Submit for review

## Support

Questions? Contact: https://sundai.us/support
