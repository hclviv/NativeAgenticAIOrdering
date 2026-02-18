# Subway Catering Chat - SwiftUI App

A modern iOS chatbot application for Subway catering orders, powered by AI and built with SwiftUI.

## Architecture

This app follows the architecture you specified:
- **SwiftUI Frontend** - Native iOS UI with animations and modern design
- **BFF (Backend for Frontend)** - NestJS server at `http://localhost:3000/v1`
- **Mock Server** - WireMock for simulating backend APIs

## Project Structure

```
SubwayCateringChat/
├── Models/
│   ├── APIModels.swift           # API request/response models
│   └── Message.swift              # Chat message model
├── Services/
│   └── APIClient.swift            # Network client for BFF communication
├── ViewModels/
│   └── ChatViewModel.swift        # State management & business logic
├── Views/
│   ├── ChatView.swift             # Main chat interface
│   └── Components/
│       ├── MessageBubbleView.swift
│       ├── TypingIndicatorView.swift
│       ├── SuggestedActionsView.swift
│       ├── LocationsListView.swift
│       └── MenuListView.swift
├── Theme/
│   └── Theme.swift                # Subway brand colors & styles
├── ContentView.swift              # Root view with splash screen
└── SubwayCateringChatApp.swift    # App entry point
```

## Features

### Core Functionality
- Real-time chat interface with AI assistant
- Conversation session management
- Message history with timestamps
- Typing indicators
- Error handling with user-friendly messages

### UI Components
- **Message Bubbles** - Distinct styling for user vs assistant messages
- **Quick Reply Buttons** - Suggested actions for easy interaction
- **Locations View** - Horizontal scrolling cards showing nearby Subway stores
- **Menu View** - Expandable categories with menu items and pricing
- **Splash Screen** - Animated brand intro

### User Experience
- Smooth animations and transitions
- Auto-scrolling to latest messages
- Loading states
- Keyboard handling
- Pull-to-refresh conversation

## Setup Instructions

### 1. Add Files to Xcode Project

All Swift files have been created in the correct directories. You need to add them to your Xcode project:

1. Open `SubwayCateringChat.xcodeproj` in Xcode
2. Right-click on the `SubwayCateringChat` folder in the navigator
3. Select **"Add Files to SubwayCateringChat"**
4. Navigate to each directory and add the files:
   - `Models/APIModels.swift`
   - `Models/Message.swift`
   - `Services/APIClient.swift`
   - `ViewModels/ChatViewModel.swift`
   - `Views/ChatView.swift`
   - `Views/Components/MessageBubbleView.swift`
   - `Views/Components/TypingIndicatorView.swift`
   - `Views/Components/SuggestedActionsView.swift`
   - `Views/Components/LocationsListView.swift`
   - `Views/Components/MenuListView.swift`
   - `Theme/Theme.swift`
5. Make sure **"Copy items if needed"** is unchecked (files are already in place)
6. Make sure **"SubwayCateringChat" target** is checked

### 2. Update Info.plist for Network Access

Since you're connecting to `localhost:3000`, you need to allow local network access:

1. Open your Xcode project
2. Select the `SubwayCateringChat` target
3. Go to the **Info** tab
4. Add the following key-value pair:
   - **Key:** `App Transport Security Settings` (Dictionary)
     - **Key:** `Allow Arbitrary Loads in Web Content` (Boolean) = `YES`
     - **Key:** `NSAllowsLocalNetworking` (Boolean) = `YES`

Alternatively, add this to your Info.plist:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

### 3. Start Your BFF Server

Before running the app, make sure your BFF is running:

```bash
cd /Users/vivekshrivastav/Documents/Personal/Agentic\ Use\ Case/CustomAgenticAIAgent
npm run start:dev
```

The server should be running at `http://localhost:3000`

### 4. Run the App

1. Select a simulator or device in Xcode
2. Press `Cmd + R` to build and run
3. The app will launch with a splash screen, then automatically start a conversation

## How to Use

1. **Start Conversation** - App automatically creates a conversation on launch
2. **Enter ZIP Code** - Type your ZIP code to find nearby Subway locations
3. **Select Location** - Tap a location card or use suggested actions
4. **Browse Menu** - Expand categories and tap items to add to order
5. **Checkout** - Follow the conversation flow to complete your order

## API Integration

The app communicates with your BFF using these endpoints:

### Create Conversation
```
POST http://localhost:3000/v1/conversations
Response: { conversationId: string }
```

### Send Message
```
POST http://localhost:3000/v1/chat
Body: {
  conversationId: string,
  userMessage: string,
  uiContext?: object
}
Response: {
  assistantText: string,
  suggestedActions?: string[],
  uiModel?: LocationsUIModel | MenuUIModel,
  conversationStateVersion: number
}
```

### Health Check
```
GET http://localhost:3000/v1/health
Response: { status: "ok", timestamp: string }
```

## Customization

### Colors (Theme.swift)
```swift
static let subwayGreen = Color(red: 0/255, green: 145/255, blue: 42/255)
static let subwayYellow = Color(red: 252/255, green: 200/255, blue: 0/255)
```

### Base URL (APIClient.swift)
```swift
private let baseURL = "http://localhost:3000/v1"
```

Change this if deploying to a different environment.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Running BFF server at `localhost:3000`

## Troubleshooting

### Connection Refused
- Ensure BFF server is running on port 3000
- Check Info.plist has local networking permissions
- Verify simulator/device can reach localhost

### Build Errors
- Make sure all files are added to the Xcode target
- Clean build folder: `Cmd + Shift + K`
- Rebuild: `Cmd + B`

### UI Not Updating
- Check that `@Observable` macro is working (requires iOS 17+)
- Verify `ChatViewModel` is using `@MainActor`

## Architecture Diagram

```
┌─────────────────┐
│   SwiftUI App   │
│  (iOS Client)   │
└────────┬────────┘
         │ HTTP/REST
         ▼
┌─────────────────┐
│   BFF Server    │
│   (NestJS)      │
│  localhost:3000 │
└────────┬────────┘
         │
         ├──────► OpenAI API (GPT-4)
         │
         └──────► WireMock (Mock Backend)
```

## Next Steps

1. **Testing** - Add unit tests and UI tests
2. **Persistence** - Save conversation history locally
3. **Push Notifications** - Order status updates
4. **Analytics** - Track user interactions
5. **Accessibility** - VoiceOver support
6. **Localization** - Multi-language support

## License

Built for Capgemini Innovation POC
