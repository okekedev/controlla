# AirControlla for Windows

Windows receiver app for AirControlla - allows you to control your Windows PC from your iPhone.

## Download

**[Download AirControlla.exe from Releases](https://github.com/okekedev/controlla/releases)**

Just download and run - no installation required!

## Prerequisites for Building

1. **Windows 10/11 PC**
2. **.NET 8.0 SDK**
   - Download: https://dotnet.microsoft.com/download/dotnet/8.0
   - Or use Visual Studio 2022 (includes .NET SDK)

## Quick Start

### Using Pre-built Executable
1. Download `AirControlla.exe` from releases
2. Run the executable
3. Allow Windows Firewall access when prompted
4. The app will show "Receiver Mode" - ready to connect!

### Building from Source

```bash
cd AirControllaWindows/AirControllaWindows
dotnet restore
dotnet build
dotnet run
```

### Creating Distributable .exe

```bash
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:EnableCompressionInSingleFile=true
```

Output: `bin/Release/net8.0-windows/win-x64/publish/AirControlla.exe`

## NuGet Packages

The project uses:
- `Makaretu.Dns.Multicast` - mDNS/Bonjour service advertising
- `InputSimulatorCore` - Keyboard/mouse input simulation
- `Newtonsoft.Json` - JSON parsing

## Architecture

The Windows app mirrors the macOS receiver implementation:

```
iPhone (Controller) → WiFi Network → Windows PC (Receiver)
                                      ↓
                                  Raw TCP Listener
                                      ↓
                                  Simulates Input
```

### Components:

1. **NetworkManager.cs** - Raw TCP listener + mDNS advertising
   - Uses `TcpListener` for persistent connections
   - Manually parses HTTP requests (matches macOS NWConnection approach)
   - Advertises via `Makaretu.Dns.Multicast`

2. **InputSimulator.cs** - Windows input simulation
   - Uses `InputSimulatorCore` for keyboard/mouse
   - Uses Win32 API for precise mouse positioning

3. **MainWindow.xaml/.cs** - WPF UI
   - Centered design matching macOS receiver
   - Real-time connection status
   - Desktop icon and clean blue theme

## Files in This Folder

- `NetworkManager.cs` - Network handling (mDNS + HTTP server)
- `InputSimulator.cs` - Windows input simulation
- `MainWindow.xaml` - UI layout
- `MainWindow.xaml.cs` - UI code-behind
- `App.xaml` - Application entry point

## How It Works

1. App starts and advertises itself via Bonjour as `_controlla._tcp`
2. iPhone app discovers it on the network
3. iPhone sends HTTP POST requests with commands
4. Windows app simulates keyboard/mouse input

## Differences from macOS Version

| Feature | macOS | Windows |
|---------|-------|---------|
| Network Stack | NWListener (Network.framework) | TcpListener (.NET) |
| mDNS/Bonjour | Built-in (Network.framework) | Makaretu.Dns.Multicast |
| Input Simulation | CGEvent API | InputSimulatorCore + Win32 API |
| UI Framework | SwiftUI | WPF (XAML) |
| Permissions | Accessibility | Firewall + Administrator |

Both implementations use:
- Raw TCP connections with manual HTTP parsing
- Same endpoint structure (`/keyboard/text`, `/mouse/move`, etc.)
- Same JSON payload format
- Persistent connections for low latency

## Testing

1. Build and run the Windows app
2. Launch AirControlla on iPhone (same WiFi network)
3. Switch to Controller mode
4. Windows PC should appear in device list
5. Connect and test joystick, keyboard, voice input

## Distribution

- Build as standalone .exe
- Package with installer (e.g., Inno Setup, WiX)
- Or distribute via Microsoft Store

## Important Notes

### Firewall Access
- Windows will prompt for firewall access on first run - **you must allow it**
- The app needs incoming connections on port 8080 (auto-assigned)
- If blocked, the iPhone won't be able to send commands

### Administrator Privileges
- Not required for basic functionality
- Recommended for unrestricted input simulation
- Right-click → "Run as Administrator" if needed

### Network Requirements
- Both iPhone and Windows PC must be on the **same WiFi network**
- Won't work across different networks or subnets
- Corporate networks with AP isolation may block device-to-device communication

### Antivirus
- Some antivirus software may flag input simulation
- Add AirControlla.exe to your antivirus exceptions if needed
- This is a false positive - the app only simulates input when you send commands from your iPhone

## Troubleshooting

**iPhone can't discover Windows PC:**
- Ensure both devices are on the same WiFi network
- Check Windows Firewall allows the app
- Try temporarily disabling antivirus

**Connection shows but commands don't work:**
- Run the app as Administrator
- Check Windows Firewall settings
- Restart both the app and iPhone

**Mouse/keyboard not responding:**
- Run as Administrator for full input simulation access
- Check that the Windows app window shows "Controller Connected"
