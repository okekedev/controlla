# AirType WiFi Protocol

## Discovery (Bonjour)

**Service Type:** `_airtype._tcp.local.`
**Port:** 8080
**Name:** Computer name (e.g., "Christian's MacBook Pro")

## API Endpoints

### 1. Health Check
```
GET /status
Response: {"status": "ready", "version": "1.0"}
```

### 2. Send Text
```
POST /keyboard/text
Body: {"text": "Hello World"}
Response: {"success": true}
```

### 3. Send Key
```
POST /keyboard/key
Body: {
  "keycode": 4,        // 'A' key
  "modifier": 0        // 0=none, 1=ctrl, 2=shift, 4=alt, 8=cmd
}
Response: {"success": true}
```

### 4. Move Mouse
```
POST /mouse/move
Body: {
  "deltaX": 10,
  "deltaY": -5
}
Response: {"success": true}
```

### 5. Mouse Click
```
POST /mouse/click
Body: {
  "button": "left"    // "left", "right", or "middle"
}
Response: {"success": true}
```

### 6. Voice Input
```
POST /keyboard/text
Body: {"text": "transcribed speech here"}
Response: {"success": true}
```

## Connection Flow

1. **iPhone discovers** Macs via Bonjour
2. **User selects** Mac from list
3. **iPhone connects** to `http://[mac-ip]:8080`
4. **iPhone sends** keyboard/mouse commands as JSON
5. **Mac receives** and simulates input

## Why This Works

✅ **Simple:** REST API with JSON (not raw bytes)
✅ **Fast:** Local network, low latency
✅ **Reliable:** HTTP with proper error handling
✅ **Debuggable:** Can test with curl/Postman
✅ **Auto-discovery:** Bonjour finds Macs automatically
✅ **Secure:** Only works on same WiFi network
