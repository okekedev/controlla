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

- **Free**: Virtual joystick mouse control
- **Pro ($0.99/month)**: Text input + Keyboard actions + Mouse clicks
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

## Code Structure

```
AirType/
├── AirTypeApp.swift          # Main app entry point
├── ContentView.swift         # SwiftUI UI with tabs and joystick
├── NetworkManager.swift      # WiFi networking and Bonjour
├── InputSimulator.swift      # Mac input simulation (CGEvent)
├── HIDKeycodeMapper.swift    # Character to keycode mapping
├── Assets.xcassets/          # App icons and colors
└── Info.plist               # Permissions and configuration
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

## Future Enhancements

- StoreKit 2 subscription system
- Voice-to-text input
- Clipboard sharing
- Custom keyboard shortcuts
- Multiple device support
- Windows receiver support

## License

Proprietary - All rights reserved

## Support

Built with Swift 6, SwiftUI, Network framework, and CoreGraphics.

---

**Optimized for iOS 15+ / macOS 12+ and Xcode 16.4**
