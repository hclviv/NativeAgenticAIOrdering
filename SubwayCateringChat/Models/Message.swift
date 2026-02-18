//
//  Message.swift
//  SubwayCateringChat
//
//  Chat message model
//

import Foundation

struct Message: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    let suggestedActions: [String]?
    let uiModel: UIModel?

    init(
        id: UUID = UUID(),
        text: String,
        isUser: Bool,
        timestamp: Date = Date(),
        suggestedActions: [String]? = nil,
        uiModel: UIModel? = nil
    ) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.suggestedActions = suggestedActions
        self.uiModel = uiModel
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
