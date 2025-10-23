//
//  Test: Can iOS advertise as a Bluetooth Media Remote?
//
//  Theory: iOS might allow media control (volume, play/pause)
//  even if it blocks full keyboard HID
//

import CoreBluetooth
import Foundation

/*
Standard Bluetooth Profiles iOS might allow:

1. HID Service (0x1812) - ❌ BLOCKED for keyboard
   But what about HID with ONLY media keys?

2. Custom UUID with HID-like data - ✓ Allowed to advertise
   But computers won't recognize it

3. Audio/Video Remote Control Profile (AVRCP)
   - Could this work for media keys?

4. Consumer Control (part of HID)
   - Volume, Play/Pause, Next/Previous
   - Might have different restrictions?

IDEA: Start with media controls ONLY
- Play/Pause
- Volume Up/Down
- Next/Previous Track
- Mute

If THIS works, we prove iOS allows SOME input control.
Then we can explore expanding it.

Test Plan:
1. Create HID descriptor with ONLY consumer control keys
2. Try to add service
3. See if iOS blocks it or allows it
4. If allowed, test if Mac recognizes it
*/

// Consumer Control HID Report Descriptor (Media Keys Only)
let mediaRemoteDescriptor: [UInt8] = [
    0x05, 0x0C,        // Usage Page (Consumer)
    0x09, 0x01,        // Usage (Consumer Control)
    0xA1, 0x01,        // Collection (Application)
    0x85, 0x01,        //   Report ID (1)

    // Media Keys
    0x15, 0x00,        //   Logical Minimum (0)
    0x25, 0x01,        //   Logical Maximum (1)
    0x75, 0x01,        //   Report Size (1 bit)
    0x95, 0x08,        //   Report Count (8 bits = 8 keys)

    0x09, 0xCD,        //   Usage (Play/Pause)
    0x09, 0xB5,        //   Usage (Scan Next Track)
    0x09, 0xB6,        //   Usage (Scan Previous Track)
    0x09, 0xE9,        //   Usage (Volume Increment)
    0x09, 0xEA,        //   Usage (Volume Decrement)
    0x09, 0xE2,        //   Usage (Mute)
    0x09, 0x83,        //   Usage (Recall Last)
    0x09, 0x8A,        //   Usage (Mail)

    0x81, 0x02,        //   Input (Data, Variable, Absolute)
    0xC0               // End Collection
]

/*
QUESTION: Will iOS allow this media-only HID descriptor?

If YES: We can control media on computers without companion app!
        Then explore if we can sneak in keyboard keys later.

If NO: iOS blocks ALL HID, not just keyboard.
       Must use custom protocol + companion app.
*/
