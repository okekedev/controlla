# AirType - Wireless Voice Keyboard + Mouse

AirType is a premium iOS app that turns your iPhone into a Bluetooth HID keyboard with built-in voice-to-text and mouse control capabilities.

## Features

- **True BLE HID Keyboard + Mouse** - No computer software needed, just pair in Bluetooth settings
- **Voice Mode** - Hold button to speak, words appear instantly on connected device
- **Keyboard Mode** - Type on screen with quick access keys (Space, Enter, Tab, Delete)
- **Mouse Mode** - Virtual joystick with left/right click buttons for cursor control
- **Auto-Reconnect** - Automatically reconnects after initial pairing
- **Beautiful UI** - Premium gradient design with smooth animations

## Requirements

- iOS 15.0 or later
- Xcode 16.4
- iPhone or iPad
- Device with Bluetooth support (Mac, iPad, Windows PC, etc.)

## Getting Started

### 1. Open the Project
1. Navigate to `AirType.xcodeproj` and open it in Xcode 16.4
2. Select your development team in the project settings
3. Connect your iPhone/iPad

### 2. Build and Run
1. Select your device as the build target
2. Click Run (Cmd+R) to build and install
3. Grant microphone and Bluetooth permissions when prompted

### 3. Pair with Your Device
1. On your Mac/PC/iPad, go to Bluetooth settings
2. Look for "AirType Keyboard" in available devices
3. Click to pair - no pairing code needed
4. Once connected, the app will show "Connected" status

### 4. Using Voice Mode
1. Ensure AirType shows "Connected"
2. Switch to "Voice" tab
3. Hold the circular button and speak
4. Release to send - your words will appear on the connected device
5. The app automatically adds spaces between phrases

### 5. Using Keyboard Mode
1. Switch to "Keyboard" tab
2. Type your message in the text field
3. Use quick keys for Space, Enter, Tab, or Delete
4. Tap "Send" to type everything on the connected device

### 6. Using Mouse Mode
1. Switch to "Mouse" tab
2. Drag the virtual joystick to move the cursor on your connected device
3. Tap "Left Click" button for left mouse clicks
4. Tap "Right Click" button for right mouse clicks (context menu)
5. The joystick automatically returns to center when released

## Technical Details

### Bluetooth HID Implementation
- Uses standard HID-over-GATT profile (Service UUID: 0x1812)
- Combo keyboard + mouse descriptor with Report IDs
- Keyboard reports: 9 bytes [ReportID, Modifier, Reserved, Key1-Key6]
- Mouse reports: 5 bytes [ReportID, Buttons, X, Y, Wheel]
- Device Information Service for maximum compatibility
- Encryption required for iOS security compliance

### Voice Recognition
- Real-time speech recognition using Apple's Speech framework
- Supports partial results for live feedback
- Automatic audio session management
- Background audio mode for continuous operation

### Mouse Control
- Virtual joystick with drag gesture recognition
- Smooth continuous movement with timer-based updates
- Configurable sensitivity (default 2.5x)
- Support for left, right, and middle mouse buttons
- Scroll wheel support (not exposed in current UI)

### Supported Characters
- All letters (a-z, A-Z)
- Numbers (0-9)
- Common punctuation and symbols
- Special keys: Space, Enter, Tab, Backspace

## Use Cases

- **Remote Control** - Type and control your Mac from across the room
- **iPad Keyboard + Mouse** - No need to carry a physical keyboard or mouse
- **Voice Dictation** - Dictate long emails or documents
- **Couch Computing** - Control your computer from the couch with joystick navigation
- **Backup Input** - Emergency keyboard and mouse when yours fails
- **Accessibility** - Voice input and joystick control for those who can't type
- **Presentations** - Navigate slides and type notes wirelessly

## Troubleshooting

**App not appearing in Bluetooth settings?**
- Make sure the app is open and shows "Advertising..."
- Try restarting Bluetooth on your device
- Ensure Bluetooth permissions are granted

**Voice recognition not working?**
- Grant microphone and speech recognition permissions in Settings > Privacy
- Check that your iPhone is not muted
- Ensure you have an internet connection (first-time speech recognition setup)

**Typed text not appearing on connected device?**
- Verify connection status shows "Connected"
- Some apps may need to be in focus to receive keyboard input
- Try clicking in a text field on the connected device

**Characters missing or wrong?**
- The keycode mapper supports US keyboard layout
- Some special characters may not be available
- International keyboards may behave differently

**Mouse not moving or moving too fast/slow?**
- Make sure you're in Mouse mode and connected
- Joystick sensitivity is set to 2.5x by default
- Try smaller/larger joystick movements
- Some systems may have mouse acceleration settings that affect feel

**Mouse clicks not registering?**
- Ensure the connected device is ready to receive input
- Try clicking in different areas or applications
- Some security-focused apps may block external mouse input

## Code Structure

```
AirType/
├── AirTypeApp.swift              # Main app entry point
├── ContentView.swift             # SwiftUI UI with Voice, Keyboard & Mouse modes
├── BLEHIDKeyboard.swift          # Bluetooth HID keyboard + mouse peripheral
├── HIDKeycodeMapper.swift        # Character to HID keycode conversion
├── SpeechRecognitionManager.swift # Voice-to-text engine
├── Assets.xcassets/              # App icons and colors
└── Info.plist                    # Permissions and configuration
```

## Privacy & Permissions

AirType requires:
- **Microphone** - For voice recognition in Voice mode
- **Speech Recognition** - To convert speech to text
- **Bluetooth** - To communicate as a HID keyboard + mouse

All voice processing happens on-device using Apple's Speech framework. No data is sent to external servers beyond Apple's speech recognition service.

## Known Limitations

- Voice recognition requires internet connection for initial setup
- Some complex Unicode characters not supported
- Typing speed limited by Bluetooth HID protocol (~50 chars/sec)
- Mouse movement speed depends on joystick sensitivity setting
- No modifier key combinations (Cmd+C, Ctrl+V, etc.) in current version

## Future Enhancements

- Custom keyboard shortcuts (Cmd+C, Ctrl+V, etc.)
- Adjustable mouse sensitivity slider
- Scroll wheel control in Mouse mode
- Multiple language support
- Emoji picker
- Text snippets and templates
- Multiple device pairing
- macOS companion app

## License

This is a demonstration project built for educational purposes.

## Support

For issues or questions, please check the troubleshooting section above or review the source code comments for implementation details.

---

**Built with Swift 6, SwiftUI, CoreBluetooth, and Speech framework**
**Optimized for iOS 15+ and Xcode 16.4**
