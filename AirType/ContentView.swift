//
//  ContentView.swift
//  AirType
//
//  Main UI with Voice and Keyboard modes
//

import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @EnvironmentObject var storeManager: StoreManager
    @State private var selectedMode: Mode = .control
    @State private var textInput = ""
    @State private var selectedDevice: DiscoveredDevice?
    @State private var showPaywall = false
    @State private var hasShownInitialPaywall = false
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    enum Mode: String, CaseIterable {
        case control = "Control"
        case devices = "Devices"
        case appMode = "App Mode"
    }

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 1.0),
                    Color(red: 0.6, green: 0.4, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Mode Switcher - only show if in Controller mode
                if networkManager.appMode == .controller {
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(Mode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    #if os(macOS)
                    .controlSize(.large)
                    #endif
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 25)
                }

                // Mode Content
                Group {
                    if networkManager.appMode == .receiver {
                        // Receiver mode - only show App Mode settings
                        AppModeView(networkManager: networkManager)
                    } else {
                        // Controller mode - show all tabs
                        switch selectedMode {
                        case .control:
                            ControlModeView(
                                networkManager: networkManager,
                                selectedDevice: selectedDevice,
                                textInput: $textInput,
                                showPaywall: $showPaywall
                            )
                        case .devices:
                            DevicePickerView(
                                networkManager: networkManager,
                                selectedDevice: $selectedDevice
                            )
                        case .appMode:
                            AppModeView(networkManager: networkManager)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: networkManager.appMode) { newMode in
                    // Auto-switch to App Mode tab when switching to Receiver
                    if newMode == .receiver {
                        selectedMode = .appMode
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0)
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
                    .onDisappear {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        // Show paywall after onboarding if user is free
                        if !storeManager.isPro {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showPaywall = true
                            }
                        }
                    }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(storeManager)
            }
            .onAppear {
                // Show paywall on launch for free users (once per session, if onboarding already seen)
                if !showOnboarding && !storeManager.isPro && !hasShownInitialPaywall {
                    // Small delay so the UI loads first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showPaywall = true
                        hasShownInitialPaywall = true
                    }
                }
            }
        }
    }
}

