//
//  HIDKeycodeMapper.swift
//  AirType
//
//  Maps characters to USB HID keyboard scancodes
//

import Foundation

struct HIDKeycode {
    let keycode: UInt8
    let modifier: UInt8

    static let none = HIDKeycode(keycode: 0x00, modifier: 0x00)
}

class HIDKeycodeMapper {

    // HID Modifier bits
    static let MOD_LEFT_CTRL: UInt8   = 0x01
    static let MOD_LEFT_SHIFT: UInt8  = 0x02
    static let MOD_LEFT_ALT: UInt8    = 0x04
    static let MOD_LEFT_GUI: UInt8    = 0x08
    static let MOD_RIGHT_CTRL: UInt8  = 0x10
    static let MOD_RIGHT_SHIFT: UInt8 = 0x20
    static let MOD_RIGHT_ALT: UInt8   = 0x40
    static let MOD_RIGHT_GUI: UInt8   = 0x80

    // Special keys
    static let KEY_ENTER: UInt8     = 0x28
    static let KEY_ESCAPE: UInt8    = 0x29
    static let KEY_BACKSPACE: UInt8 = 0x2A
    static let KEY_TAB: UInt8       = 0x2B
    static let KEY_SPACE: UInt8     = 0x2C
    static let KEY_DELETE: UInt8    = 0x4C

