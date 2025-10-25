//
//  InputSimulator.swift
//  AirType
//
//  Simulates keyboard and mouse input on the receiver device
//

import Foundation

#if os(macOS)
import Cocoa
import CoreGraphics

class InputSimulator {

    // MARK: - Keyboard Simulation

    static func typeText(_ text: String) {
        let keycodes = HIDKeycodeMapper.keycodes(for: text)

        for keycode in keycodes {
            sendKeyPress(keycode: keycode.keycode, modifier: keycode.modifier)
            Thread.sleep(forTimeInterval: 0.01) // Small delay between keys
        }
    }

    static func sendKeyPress(keycode: UInt8, modifier: UInt8) {
        guard let keyCode = convertHIDToMacKeyCode(keycode) else {
            print("⚠️ Unsupported keycode: \(keycode)")
            return
        }

        let modifierFlags = convertModifierFlags(modifier)

        // Key down event
        if let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) {
            keyDownEvent.flags = modifierFlags
            keyDownEvent.post(tap: .cghidEventTap)
        }

        Thread.sleep(forTimeInterval: 0.01)

        // Key up event
        if let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) {
            keyUpEvent.flags = modifierFlags
            keyUpEvent.post(tap: .cghidEventTap)
        }
    }

    // MARK: - Mouse Simulation

    static func moveMouse(deltaX: Int, deltaY: Int) {
        // Get current mouse position using CGEvent (top-left origin)
        guard let currentEvent = CGEvent(source: nil) else { return }
        let currentLocation = currentEvent.location

        // Calculate new position using deltas
        // Note: deltaY is negative when moving down (joystick pushed down)
        // CGEvent Y increases downward, so we negate deltaY
        let newX = currentLocation.x + CGFloat(deltaX)
        let newY = currentLocation.y - CGFloat(deltaY)
        let newLocation = CGPoint(x: newX, y: newY)

        // Create mouse move event with new absolute position
        if let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: newLocation, mouseButton: .left) {
            moveEvent.post(tap: .cghidEventTap)
        }
    }

    static func clickMouse(button: String) {
        // Get current mouse position - create a CGEvent to read current location
        guard let currentEvent = CGEvent(source: nil) else { return }
        let currentLocation = currentEvent.location

        let (mouseDown, mouseUp, mouseButton): (CGEventType, CGEventType, CGMouseButton)

        switch button.lowercased() {
        case "left":
            mouseDown = .leftMouseDown
            mouseUp = .leftMouseUp
            mouseButton = .left
        case "right":
            mouseDown = .rightMouseDown
            mouseUp = .rightMouseUp
            mouseButton = .right
        case "middle":
            mouseDown = .otherMouseDown
            mouseUp = .otherMouseUp
            mouseButton = .center
        default:
            return
        }

        // Mouse down
        if let downEvent = CGEvent(mouseEventSource: nil, mouseType: mouseDown, mouseCursorPosition: currentLocation, mouseButton: mouseButton) {
            downEvent.post(tap: .cghidEventTap)
        }

        Thread.sleep(forTimeInterval: 0.05)

        // Mouse up
        if let upEvent = CGEvent(mouseEventSource: nil, mouseType: mouseUp, mouseCursorPosition: currentLocation, mouseButton: mouseButton) {
            upEvent.post(tap: .cghidEventTap)
        }
    }

    // MARK: - Key Code Conversion

    private static func convertHIDToMacKeyCode(_ hidCode: UInt8) -> CGKeyCode? {
        // Map HID keycodes to macOS virtual keycodes
        // Reference: https://developer.apple.com/documentation/coregraphics/cgkeycode

        let mapping: [UInt8: CGKeyCode] = [
            0x04: 0x00, // A
            0x05: 0x0B, // B
            0x06: 0x08, // C
            0x07: 0x02, // D
            0x08: 0x0E, // E
            0x09: 0x03, // F
            0x0A: 0x05, // G
            0x0B: 0x04, // H
            0x0C: 0x22, // I
            0x0D: 0x26, // J
            0x0E: 0x28, // K
            0x0F: 0x25, // L
            0x10: 0x2E, // M
            0x11: 0x2D, // N
            0x12: 0x1F, // O
            0x13: 0x23, // P
            0x14: 0x0C, // Q
            0x15: 0x0F, // R
            0x16: 0x01, // S
            0x17: 0x11, // T
            0x18: 0x20, // U
            0x19: 0x09, // V
            0x1A: 0x0D, // W
            0x1B: 0x07, // X
            0x1C: 0x10, // Y
            0x1D: 0x06, // Z

            0x1E: 0x12, // 1
            0x1F: 0x13, // 2
            0x20: 0x14, // 3
            0x21: 0x15, // 4
            0x22: 0x17, // 5
            0x23: 0x16, // 6
            0x24: 0x1A, // 7
            0x25: 0x1C, // 8
            0x26: 0x19, // 9
            0x27: 0x1D, // 0

            0x28: 0x24, // Enter
            0x29: 0x35, // Escape
            0x2A: 0x33, // Backspace
            0x2B: 0x30, // Tab
            0x2C: 0x31, // Space

            0x2D: 0x1B, // - _
            0x2E: 0x18, // = +
            0x2F: 0x21, // [ {
            0x30: 0x1E, // ] }
            0x31: 0x2A, // \ |
            0x33: 0x29, // ; :
            0x34: 0x27, // ' "
            0x35: 0x32, // ` ~
            0x36: 0x2B, // , <
            0x37: 0x2F, // . >
            0x38: 0x2C, // / ?
        ]

        return mapping[hidCode]
    }

    private static func convertModifierFlags(_ modifier: UInt8) -> CGEventFlags {
        var flags: CGEventFlags = []

        if modifier & 0x01 != 0 { flags.insert(.maskControl) }    // Ctrl
        if modifier & 0x02 != 0 { flags.insert(.maskShift) }      // Shift
        if modifier & 0x04 != 0 { flags.insert(.maskAlternate) }  // Alt
        if modifier & 0x08 != 0 { flags.insert(.maskCommand) }    // Cmd

        return flags
    }

    // MARK: - Accessibility Check

    static func checkAccessibilityPermissions() -> Bool {
        // Check without prompting - just get the current state
        return AXIsProcessTrusted()
    }

    static func requestAccessibilityPermissions() {
        // Show the system permission dialog
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options)
    }

    static func hasAccessibilityPermissions() -> Bool {
        // Check without prompting - for UI state checking
        return AXIsProcessTrusted()
    }
}

#elseif os(iOS) || os(tvOS)
import UIKit

class InputSimulator {

    static func typeText(_ text: String) {
        print("⚠️ Input simulation not supported on iOS/tvOS")
        print("   iOS does not allow apps to simulate keyboard/mouse input")
        print("   Use macOS or tvOS (with private APIs) as receiver")
    }

    static func sendKeyPress(keycode: UInt8, modifier: UInt8) {
        print("⚠️ Input simulation not supported on iOS/tvOS")
    }

    static func moveMouse(deltaX: Int, deltaY: Int) {
        print("⚠️ Input simulation not supported on iOS/tvOS")
    }

    static func clickMouse(button: String) {
        print("⚠️ Input simulation not supported on iOS/tvOS")
    }

    static func checkAccessibilityPermissions() -> Bool {
        return false // Not applicable on iOS
    }

    static func requestAccessibilityPermissions() {
        // Not applicable on iOS
    }

    static func hasAccessibilityPermissions() -> Bool {
        return false // Not applicable on iOS
    }
}

#endif
