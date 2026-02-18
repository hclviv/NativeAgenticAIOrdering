//
//  Theme.swift
//  SubwayCateringChat
//
//  App theme and branding colors
//

import SwiftUI

extension Color {
    // Subway Brand Colors
    static let subwayGreen = Color(red: 0/255, green: 145/255, blue: 42/255)
    static let subwayYellow = Color(red: 252/255, green: 200/255, blue: 0/255)

    // Custom UI Colors
    static let primaryAccent = subwayGreen
    static let secondaryAccent = subwayYellow
}

// Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.primaryAccent)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.primaryAccent.opacity(0.1))
            .foregroundColor(.primaryAccent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryAccent, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