// MARK: - Device Picker View
struct DevicePickerView: View {
    @ObservedObject var networkManager: NetworkManager
    @Binding var selectedDevice: DiscoveredDevice?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Nearby Devices")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    networkManager.stopAll()
                    selectedDevice = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        networkManager.startDiscovery()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Refresh")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            if networkManager.discoveredDevices.isEmpty {
                Spacer()
                VStack(spacing: 15) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.6))

                    Text("No devices found")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))

                    Text("Make sure the other device is in Receiver mode")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(networkManager.discoveredDevices) { device in
                            DeviceCard(
                                device: device,
                                isSelected: selectedDevice?.id == device.id,
                                isConnected: networkManager.isDeviceConnected,
                                onTap: {
                                    selectedDevice = device
                                    networkManager.connectToDevice(device)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Device Card
struct DeviceCard: View {
    let device: DiscoveredDevice
    let isSelected: Bool
    let isConnected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text(device.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Image(systemName: "wifi")
                            .font(.system(size: 12))
                        Text(device.signalStrength)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                if isSelected {
                    if isConnected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
            }
            .padding()
            .background(
                isSelected
                    ? Color.white.opacity(0.3)
                    : Color.white.opacity(0.2)
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - App Mode View
struct AppModeView: View {
    @ObservedObject var networkManager: NetworkManager

    var body: some View {
        VStack(spacing: 25) {
            VStack(alignment: .leading, spacing: 15) {
                ForEach([AppMode.controller, AppMode.receiver], id: \.self) { mode in
                    ModeButton(
                        mode: mode,
                        isSelected: networkManager.appMode == mode,
                        onTap: {
                            networkManager.appMode = mode
                        }
                    )
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)

            // Connection Status for Receiver Mode
            if networkManager.appMode == .receiver && networkManager.isReceiving {
                VStack(spacing: 15) {
                    if networkManager.isControllerConnected {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            Text("Controller Connected")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    } else {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                                .padding(.bottom, 8)

                            Text("Download app on iPhone then connect")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)

                            Text("* You must be on the same WiFi")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.top, 30)
            }

            Spacer()
        }
    }
}

// MARK: - Mode Button
struct ModeButton: View {
    let mode: AppMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                Text(mode.rawValue)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                isSelected
                    ? Color.white.opacity(0.3)
                    : Color.white.opacity(0.15)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch mode {
        case .controller:
            return "hand.point.left.fill"
        case .receiver:
            return "antenna.radiowaves.left.and.right"
        }
    }
}

// MARK: - Control Mode View (Keyboard + Mouse)
struct ControlModeView: View {
    @ObservedObject var networkManager: NetworkManager
    @EnvironmentObject var storeManager: StoreManager
    let selectedDevice: DiscoveredDevice?
    @Binding var textInput: String
    @Binding var showPaywall: Bool
    @State private var joystickOffset = CGSize.zero
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Text Input Area
            ZStack(alignment: .topLeading) {
                if textInput.isEmpty {
                    Text("Tap to type...")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                TextEditor(text: $textInput)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .focused($isTextEditorFocused)
            }
            .frame(height: 180)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                // Send button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if !textInput.isEmpty {
                            Button(action: sendText) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color(red: 0.5, green: 0.5, blue: 1.0))
                                    .clipShape(Circle())
                            }
                            .padding(8)
                        }
                    }
                }
            )
            .disabled(selectedDevice == nil)
            .opacity(selectedDevice == nil ? 0.5 : 1.0)
            .padding(.horizontal, 25)
            .padding(.top, isTextEditorFocused ? 10 : 20)

            // Quick Keys: Enter, Backspace, Space
            HStack(spacing: 12) {
                Button(action: {
                    guard storeManager.isPro else {
                        showPaywall = true
                        return
                    }
                    if let device = selectedDevice {
                        networkManager.sendKeyPress(keycode: 0x28, modifier: 0, to: device) // Enter
                    }
                }) {
                    Text("Enter")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(selectedDevice == nil)
                .opacity(selectedDevice == nil ? 0.5 : 1.0)

                Button(action: {
                    guard storeManager.isPro else {
                        showPaywall = true
                        return
                    }
                    if let device = selectedDevice {
                        networkManager.sendKeyPress(keycode: 0x2A, modifier: 0, to: device) // Backspace
                    }
                }) {
                    Text("⌫")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(selectedDevice == nil)
                .opacity(selectedDevice == nil ? 0.5 : 1.0)

                Button(action: {
                    guard storeManager.isPro else {
                        showPaywall = true
                        return
                    }
                    if let device = selectedDevice {
                        networkManager.sendKeyPress(keycode: 0x2C, modifier: 0, to: device) // Space
                    }
                }) {
                    Text("Space")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(selectedDevice == nil)
                .opacity(selectedDevice == nil ? 0.5 : 1.0)

                Button(action: {
                    isTextEditorFocused.toggle()
                }) {
                    Image(systemName: isTextEditorFocused ? "keyboard.chevron.compact.down" : "keyboard")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 25)
            .padding(.top, 12)

            Spacer()

            // Controller Layout: Joystick + Buttons
            HStack(spacing: 10) {
                // Left Side - Joystick
                VirtualJoystick(
                    offset: $joystickOffset,
                    onMove: { deltaX, deltaY in
                        if let device = selectedDevice {
                            networkManager.sendMouseMove(deltaX: deltaX, deltaY: deltaY, to: device)
                        }
                    }
                )
                .disabled(selectedDevice == nil)
                .opacity(selectedDevice == nil ? 0.5 : 1.0)

                // Right Side - Click Buttons - Game Boy style staggered
                VStack(spacing: 15) {
                    // R Button (Right Click) - Top, offset right
                    HStack {
                        Spacer()
                        Button(action: {
                            if let device = selectedDevice {
                                networkManager.sendMouseClick(button: "right", to: device)
                            }
                        }) {
                            Text("R")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 1.0))
                                .frame(width: 70, height: 70)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedDevice == nil)
                        .opacity(selectedDevice == nil ? 0.5 : 1.0)
                    }

                    // L Button (Left Click) - Bottom, offset left
                    HStack {
                        Button(action: {
                            if let device = selectedDevice {
                                networkManager.sendMouseClick(button: "left", to: device)
                            }
                        }) {
                            Text("L")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 1.0))
                                .frame(width: 70, height: 70)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedDevice == nil)
                        .opacity(selectedDevice == nil ? 0.5 : 1.0)
                        Spacer()
                    }
                }
                .frame(width: 100)
            }
            .frame(height: 230)
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside text editor
            isTextEditorFocused = false
        }
    }

    private func sendText() {
        guard !textInput.isEmpty, let device = selectedDevice else { return }

        // Check Pro status
        guard storeManager.isPro else {
            showPaywall = true
            return
        }

        // Dismiss keyboard
        isTextEditorFocused = false

        DispatchQueue.global(qos: .userInitiated).async {
            networkManager.sendText(textInput, to: device)
            DispatchQueue.main.async {
                textInput = ""
            }
        }
    }
}

