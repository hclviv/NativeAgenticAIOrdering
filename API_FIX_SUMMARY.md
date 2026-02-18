# API Integration Fix Summary

## Changes Made

### 1. Fixed ChatRequest Encoding (APIModels.swift)
**Issue:** The `uiContext` field was being included in the JSON even when nil, which could cause validation errors.

**Fix:** Added custom encoding to omit `uiContext` when it's nil:
```swift
func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(conversationId, forKey: .conversationId)
    try container.encode(userMessage, forKey: .userMessage)
    if let uiContext = uiContext {
        try container.encode(uiContext, forKey: .uiContext)
    }
}
```

**Expected JSON Output:**
```json
{
  "conversationId": "abc-123",
  "userMessage": "Hello"
}
```
(Note: `uiContext` is omitted, not sent as `null`)

### 2. Added Debug Logging (APIClient.swift)
Added comprehensive logging to help diagnose any issues:
- Request URL, method, headers, and body
- Response status code and body
- Error messages

**To view logs:**
1. Run the app in Xcode
2. Open the Console (Cmd+Shift+Y)
3. You'll see logs like:
```
🌐 API Request:
URL: http://localhost:3000/v1/chat
Method: POST
Headers: ["Content-Type": "application/json"]
Body: {
  "conversationId" : "abc-123",
  "userMessage" : "10001"
}

📥 API Response:
Status: 200
Body: {"assistantText":"...","conversationStateVersion":1}
```

**To disable logging:**
Set `enableDebugLogging = false` in APIClient.swift:72

## Verified API Contracts

### POST /v1/conversations
**Request:** Empty body
**Response:**
```json
{
  "conversationId": "string"
}
```
✅ Matches CreateConversationResponse in Swift

### POST /v1/chat
**Request:**
```json
{
  "conversationId": "string (required)",
  "userMessage": "string (required)",
  "uiContext": {} // optional, omitted if not provided
}
```
✅ Matches ChatRequest in Swift

**Response:**
```json
{
  "assistantText": "string",
  "suggestedActions": ["string"],  // optional
  "uiModel": {                      // optional
    "type": "locations" | "menu",
    ...
  },
  "conversationStateVersion": 0
}
```
✅ Matches ChatResponse in Swift

## Testing Steps

### 1. Start the BFF Server
```bash
cd ~/Documents/Personal/Agentic\ Use\ Case/CustomAgenticAIAgent
npm run start:dev
```

Verify it's running:
```bash
curl http://localhost:3000/v1/health
# Should return: {"status":"ok","timestamp":"..."}
```

### 2. Build and Run the iOS App
1. Open SubwayCateringChat.xcodeproj in Xcode
2. Make sure all new Swift files are added to the target
3. Select a simulator (iOS 17+)
4. Press Cmd+R to build and run

### 3. Test the Conversation Flow

**Expected Flow:**
1. App launches with splash screen
2. Automatically creates a conversation
3. Shows welcome message
4. Enter a ZIP code (e.g., "10001")
5. Should receive locations list
6. Tap a location or use suggested action
7. Should receive menu
8. Tap a menu item
9. Continue conversation...

### 4. Check the Logs

In Xcode Console, you should see:
```
🌐 API Request:
URL: http://localhost:3000/v1/conversations
Method: POST

📥 API Response:
Status: 200
Body: {"conversationId":"..."}

🌐 API Request:
URL: http://localhost:3000/v1/chat
Body: {
  "conversationId" : "...",
  "userMessage" : "10001"
}

📥 API Response:
Status: 200
Body: {"assistantText":"...","uiModel":{"type":"locations",...}}
```

## Troubleshooting

### Connection Refused
**Symptom:** "Network error: The operation couldn't be completed"
**Fix:**
1. Verify BFF is running on port 3000
2. Check Info.plist has App Transport Security settings
3. Try `curl http://localhost:3000/v1/health` from terminal

### 400 Bad Request
**Symptom:** "Server error (400): Validation failed"
**Fix:** Check the request body in logs matches expected format

### 404 Not Found (Conversation)
**Symptom:** "Server error (404): Conversation xxx not found"
**Fix:**
1. Make sure conversation was created before sending messages
2. Check conversationId in logs is being sent correctly

### Decoding Error
**Symptom:** "Failed to decode response"
**Fix:**
1. Check response body in logs
2. Verify uiModel type matches expected structure
3. Ensure all required fields are present

## Example Request/Response

### Create Conversation
```
🌐 REQUEST: POST http://localhost:3000/v1/conversations
(empty body)

📥 RESPONSE: 200
{
  "conversationId": "abc-123-def-456"
}
```

### Send Message
```
🌐 REQUEST: POST http://localhost:3000/v1/chat
{
  "conversationId": "abc-123-def-456",
  "userMessage": "10001"
}

📥 RESPONSE: 200
{
  "assistantText": "I found 3 Subway locations near 10001...",
  "suggestedActions": ["Select Store Name"],
  "uiModel": {
    "type": "locations",
    "locations": [...]
  },
  "conversationStateVersion": 1
}
```

## What Was Fixed

1. ✅ Request body now omits `uiContext` when nil (was causing validation errors)
2. ✅ Added debug logging for request/response inspection
3. ✅ Verified all DTOs match BFF expectations
4. ✅ Pretty-printed JSON in logs for easier debugging

## Next Steps

1. Run the app and check the console logs
2. If you see any errors, share the exact log output
3. Verify the request body format matches expected structure
4. Test the full conversation flow end-to-end
