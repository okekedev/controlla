using System;
using System.Runtime.InteropServices;
using WindowsInput;
using WindowsInput.Native;

namespace AirControllaWindows
{
    /// <summary>
    /// Simulates keyboard and mouse input on Windows
    /// Mirrors the Swift InputSimulator from macOS version
    /// </summary>
    public static class InputSimulator
    {
        private static readonly WindowsInput.InputSimulator _simulator = new WindowsInput.InputSimulator();

        // MARK: - Keyboard Simulation

        /// <summary>
        /// Type text character by character
        /// Mirrors Swift typeText() method
        /// </summary>
        public static void TypeText(string text)
        {
            if (string.IsNullOrEmpty(text)) return;

            try
            {
                _simulator.Keyboard.TextEntry(text);
                Console.WriteLine($"⌨️ Typed: {text.Substring(0, Math.Min(text.Length, 50))}...");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to type text: {ex.Message}");
            }
        }

        /// <summary>
        /// Send a key press with modifiers (Cmd, Shift, etc.)
        /// Mirrors Swift sendKeyPress() method
        /// </summary>
        public static void SendKeyPress(byte keycode, byte modifier)
        {
            try
            {
                var virtualKey = ConvertHIDToWindowsKeyCode(keycode);
                if (virtualKey == null)
                {
                    Console.WriteLine($"⚠️ Unsupported keycode: {keycode}");
                    return;
                }

                // Handle modifiers
                bool ctrl = (modifier & 0x01) != 0;  // Left Control
                bool shift = (modifier & 0x02) != 0; // Left Shift
                bool alt = (modifier & 0x04) != 0;   // Left Alt
                bool win = (modifier & 0x08) != 0;   // Left Windows key (Cmd on Mac)

                // Press modifiers
                if (ctrl) _simulator.Keyboard.KeyDown(VirtualKeyCode.CONTROL);
                if (shift) _simulator.Keyboard.KeyDown(VirtualKeyCode.SHIFT);
                if (alt) _simulator.Keyboard.KeyDown(VirtualKeyCode.MENU); // Alt
                if (win) _simulator.Keyboard.KeyDown(VirtualKeyCode.LWIN);

                // Press the key
                _simulator.Keyboard.KeyPress(virtualKey.Value);

                // Release modifiers
                if (win) _simulator.Keyboard.KeyUp(VirtualKeyCode.LWIN);
                if (alt) _simulator.Keyboard.KeyUp(VirtualKeyCode.MENU);
                if (shift) _simulator.Keyboard.KeyUp(VirtualKeyCode.SHIFT);
                if (ctrl) _simulator.Keyboard.KeyUp(VirtualKeyCode.CONTROL);

                Console.WriteLine($"⌨️ Key pressed: {virtualKey}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to send key press: {ex.Message}");
            }
        }

        // MARK: - Mouse Simulation

        /// <summary>
        /// Move mouse by delta amounts
        /// Mirrors Swift moveMouse() method
        /// </summary>
        public static void MoveMouse(int deltaX, int deltaY)
        {
            try
            {
                // Get current cursor position using Win32 API
                GetCursorPos(out POINT currentPos);

                // Note: deltaY is negative when moving down (joystick pushed down)
                // Windows Y increases downward, so we negate deltaY
                int newX = currentPos.X + deltaX;
                int newY = currentPos.Y - deltaY;

                // Set new cursor position
                SetCursorPos(newX, newY);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to move mouse: {ex.Message}");
            }
        }

        /// <summary>
        /// Click mouse button
        /// Mirrors Swift clickMouse() method
        /// </summary>
        public static void ClickMouse(string button)
        {
            try
            {
                switch (button.ToLower())
                {
                    case "left":
                        _simulator.Mouse.LeftButtonClick();
                        break;
                    case "right":
                        _simulator.Mouse.RightButtonClick();
                        break;
                    case "middle":
                        // Middle button not supported in InputSimulatorCore
                        Console.WriteLine("⚠️ Middle button not supported");
                        break;
                    default:
                        Console.WriteLine($"⚠️ Unknown button: {button}");
                        break;
                }

                Console.WriteLine($"🖱️ Mouse clicked: {button}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to click mouse: {ex.Message}");
            }
        }

        // MARK: - HID to Windows KeyCode Mapping

