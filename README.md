# Controlla - Wireless Keyboard + Mouse Controller

Controlla turns your iPhone or iPad into a wireless keyboard and mouse for your Mac over WiFi. Control your computer from anywhere in the room with smooth joystick navigation, text input, and mouse clicks.

## Features

- **Virtual Joystick Mouse Control** - Smooth, game-controller-like cursor movement
- **Text Input** - Type on your Mac from your iPhone/iPad
- **Mouse Clicks** - Left and right click buttons
- **Keyboard Actions** - Quick access to Enter, Backspace, and Space
- **Auto-Discovery** - Finds your Mac automatically via Bonjour
- **Persistent Connection** - Low-latency TCP connection for real-time control
- **Cross-Platform** - Universal app for iPhone, iPad, and Mac

## Monetization (Freemium)

- **Free**: Virtual joystick + Mouse clicks (L/R buttons) - Full mouse control
- **Pro ($0.99/month)**: Text input + Keyboard actions (Enter, Backspace, Space)
- **7-day free trial** of Pro features
- **Family Sharing** supported

## Platform Support

- **Controller**: iPhone, iPad, Mac
- **Receiver**: Mac only

## Requirements

- iOS 15.0+ or macOS 12.0+
- Xcode 16.4
- WiFi network (devices must be on same network)

## Architecture

### WiFi Protocol
- **Service Discovery**: Bonjour (_controlla._tcp)
- **Communication**: HTTP over persistent TCP connection
- **Port**: Auto-assigned by OS
- **Endpoints**: `/keyboard/text`, `/keyboard/key`, `/mouse/move`, `/mouse/click`

### Key Components
- **NetworkManager.swift** - Handles Bonjour discovery, TCP connections, and command sending
- **InputSimulator.swift** - Simulates keyboard/mouse input on Mac using CoreGraphics
- **ContentView.swift** - SwiftUI UI with Controller and Receiver modes
- **HIDKeycodeMapper.swift** - Character to HID keycode conversion

### Joystick Features
- x^4.5 acceleration curve for extended low-speed precision
- 0.6-43 pixels per update (25ms intervals)
- Sub-pixel accumulation for smooth movement
- Send throttling to prevent queue buildup
- Velocity smoothing (35%) for consistent feel

## Project Structure

```
controlla/
├── AirType/                  # Main app source code
│   ├── ContentView.swift    # SwiftUI UI with tabs and joystick
│   ├── NetworkManager.swift # WiFi networking and Bonjour
│   ├── InputSimulator.swift # Mac input simulation
│   └── PaywallView.swift    # Subscription paywall
│
├── deployment/               # App Store deployment automation
│   ├── api.py               # App Store Connect API client
│   ├── metadata.py          # Metadata upload
│   ├── screenshots.py       # Screenshot upload
│   ├── metadata/            # App Store text content
│   ├── screenshots/         # iOS and macOS screenshots
│   └── AuthKey_*.p8         # API key (gitignored)
│
├── scripts/                  # Build and deployment scripts
│   ├── archive_and_upload.sh         # iOS build
│   ├── archive_and_upload_macos.sh   # macOS build
│   ├── deploy.py                     # Metadata/screenshot automation
│   └── upload_macos_screenshots.py   # macOS screenshot upload
│
├── docs/                     # GitHub Pages website
│   ├── index.html           # Landing page
│   ├── privacy.html         # Privacy Policy
│   └── terms.html           # Terms of Use
│
├── DEPLOYMENT.md             # Complete deployment guide
├── NEXT_STEPS.md             # Submission checklist
└── README.md                 # This file
```

## Getting Started

### Mac (Receiver)
1. Build and run on Mac
2. Switch to "App Mode" tab
3. Select "Receiver" mode
4. Grant Accessibility permissions when prompted
5. App will show "Ready - [Your Mac Name]"

### iPhone/iPad (Controller)
1. Build and run on iPhone/iPad
2. Ensure you're on the same WiFi as your Mac
3. Go to "Devices" tab
4. Select your Mac from the discovered devices list
5. Use the joystick, text input, and buttons to control your Mac

## Technical Details

### macOS Accessibility Permissions
The Mac receiver requires Accessibility permissions to simulate keyboard and mouse input. The app will prompt you to grant this on first launch.

### Network Security
- Only works on same WiFi network
- No internet connection required
- No data leaves local network
- Bonjour service automatically secured by WiFi encryption

### Input Simulation
- **Keyboard**: CGEvent API with HID keycode mapping
- **Mouse Movement**: Relative delta positioning
- **Mouse Clicks**: CGEvent mouse button simulation
- **Coordinate System**: Top-left origin (standard macOS screen coordinates)

## App Store Deployment

Automated deployment system using App Store Connect API:

```bash
# Build iOS and macOS
./scripts/archive_and_upload.sh
./scripts/archive_and_upload_macos.sh

# Upload screenshots and metadata
python3 scripts/deploy.py --screenshots
python3 scripts/upload_macos_screenshots.py
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete guide and [NEXT_STEPS.md](NEXT_STEPS.md) for submission checklist.

## GitHub Pages Setup

The `docs/` folder contains the website hosted at https://okekedev.github.io/controlla/

**To enable:**
1. Push to GitHub
2. Go to Settings → Pages
3. Source: Deploy from branch `main` / folder `/docs`
4. URLs:
   - Privacy: https://okekedev.github.io/controlla/privacy.html
   - Terms: https://okekedev.github.io/controlla/terms.html

These URLs are required for App Store submission.

## License

**Source Available - Commercial Software**

This source code is publicly available for transparency and educational purposes.
See [LICENSE](LICENSE) for details.

**TL;DR:**
- ✅ View, study, and learn from the code
- ✅ Report bugs and contribute improvements
- ✅ Use for educational purposes
- ❌ Commercial use or redistribution
- ❌ Publishing competing apps
- ❌ Using the "Controlla" trademark

For commercial licensing inquiries, contact: https://sundai.us

## Support

Built with Swift 6, SwiftUI, Network framework, and CoreGraphics.

---

**Optimized for iOS 15+ / macOS 12+ and Xcode 16.4**
