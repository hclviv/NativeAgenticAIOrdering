//
//  SuggestedActionsView.swift
//  SubwayCateringChat
//
//  Quick reply buttons for suggested actions
//

import SwiftUI

struct SuggestedActionsView: View {
    let actions: [String]
    let onActionTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(actions, id: \.self) { action in
                    Button(action: {
                        onActionTap(action)
                    }) {
                        Text(action)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.primaryAccent.opacity(0.1))
                            .foregroundColor(.primaryAccent)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.primaryAccent, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    SuggestedActionsView(
        actions: ["Select Store Name", "Browse Menu", "View Cart"],
        onActionTap: { _ in }
    )
}
