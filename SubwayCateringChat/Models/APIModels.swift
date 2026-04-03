//
//  APIModels.swift
//  SubwayCateringChat
//
//  API request and response models for BFF communication
//

import Foundation

// MARK: - Request Models

struct CreateConversationResponse: Codable {
    let conversationId: String
}

struct ChatRequest: Codable {
    let conversationId: String
    let userMessage: String
    let uiContext: [String: String]?

    init(conversationId: String, userMessage: String, uiContext: [String: String]? = nil) {
        self.conversationId = conversationId
        self.userMessage = userMessage
        self.uiContext = uiContext
    }

    // Custom encoding to omit uiContext when nil
    enum CodingKeys: String, CodingKey {
        case conversationId
        case userMessage
        case uiContext
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(conversationId, forKey: .conversationId)
        try container.encode(userMessage, forKey: .userMessage)
        if let uiContext = uiContext {
            try container.encode(uiContext, forKey: .uiContext)
        }
    }
}

// MARK: - Response Models

struct ChatResponse: Codable {
    let assistantText: String
    let suggestedActions: [String]?
    let uiModel: UIModel?
    let conversationStateVersion: Int
}

// MARK: - UI Model Types

enum UIModel: Codable {
    case locations(LocationsUIModel)
    case menu(MenuUIModel)

    enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "locations":
            let model = try LocationsUIModel(from: decoder)
            self = .locations(model)
        case "menu":
            let model = try MenuUIModel(from: decoder)
            self = .menu(model)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown UI model type: \(type)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .locations(let model):
            try model.encode(to: encoder)
        case .menu(let model):
            try model.encode(to: encoder)
        }
    }
}

struct LocationsUIModel: Codable {
    let type: String
    let locations: [Location]
    let visualsAllowed: Bool?
}

struct Location: Codable, Identifiable {
    let locationId: String
    let name: String
    let address: String
    let phone: String?
    let distance: Double?
    let cateringAvailable: Bool?

    var id: String { locationId }
}

struct MenuUIModel: Codable {
    let type: String
    let locationId: String
    let locationName: String
    let categories: [MenuCategory]
    let visualsAllowed: Bool?
}

struct MenuCategory: Codable, Identifiable {
    let categoryId: String
    let name: String
    let imageURL: String?
    let items: [MenuItem]

    var id: String { categoryId }

    enum CodingKeys: String, CodingKey {
        case categoryId
        case name
        case imageURL = "imageUrl"
        case items
    }
}

struct MenuItemServes: Codable {
    let min: Int?
    let max: Int?
}

struct MenuItem: Codable, Identifiable {
    let itemId: String
    let name: String
    let description: String?
    let basePrice: Double
    let serves: MenuItemServes?

    var id: String { itemId }

    // Computed property for display
    var displayPrice: Double { basePrice }

    var servingsText: String? {
        guard let serves = serves else { return nil }
        if let min = serves.min, let max = serves.max {
            return min == max ? "\(min)" : "\(min)-\(max)"
        } else if let min = serves.min {
            return "\(min)"
        } else if let max = serves.max {
            return "\(max)"
        }
        return nil
    }
}

// MARK: - Complete Checkout

struct OrderFormData {
    var numberOfGuests: Int = 8
    var complimentaryItems: Set<String> = ["NAPKINS", "PLATES"]
    var specialInstructions: String = ""
    var vehicleType: String = "SUV"
    var vehicleColor: String = "Black"
    var mobilePhone: String = ""
    var gratuityPercent: Int = 18

    init(
        numberOfGuests: Int = 8,
        complimentaryItems: Set<String> = ["NAPKINS", "PLATES"],
        specialInstructions: String = "",
        vehicleType: String = "SUV",
        vehicleColor: String = "Black",
        mobilePhone: String = "",
        gratuityPercent: Int = 18
    ) {
        self.numberOfGuests = numberOfGuests
        self.complimentaryItems = complimentaryItems
        self.specialInstructions = specialInstructions
        self.vehicleType = vehicleType
        self.vehicleColor = vehicleColor
        self.mobilePhone = mobilePhone
        self.gratuityPercent = gratuityPercent
    }
}

struct CompleteCheckoutRequest: Codable {
    let conversationId: String
    let numberOfGuests: Int?
    let complimentaryItems: [String]?
    let specialInstructions: String?
    let vehicleType: String
    let vehicleColor: String
    let mobilePhone: String
    let gratuityPercent: Int?
}

struct CompleteCheckoutResponse: Codable {
    let orderId: String
    let status: String
    let confirmationText: String
}

// MARK: - Error Response

struct APIErrorResponse: Codable {
    let statusCode: Int
    let timestamp: String
    let correlationId: String
    let message: String
}
