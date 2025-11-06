# AirControlla for Windows

Windows receiver app for AirControlla - allows you to control your Windows PC from your iPhone.

## Prerequisites

1. **Windows 10/11 PC**
2. **Visual Studio 2022** (Community Edition is free)
   - Download: https://visualstudio.microsoft.com/downloads/
   - During installation, select ".NET desktop development" workload
3. **.NET 8.0 SDK** (included with Visual Studio)

## How to Build

### On Windows PC:

1. **Open Visual Studio 2022**
2. Click **"Create a new project"**
3. Search for **"WPF Application"**
4. Select **"WPF App (.NET)"** (not .NET Framework)
5. Name it: `AirControllaWindows`
6. Framework: **.NET 8.0**
7. Click **Create**

### Install Required NuGet Packages:

In Visual Studio:
1. Right-click on project → **"Manage NuGet Packages"**
2. Install these packages:
   - `Zeroconf` - For Bonjour/mDNS discovery
   - `InputSimulatorCore` - For keyboard/mouse simulation
   - `EmbedIO` - For HTTP server
   - `Newtonsoft.Json` - For JSON parsing

OR use Package Manager Console:
```powershell
Install-Package Zeroconf
Install-Package InputSimulatorCore
Install-Package EmbedIO
Install-Package Newtonsoft.Json
```

## Architecture

The Windows app mirrors the macOS receiver:

```
iPhone (Controller) → WiFi Network → Windows PC (Receiver)
                                      ↓
                                  Simulates Input
```

### Components:

1. **NetworkManager.cs** - Bonjour service advertising + HTTP server
2. **InputSimulator.cs** - Keyboard/mouse input simulation
3. **MainWindow.xaml** - UI (status display)

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
| Bonjour | Built-in (Network.framework) | Zeroconf library |
| HTTP Server | Built-in (NWListener) | EmbedIO library |
| Input Simulation | CGEvent API | Windows Input API |
| Permissions | Accessibility | Run as Administrator |

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

## Notes

- Windows app needs to run with **elevated privileges** for input simulation to work globally
- Firewall may prompt to allow network access - allow it
- Antivirus might flag input simulation - add exception if needed