    // Character to keycode mapping
    private static let keycodeMap: [Character: HIDKeycode] = [
        // Letters (lowercase)
        "a": HIDKeycode(keycode: 0x04, modifier: 0x00),
        "b": HIDKeycode(keycode: 0x05, modifier: 0x00),
        "c": HIDKeycode(keycode: 0x06, modifier: 0x00),
        "d": HIDKeycode(keycode: 0x07, modifier: 0x00),
        "e": HIDKeycode(keycode: 0x08, modifier: 0x00),
        "f": HIDKeycode(keycode: 0x09, modifier: 0x00),
        "g": HIDKeycode(keycode: 0x0A, modifier: 0x00),
        "h": HIDKeycode(keycode: 0x0B, modifier: 0x00),
        "i": HIDKeycode(keycode: 0x0C, modifier: 0x00),
        "j": HIDKeycode(keycode: 0x0D, modifier: 0x00),
        "k": HIDKeycode(keycode: 0x0E, modifier: 0x00),
        "l": HIDKeycode(keycode: 0x0F, modifier: 0x00),
        "m": HIDKeycode(keycode: 0x10, modifier: 0x00),
        "n": HIDKeycode(keycode: 0x11, modifier: 0x00),
        "o": HIDKeycode(keycode: 0x12, modifier: 0x00),
        "p": HIDKeycode(keycode: 0x13, modifier: 0x00),
        "q": HIDKeycode(keycode: 0x14, modifier: 0x00),
        "r": HIDKeycode(keycode: 0x15, modifier: 0x00),
        "s": HIDKeycode(keycode: 0x16, modifier: 0x00),
        "t": HIDKeycode(keycode: 0x17, modifier: 0x00),
        "u": HIDKeycode(keycode: 0x18, modifier: 0x00),
        "v": HIDKeycode(keycode: 0x19, modifier: 0x00),
        "w": HIDKeycode(keycode: 0x1A, modifier: 0x00),
        "x": HIDKeycode(keycode: 0x1B, modifier: 0x00),
        "y": HIDKeycode(keycode: 0x1C, modifier: 0x00),
        "z": HIDKeycode(keycode: 0x1D, modifier: 0x00),

        // Letters (uppercase)
        "A": HIDKeycode(keycode: 0x04, modifier: MOD_LEFT_SHIFT),
        "B": HIDKeycode(keycode: 0x05, modifier: MOD_LEFT_SHIFT),
        "C": HIDKeycode(keycode: 0x06, modifier: MOD_LEFT_SHIFT),
        "D": HIDKeycode(keycode: 0x07, modifier: MOD_LEFT_SHIFT),
        "E": HIDKeycode(keycode: 0x08, modifier: MOD_LEFT_SHIFT),
        "F": HIDKeycode(keycode: 0x09, modifier: MOD_LEFT_SHIFT),
        "G": HIDKeycode(keycode: 0x0A, modifier: MOD_LEFT_SHIFT),
        "H": HIDKeycode(keycode: 0x0B, modifier: MOD_LEFT_SHIFT),
        "I": HIDKeycode(keycode: 0x0C, modifier: MOD_LEFT_SHIFT),
        "J": HIDKeycode(keycode: 0x0D, modifier: MOD_LEFT_SHIFT),
        "K": HIDKeycode(keycode: 0x0E, modifier: MOD_LEFT_SHIFT),
        "L": HIDKeycode(keycode: 0x0F, modifier: MOD_LEFT_SHIFT),
        "M": HIDKeycode(keycode: 0x10, modifier: MOD_LEFT_SHIFT),
        "N": HIDKeycode(keycode: 0x11, modifier: MOD_LEFT_SHIFT),
        "O": HIDKeycode(keycode: 0x12, modifier: MOD_LEFT_SHIFT),
        "P": HIDKeycode(keycode: 0x13, modifier: MOD_LEFT_SHIFT),
        "Q": HIDKeycode(keycode: 0x14, modifier: MOD_LEFT_SHIFT),
        "R": HIDKeycode(keycode: 0x15, modifier: MOD_LEFT_SHIFT),
        "S": HIDKeycode(keycode: 0x16, modifier: MOD_LEFT_SHIFT),
        "T": HIDKeycode(keycode: 0x17, modifier: MOD_LEFT_SHIFT),
        "U": HIDKeycode(keycode: 0x18, modifier: MOD_LEFT_SHIFT),
        "V": HIDKeycode(keycode: 0x19, modifier: MOD_LEFT_SHIFT),
        "W": HIDKeycode(keycode: 0x1A, modifier: MOD_LEFT_SHIFT),
        "X": HIDKeycode(keycode: 0x1B, modifier: MOD_LEFT_SHIFT),
        "Y": HIDKeycode(keycode: 0x1C, modifier: MOD_LEFT_SHIFT),
        "Z": HIDKeycode(keycode: 0x1D, modifier: MOD_LEFT_SHIFT),

        // Numbers
        "1": HIDKeycode(keycode: 0x1E, modifier: 0x00),
        "2": HIDKeycode(keycode: 0x1F, modifier: 0x00),
        "3": HIDKeycode(keycode: 0x20, modifier: 0x00),
        "4": HIDKeycode(keycode: 0x21, modifier: 0x00),
        "5": HIDKeycode(keycode: 0x22, modifier: 0x00),
        "6": HIDKeycode(keycode: 0x23, modifier: 0x00),
        "7": HIDKeycode(keycode: 0x24, modifier: 0x00),
        "8": HIDKeycode(keycode: 0x25, modifier: 0x00),
        "9": HIDKeycode(keycode: 0x26, modifier: 0x00),
        "0": HIDKeycode(keycode: 0x27, modifier: 0x00),

        // Special characters
        "!": HIDKeycode(keycode: 0x1E, modifier: MOD_LEFT_SHIFT),
        "@": HIDKeycode(keycode: 0x1F, modifier: MOD_LEFT_SHIFT),
        "#": HIDKeycode(keycode: 0x20, modifier: MOD_LEFT_SHIFT),
        "$": HIDKeycode(keycode: 0x21, modifier: MOD_LEFT_SHIFT),
        "%": HIDKeycode(keycode: 0x22, modifier: MOD_LEFT_SHIFT),
        "^": HIDKeycode(keycode: 0x23, modifier: MOD_LEFT_SHIFT),
        "&": HIDKeycode(keycode: 0x24, modifier: MOD_LEFT_SHIFT),
        "*": HIDKeycode(keycode: 0x25, modifier: MOD_LEFT_SHIFT),
        "(": HIDKeycode(keycode: 0x26, modifier: MOD_LEFT_SHIFT),
        ")": HIDKeycode(keycode: 0x27, modifier: MOD_LEFT_SHIFT),

        // Punctuation
        " ": HIDKeycode(keycode: KEY_SPACE, modifier: 0x00),
        "\n": HIDKeycode(keycode: KEY_ENTER, modifier: 0x00),
        "\t": HIDKeycode(keycode: KEY_TAB, modifier: 0x00),
        "-": HIDKeycode(keycode: 0x2D, modifier: 0x00),
        "_": HIDKeycode(keycode: 0x2D, modifier: MOD_LEFT_SHIFT),
        "=": HIDKeycode(keycode: 0x2E, modifier: 0x00),
        "+": HIDKeycode(keycode: 0x2E, modifier: MOD_LEFT_SHIFT),
        "[": HIDKeycode(keycode: 0x2F, modifier: 0x00),
        "{": HIDKeycode(keycode: 0x2F, modifier: MOD_LEFT_SHIFT),
        "]": HIDKeycode(keycode: 0x30, modifier: 0x00),
        "}": HIDKeycode(keycode: 0x30, modifier: MOD_LEFT_SHIFT),
        "\\": HIDKeycode(keycode: 0x31, modifier: 0x00),
        "|": HIDKeycode(keycode: 0x31, modifier: MOD_LEFT_SHIFT),
        ";": HIDKeycode(keycode: 0x33, modifier: 0x00),
        ":": HIDKeycode(keycode: 0x33, modifier: MOD_LEFT_SHIFT),
        "'": HIDKeycode(keycode: 0x34, modifier: 0x00),
        "\"": HIDKeycode(keycode: 0x34, modifier: MOD_LEFT_SHIFT),
        "`": HIDKeycode(keycode: 0x35, modifier: 0x00),
        "~": HIDKeycode(keycode: 0x35, modifier: MOD_LEFT_SHIFT),
        ",": HIDKeycode(keycode: 0x36, modifier: 0x00),
        "<": HIDKeycode(keycode: 0x36, modifier: MOD_LEFT_SHIFT),
        ".": HIDKeycode(keycode: 0x37, modifier: 0x00),
        ">": HIDKeycode(keycode: 0x37, modifier: MOD_LEFT_SHIFT),
        "/": HIDKeycode(keycode: 0x38, modifier: 0x00),
        "?": HIDKeycode(keycode: 0x38, modifier: MOD_LEFT_SHIFT),
    ]

    static func keycode(for character: Character) -> HIDKeycode {
        return keycodeMap[character] ?? .none
    }

    static func keycodes(for text: String) -> [HIDKeycode] {
        return text.map { keycode(for: $0) }
    }
}
