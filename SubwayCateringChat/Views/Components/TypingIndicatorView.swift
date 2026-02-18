//
//  TypingIndicatorView.swift
//  SubwayCateringChat
//
//  Animated typing indicator for assistant
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer(minLength: 60)
        }
        .padding(.horizontal)
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            animationPhase = 1
        }
    }
}

#Preview {
    TypingIndicatorView()
}
