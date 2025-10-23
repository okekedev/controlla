//
//  NetworkManager.swift
//  AirType
//
//  Handles WiFi networking, Bonjour discovery, and HTTP communication
//

import Foundation
import Network
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Discovered Device Model
struct DiscoveredDevice: Identifiable {
    let id = UUID()
    let name: String
    let host: String
    let port: Int
    let signalStrength: String // "Excellent", "Good", "Fair"

    var urlString: String {
        "http://\(host):\(port)"
    }
}

// MARK: - App Mode
enum AppMode: String, Codable {
    case controller = "Controller"
    case receiver = "Receiver"
}

// MARK: - Network Manager
class NetworkManager: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var isDiscovering = false
    @Published var isReceiving = false
    @Published var receiverStatus = "Not Started"
    @Published var connectedDevice: DiscoveredDevice?
    @Published var isControllerConnected = false // Receiver mode: is a controller connected?
    @Published var isDeviceConnected = false // Controller mode: successfully connected to device?
    @Published var hasAttemptedConnection = false // Have we tried sending a command yet?
    #if os(macOS)
    @Published var appMode: AppMode = .receiver {
        didSet {
            UserDefaults.standard.set(appMode.rawValue, forKey: "appMode")
            updateServices()
        }
    }
    #else
    @Published var appMode: AppMode = .controller {
        didSet {
            UserDefaults.standard.set(appMode.rawValue, forKey: "appMode")
            updateServices()
        }
    }
    #endif

    // MARK: - Bonjour Properties
    private var browser: NWBrowser?
    private var listener: NWListener?
    private let serviceType = "_airtype._tcp"

    // MARK: - HTTP Server
    private var connectionsByID: [Int: NWConnection] = [:]
    private var nextConnectionID = 0

    // MARK: - Controller Connection
    private var controllerConnection: NWConnection?
    private var isSendingCommand = false

    // MARK: - Device Name
    var deviceName: String {
        #if os(iOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return "AirType Device"
        #endif
    }

    // MARK: - Initialization
    override init() {
        super.init()

        // Load saved mode
        if let savedMode = UserDefaults.standard.string(forKey: "appMode"),
           let mode = AppMode(rawValue: savedMode) {
            self.appMode = mode
        }

        updateServices()
    }

    // MARK: - Service Management
    private func updateServices() {
        stopAll()

        switch appMode {
        case .controller:
            startDiscovery()
        case .receiver:
            startReceiver()
        }
    }

    func stopAll() {
        stopDiscovery()
        stopReceiver()
        disconnectFromDevice()
        isDeviceConnected = false
        isControllerConnected = false
        hasAttemptedConnection = false
    }

    // MARK: - Persistent Connection to Device (Controller Mode)
    func connectToDevice(_ device: DiscoveredDevice) {
        // Disconnect from previous device if any
        disconnectFromDevice()

        // Create connection to device
        let host = NWEndpoint.Host(device.host)
        let port = NWEndpoint.Port(integerLiteral: UInt16(device.port))
        let connection = NWConnection(host: host, port: port, using: .tcp)

        connection.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    print("✅ Connected to \(device.name)")
                    self?.isDeviceConnected = true
                    self?.hasAttemptedConnection = true
                case .waiting(let error):
                    print("⏳ Waiting to connect: \(error)")
                    self?.isDeviceConnected = false
                case .failed(let error):
                    print("❌ Connection failed: \(error)")
                    self?.isDeviceConnected = false
                    self?.hasAttemptedConnection = true
                case .cancelled:
                    print("🚫 Connection cancelled")
                    self?.isDeviceConnected = false
                default:
                    break
                }
            }
        }

        connection.start(queue: .main)
        controllerConnection = connection
    }

    func disconnectFromDevice() {
        controllerConnection?.cancel()
        controllerConnection = nil
        isDeviceConnected = false
    }

    // MARK: - Discovery (Controller Mode)
    func startDiscovery() {
        guard !isDiscovering else { return }

        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        browser = NWBrowser(for: .bonjourWithTXTRecord(type: serviceType, domain: nil), using: parameters)

        browser?.stateUpdateHandler = { [weak self] newState in
            DispatchQueue.main.async {
                switch newState {
                case .ready:
                    self?.isDiscovering = true
                    print("🔍 Started discovering AirType devices")
                case .failed(let error):
                    print("❌ Discovery failed: \(error)")
                    self?.isDiscovering = false
                default:
                    break
                }
            }
        }

        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            self?.handleBrowseResults(results)
        }

        browser?.start(queue: .main)
    }

    func stopDiscovery() {
        browser?.cancel()
        browser = nil
        DispatchQueue.main.async {
            self.isDiscovering = false
            self.discoveredDevices = []
        }
    }

    private func handleBrowseResults(_ results: Set<NWBrowser.Result>) {
        for result in results {
            if case let .service(name, _, _, _) = result.endpoint {
                // Resolve the endpoint to get IP address and port
                resolveEndpoint(result.endpoint, name: name) { resolvedHost, resolvedPort in
                    let device = DiscoveredDevice(
                        name: name,
                        host: resolvedHost,
                        port: resolvedPort,
                        signalStrength: "Excellent"
                    )

                    DispatchQueue.main.async {
                        // Add if not already in list
                        if !self.discoveredDevices.contains(where: { $0.name == device.name }) {
                            self.discoveredDevices.append(device)
                            self.discoveredDevices.sort { $0.name < $1.name }
                        }
                    }
                }
            }
        }
    }

    private func resolveEndpoint(_ endpoint: NWEndpoint, name: String, completion: @escaping (String, Int) -> Void) {
        // Create a temporary connection to resolve the endpoint
        let connection = NWConnection(to: endpoint, using: .tcp)

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                // Extract IP and port from the connection
                if let path = connection.currentPath,
                   let remoteEndpoint = path.remoteEndpoint {

                    switch remoteEndpoint {
                    case .hostPort(let host, let port):
                        let resolvedHost: String
                        switch host {
                        case .ipv4(let address):
                            resolvedHost = address.debugDescription
                        case .ipv6(let address):
                            resolvedHost = address.debugDescription
                        case .name(let hostname, _):
                            resolvedHost = hostname
                        @unknown default:
                            resolvedHost = name + ".local"
                        }
                        let resolvedPort = Int(port.rawValue)
                        completion(resolvedHost, resolvedPort)
                    case .service:
                        completion(name + ".local", 8080)
                    case .unix:
                        completion(name + ".local", 8080)
                    case .url:
                        completion(name + ".local", 8080)
                    case .opaque:
                        completion(name + ".local", 8080)
                    @unknown default:
                        completion(name + ".local", 8080)
                    }
                }
                connection.cancel()

            case .failed:
                // Fallback to .local address
                completion(name + ".local", 8080)
                connection.cancel()

            default:
                break
            }
        }

        connection.start(queue: .main)
    }

    // MARK: - Receiver (Server Mode)
    func startReceiver() {
        guard !isReceiving else { return }

        #if os(macOS)
        // Check for Accessibility permissions on macOS
        if !InputSimulator.checkAccessibilityPermissions() {
            DispatchQueue.main.async {
                self.receiverStatus = "Accessibility permission required"
            }
            print("⚠️ Accessibility permissions needed. Opening System Preferences...")
            // The permission prompt was already shown by checkAccessibilityPermissions
            return
        }
        #endif

        do {
            let parameters = NWParameters.tcp
            parameters.includePeerToPeer = true

            listener = try NWListener(using: parameters, on: 0) // Let OS assign available port

            // Advertise via Bonjour after listener is created
            listener?.service = NWListener.Service(name: deviceName, type: serviceType)

            listener?.stateUpdateHandler = { [weak self] newState in
                DispatchQueue.main.async {
                    switch newState {
                    case .ready:
                        self?.isReceiving = true
                        if let port = self?.listener?.port {
                            self?.receiverStatus = "Ready - \(self?.deviceName ?? "Unknown")"
                            print("✅ Receiver started on port \(port)")
                        }
                    case .failed(let error):
                        print("❌ Receiver failed: \(error)")
                        self?.isReceiving = false
                        self?.receiverStatus = "Error: \(error.localizedDescription)"
                    default:
                        break
                    }
                }
            }

            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }

            listener?.start(queue: .main)

        } catch {
            print("❌ Failed to start receiver: \(error)")
            DispatchQueue.main.async {
                self.receiverStatus = "Failed to start"
            }
        }
    }

    func stopReceiver() {
        listener?.cancel()
        listener = nil
        connectionsByID.values.forEach { $0.cancel() }
        connectionsByID.removeAll()

        DispatchQueue.main.async {
            self.isReceiving = false
            self.receiverStatus = "Not Started"
        }
    }

    private func handleNewConnection(_ connection: NWConnection) {
        let connectionID = nextConnectionID
        nextConnectionID += 1
        connectionsByID[connectionID] = connection

        connection.stateUpdateHandler = { [weak self] newState in
            switch newState {
            case .ready:
                print("✅ Client connected: \(connectionID)")
                DispatchQueue.main.async {
                    self?.isControllerConnected = true
                }
                self?.receiveData(on: connection, id: connectionID)
            case .failed(let error):
                print("❌ Connection failed: \(error)")
                self?.connectionsByID[connectionID] = nil
                DispatchQueue.main.async {
                    if self?.connectionsByID.isEmpty ?? true {
                        self?.isControllerConnected = false
                    }
                }
            case .cancelled:
                self?.connectionsByID[connectionID] = nil
                DispatchQueue.main.async {
                    if self?.connectionsByID.isEmpty ?? true {
                        self?.isControllerConnected = false
                    }
                }
            default:
                break
            }
        }

        connection.start(queue: .main)
    }

    private func receiveData(on connection: NWConnection, id: Int) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self?.handleReceivedData(data, from: id)
            }

            if isComplete {
                connection.cancel()
                self?.connectionsByID[id] = nil
            } else if error == nil {
                // Continue receiving
                self?.receiveData(on: connection, id: id)
            }
        }
    }

    private func handleReceivedData(_ data: Data, from connectionID: Int) {
        // Parse HTTP request
        guard let request = String(data: data, encoding: .utf8) else { return }

        print("📥 Received: \(request.prefix(100))...")

        // Extract JSON from POST body
        if let jsonStart = request.range(of: "\r\n\r\n")?.upperBound {
            let jsonString = String(request[jsonStart...])
            if let jsonData = jsonString.data(using: .utf8) {
                processCommand(jsonData)
            }
        }

        // Send HTTP response
        if let connection = connectionsByID[connectionID] {
            let response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"success\":true}"
            connection.send(content: response.data(using: .utf8), completion: .contentProcessed({ _ in }))
        }
    }

    private func processCommand(_ data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📋 Command: \(json)")

                // Text input
                if let text = json["text"] as? String {
                    print("⌨️  Type: \(text)")
                    DispatchQueue.global(qos: .userInitiated).async {
                        InputSimulator.typeText(text)
                    }
                }

                // Single key press
                if let keycode = json["keycode"] as? Int,
                   let modifier = json["modifier"] as? Int {
                    print("⌨️  Key: \(keycode) + modifier: \(modifier)")
                    DispatchQueue.global(qos: .userInitiated).async {
                        InputSimulator.sendKeyPress(keycode: UInt8(keycode), modifier: UInt8(modifier))
                    }
                }

                // Mouse movement
                if let deltaX = json["deltaX"] as? Int,
                   let deltaY = json["deltaY"] as? Int {
                    print("🖱️  Move: (\(deltaX), \(deltaY))")
                    DispatchQueue.global(qos: .userInitiated).async {
                        InputSimulator.moveMouse(deltaX: deltaX, deltaY: deltaY)
                    }
                }

                // Mouse click
                if let button = json["button"] as? String {
                    print("🖱️  Click: \(button)")
                    DispatchQueue.global(qos: .userInitiated).async {
                        InputSimulator.clickMouse(button: button)
                    }
                }
            }
        } catch {
            print("❌ JSON parse error: \(error)")
        }
    }

    // MARK: - Send Commands (Controller Mode)
    func sendText(_ text: String, to device: DiscoveredDevice) {
        let json: [String: Any] = ["text": text]
        sendCommand(json, to: device, endpoint: "/keyboard/text")
    }

    func sendKeyPress(keycode: UInt8, modifier: UInt8, to device: DiscoveredDevice) {
        let json: [String: Any] = ["keycode": keycode, "modifier": modifier]
        sendCommand(json, to: device, endpoint: "/keyboard/key")
    }

    func sendMouseMove(deltaX: Int8, deltaY: Int8, to device: DiscoveredDevice) {
        // Skip if previous command still sending (prevents queue buildup)
        guard !isSendingCommand else { return }

        let json: [String: Any] = ["deltaX": deltaX, "deltaY": deltaY]
        sendCommand(json, to: device, endpoint: "/mouse/move")
    }

    func sendMouseClick(button: String, to device: DiscoveredDevice) {
        let json: [String: Any] = ["button": button]
        sendCommand(json, to: device, endpoint: "/mouse/click")
    }

    private func sendCommand(_ json: [String: Any], to device: DiscoveredDevice, endpoint: String) {
        guard let connection = controllerConnection else {
            print("❌ No active connection")
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("❌ Failed to serialize JSON")
            return
        }

        // Build HTTP request
        let httpRequest = """
POST \(endpoint) HTTP/1.1\r
Content-Type: application/json\r
Content-Length: \(jsonData.count)\r
\r
\(String(data: jsonData, encoding: .utf8) ?? "")
"""

        guard let requestData = httpRequest.data(using: .utf8) else { return }

        isSendingCommand = true
        connection.send(content: requestData, completion: .contentProcessed({ [weak self] error in
            self?.isSendingCommand = false
            if let error = error {
                print("❌ Send error: \(error)")
            }
        }))
    }
}
