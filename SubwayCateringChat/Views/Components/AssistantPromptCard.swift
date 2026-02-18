//
//  AssistantPromptCard.swift
//  SubwayCateringChat
//
//  Beautiful inline prompt/question card for assistant messages with UI models
//

import SwiftUI

struct AssistantPromptCard: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            // AI Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.2), Color.green.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
            }

            // Question Text
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer(minLength: 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 16) {
        AssistantPromptCard(text: "How many Classic Sandwich Platters would you like to add to your order?")

        AssistantPromptCard(text: "Great choice! Would you like to add any sides or drinks?")

        AssistantPromptCard(text: "What time would you like to pick up your order?")
    }
    .padding()
}