// MARK: - Virtual Joystick
struct VirtualJoystick: View {
    @Binding var offset: CGSize
    var onMove: (Int8, Int8) -> Void

    @State private var isDragging = false
    @State private var movementTimer: Timer?
    @State private var accumulatedX: CGFloat = 0
    @State private var accumulatedY: CGFloat = 0
    @State private var smoothedOffset: CGSize = .zero

    let maxDistance: CGFloat = 70

    var body: some View {
        ZStack {
            // Base circle
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 220, height: 220)

            // Joystick knob
            Circle()
                .fill(Color.white)
                .frame(width: 90, height: 90)
                .overlay(
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .font(.system(size: 35))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 1.0))
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isDragging {
                                isDragging = true
                                startMovementTimer()
                            }

                            let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                            if distance <= maxDistance {
                                offset = value.translation
                            } else {
                                let angle = atan2(value.translation.height, value.translation.width)
                                offset = CGSize(
                                    width: cos(angle) * maxDistance,
                                    height: sin(angle) * maxDistance
                                )
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            stopMovementTimer()
                            // Reset accumulated fractional pixels and smoothed position
                            accumulatedX = 0
                            accumulatedY = 0
                            smoothedOffset = .zero
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                offset = .zero
                            }
                        }
                )
        }
    }

    private func startMovementTimer() {
        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { _ in
            sendMovement()
        }
    }

    private func stopMovementTimer() {
        movementTimer?.invalidate()
        movementTimer = nil
    }

    private func sendMovement() {
        guard isDragging else { return }

        // Balanced smoothing (0.35) for consistent speed without lag
        let smoothingFactor: CGFloat = 0.35
        smoothedOffset.width = smoothedOffset.width * (1 - smoothingFactor) + offset.width * smoothingFactor
        smoothedOffset.height = smoothedOffset.height * (1 - smoothingFactor) + offset.height * smoothingFactor

        // Calculate joystick distance (magnitude)
        let distance = sqrt(smoothedOffset.width * smoothedOffset.width + smoothedOffset.height * smoothedOffset.height)
        guard distance > 0 else { return }

        // Normalize to unit vector (so diagonals aren't faster)
        let normalizedX = smoothedOffset.width / distance
        let normalizedY = smoothedOffset.height / distance

        // Normalize distance to 0-1 range
        let normalizedDistance = min(distance / maxDistance, 1.0)

        // Steeper curve (x^4.5) for extended precision at low speeds
        // 20% = 0.3%, 40% = 3.6%, 60% = 23%, 80% = 61%, 100% = 100%
        // Long precise range for clicking small UI elements
        let acceleratedDistance = pow(normalizedDistance, 4.5)

        // Speed range: 0.6 to 43 pixels per update at 25ms = 24-1720 px/sec
        // Low minimum for pixel-perfect control (clicking small buttons)
        let minSpeed: CGFloat = 0.6
        let maxSpeed: CGFloat = 43.0
        let speed = minSpeed + (acceleratedDistance * (maxSpeed - minSpeed))

        // Calculate fractional movement maintaining perfect angle
        let moveX = normalizedX * speed
        let moveY = -normalizedY * speed  // Negative to invert Y

        // Accumulate fractional pixels
        accumulatedX += moveX
        accumulatedY += moveY

        // Extract integer part to send
        let deltaX = Int8(max(-127, min(127, accumulatedX)))
        let deltaY = Int8(max(-127, min(127, accumulatedY)))

        // Subtract the integer part, keeping remainder for next update
        accumulatedX -= CGFloat(deltaX)
        accumulatedY -= CGFloat(deltaY)

        // Send movement if we have at least 1 pixel to move
        if deltaX != 0 || deltaY != 0 {
            onMove(deltaX, deltaY)
        }
    }
}

// MARK: - Quick Key Button
struct QuickKeyButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 12))
            }
            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 1.0))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
