//
//  MessageBubbleView.swift
//  SubwayCateringChat
//
//  Individual message bubble component
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Use AttributedString to render markdown formatting
                Text(LocalizedStringKey(message.text))
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color.primaryAccent : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    VStack {
        MessageBubbleView(message: Message(
            text: "Hello! I'd like to order catering.",
            isUser: true
        ))

        MessageBubbleView(message: Message(
            text: "Great! I can help you with that. What's your ZIP code?",
            isUser: false
        ))
    }
}
