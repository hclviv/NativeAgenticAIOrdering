//
//  Theme.swift
//  SubwayCateringChat
//
//  App theme and branding colors
//

import SwiftUI

extension Color {
    // Jimmy John's Brand Colors
    static let jjRed = Color(red: 227/255, green: 24/255, blue: 54/255)
    static let jjBlack = Color(red: 20/255, green: 20/255, blue: 20/255)

    // Custom UI Colors
    static let primaryAccent = jjRed
    static let secondaryAccent = jjBlack
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
