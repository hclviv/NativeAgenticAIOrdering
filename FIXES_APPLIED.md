# Swift App Fixes - Menu Integration

## Issues Fixed

### 1. Location Selection Message Format
**Problem:** App was sending `"I'll select Subway - Shelton, CT"` but the BFF expected just `"Subway - Shelton, CT"`

**Fix:** Updated `ChatView.swift:152-156`
```swift
// Before
await viewModel.sendMessage("I'll select \(location.name)")

// After
await viewModel.sendMessage(location.name)
```

### 2. Menu Data Model Mismatch
**Problem:** Swift models didn't match the actual BFF API response structure

**Mismatches Found:**
- API returns `basePrice` → Swift expected `price`
- API returns `serves: {min, max}` → Swift expected `servings: "string"`
- API returns `imageURL` → Swift expected it missing

**Fix:** Updated `APIModels.swift:118-155`

**New Models:**
```swift
struct MenuCategory: Codable, Identifiable {
    let categoryId: String
    let name: String
    let imageURL: String?        // Added
    let items: [MenuItem]
}

struct MenuItemServes: Codable {  // New struct
    let min: Int?
    let max: Int?
}

struct MenuItem: Codable, Identifiable {
    let itemId: String
    let name: String
    let description: String?
    let basePrice: Double        // Changed from 'price'
    let serves: MenuItemServes?  // Changed from 'servings: String?'

    // Computed properties for easy display
    var displayPrice: Double { basePrice }
    var servingsText: String? {
        // Converts {min: 7, max: 7} to "7"
        // Converts {min: 10, max: 12} to "10-12"
    }
}
```

### 3. UI Component Updates
**Fix:** Updated `MenuListView.swift:139-156` to use new properties

```swift
// Before
if let servings = item.servings {
    Text("Serves \(servings)")
}
Text("$\(item.price)")

// After
if let servingsText = item.servingsText {
    Text("Serves \(servingsText)")
}
Text("$\(item.displayPrice)")
```

## Testing

### Test Flow:
1. **Start app** → Creates conversation
2. **Enter ZIP**: `10001` or `06484`
3. **Tap location card** → Now sends: `"Subway - Shelton, CT"`
4. **Should receive menu** with categories and items
5. **Tap menu item** → Sends: `"Add [item name] to my order"`

### Expected Debug Log:
```
🌐 API Request:
Body: {
  "conversationId" : "...",
  "userMessage" : "Subway - Shelton, CT"
}

📥 API Response:
Status: 200
Body: {
  "assistantText": "Here's the catering menu...",
  "uiModel": {
    "type": "menu",
    "categories": [...]
  }
}
```

## Verified Against Actual API Response

The Postman response shows these exact field names:
- ✅ `basePrice` (not price)
- ✅ `serves: {min, max}` (not servings string)
- ✅ `imageURL` (category images)
- ✅ Menu structure matches perfectly

## Files Modified

1. **APIModels.swift** - Fixed MenuItem and MenuCategory structures
2. **ChatView.swift** - Fixed location selection message format
3. **MenuListView.swift** - Updated to use new model properties

## Next Steps

1. Build and run the app
2. Test the full flow: ZIP → Location → Menu
3. Verify menu displays correctly with prices and servings
4. Check console logs to ensure proper request/response format

The app should now work end-to-end with your BFF!