        /// <summary>
        /// Convert HID Usage ID (from iPhone) to Windows Virtual Key Code
        /// Mirrors the Swift convertHIDToMacKeyCode() method
        /// </summary>
        private static VirtualKeyCode? ConvertHIDToWindowsKeyCode(byte hidCode)
        {
            // HID Usage IDs from iPhone keyboard
            // Reference: https://www.usb.org/sites/default/files/documents/hut1_12v2.pdf
            return hidCode switch
            {
                // Letters
                0x04 => VirtualKeyCode.VK_A,
                0x05 => VirtualKeyCode.VK_B,
                0x06 => VirtualKeyCode.VK_C,
                0x07 => VirtualKeyCode.VK_D,
                0x08 => VirtualKeyCode.VK_E,
                0x09 => VirtualKeyCode.VK_F,
                0x0A => VirtualKeyCode.VK_G,
                0x0B => VirtualKeyCode.VK_H,
                0x0C => VirtualKeyCode.VK_I,
                0x0D => VirtualKeyCode.VK_J,
                0x0E => VirtualKeyCode.VK_K,
                0x0F => VirtualKeyCode.VK_L,
                0x10 => VirtualKeyCode.VK_M,
                0x11 => VirtualKeyCode.VK_N,
                0x12 => VirtualKeyCode.VK_O,
                0x13 => VirtualKeyCode.VK_P,
                0x14 => VirtualKeyCode.VK_Q,
                0x15 => VirtualKeyCode.VK_R,
                0x16 => VirtualKeyCode.VK_S,
                0x17 => VirtualKeyCode.VK_T,
                0x18 => VirtualKeyCode.VK_U,
                0x19 => VirtualKeyCode.VK_V,
                0x1A => VirtualKeyCode.VK_W,
                0x1B => VirtualKeyCode.VK_X,
                0x1C => VirtualKeyCode.VK_Y,
                0x1D => VirtualKeyCode.VK_Z,

                // Numbers
                0x1E => VirtualKeyCode.VK_1,
                0x1F => VirtualKeyCode.VK_2,
                0x20 => VirtualKeyCode.VK_3,
                0x21 => VirtualKeyCode.VK_4,
                0x22 => VirtualKeyCode.VK_5,
                0x23 => VirtualKeyCode.VK_6,
                0x24 => VirtualKeyCode.VK_7,
                0x25 => VirtualKeyCode.VK_8,
                0x26 => VirtualKeyCode.VK_9,
                0x27 => VirtualKeyCode.VK_0,

                // Special keys
                0x28 => VirtualKeyCode.RETURN,    // Enter
                0x29 => VirtualKeyCode.ESCAPE,
                0x2A => VirtualKeyCode.BACK,      // Backspace
                0x2B => VirtualKeyCode.TAB,
                0x2C => VirtualKeyCode.SPACE,
                0x2D => VirtualKeyCode.OEM_MINUS, // -
                0x2E => VirtualKeyCode.OEM_PLUS,  // =
                0x2F => VirtualKeyCode.OEM_4,     // [
                0x30 => VirtualKeyCode.OEM_6,     // ]
                0x31 => VirtualKeyCode.OEM_5,     // \
                0x33 => VirtualKeyCode.OEM_1,     // ;
                0x34 => VirtualKeyCode.OEM_7,     // '
                0x35 => VirtualKeyCode.OEM_3,     // `
                0x36 => VirtualKeyCode.OEM_COMMA, // ,
                0x37 => VirtualKeyCode.OEM_PERIOD,// .
                0x38 => VirtualKeyCode.OEM_2,     // /

                // Function keys
                0x3A => VirtualKeyCode.F1,
                0x3B => VirtualKeyCode.F2,
                0x3C => VirtualKeyCode.F3,
                0x3D => VirtualKeyCode.F4,
                0x3E => VirtualKeyCode.F5,
                0x3F => VirtualKeyCode.F6,
                0x40 => VirtualKeyCode.F7,
                0x41 => VirtualKeyCode.F8,
                0x42 => VirtualKeyCode.F9,
                0x43 => VirtualKeyCode.F10,
                0x44 => VirtualKeyCode.F11,
                0x45 => VirtualKeyCode.F12,

                // Arrow keys
                0x4F => VirtualKeyCode.RIGHT,
                0x50 => VirtualKeyCode.LEFT,
                0x51 => VirtualKeyCode.DOWN,
                0x52 => VirtualKeyCode.UP,

                _ => null
            };
        }

        // MARK: - Win32 API for mouse positioning

        [StructLayout(LayoutKind.Sequential)]
        private struct POINT
        {
            public int X;
            public int Y;
        }

        [DllImport("user32.dll")]
        private static extern bool SetCursorPos(int x, int y);

        [DllImport("user32.dll")]
        private static extern bool GetCursorPos(out POINT lpPoint);
    }
}
