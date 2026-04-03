//
//  ApplePaySheetView.swift
//  SubwayCateringChat
//
//  Simulated Apple Pay bottom sheet for demo purposes.
//  Shown before calling the checkout API; completion triggers the real API call.
//

import SwiftUI

struct ApplePaySheetView: View {
    let orderTotal: Double?
    let locationName: String?
    let onPay: () -> Void
    let onCancel: () -> Void

    @State private var isProcessing = false
    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            // System drag indicator space
            Color.clear.frame(height: 44)

            // Header
            HStack {
                Button("Cancel", action: onCancel)
                    .foregroundColor(.primaryAccent)
                Spacer()
                Text("Apple Pay")
                    .font(.headline)
                Spacer()
                // Balance the Cancel button width
                Text("Cancel").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Divider()

            // Merchant info
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.primaryAccent)
                        .frame(width: 56, height: 56)
                    Text("JJ")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
                .padding(.top, 24)

                Text("Jimmy John's Catering")
                    .font(.title3)
                    .fontWeight(.semibold)

                if let location = locationName {
                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 20)

            Divider()

            // Order summary
            VStack(spacing: 12) {
                HStack {
                    Text("Catering Order")
                        .foregroundColor(.secondary)
                    Spacer()
                    if let total = orderTotal {
                        Text(String(format: "$%.2f", total))
                            .fontWeight(.medium)
                    } else {
                        Text("PAY AT PICKUP")
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                HStack {
                    Text("Total")
                        .fontWeight(.semibold)
                    Spacer()
                    if let total = orderTotal {
                        Text(String(format: "$%.2f", total))
                            .fontWeight(.bold)
                            .font(.title3)
                    } else {
                        Text("PAY AT PICKUP")
                            .fontWeight(.bold)
                            .foregroundColor(.primaryAccent)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            // Payment method row
            HStack(spacing: 12) {
                Image(systemName: "applelogo")
                    .font(.title3)
                Text("Apple Pay")
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            Divider()

            Spacer(minLength: 16)

            // Pay button
            if showSuccess {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Payment Authorized")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 20)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    handlePayment()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.black)
                            .frame(height: 56)

                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "applelogo")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                Text("Pay")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .disabled(isProcessing)
                .padding(.horizontal, 20)
            }

            // Face ID hint
            if !showSuccess {
                HStack(spacing: 6) {
                    Image(systemName: "faceid")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Confirm with Face ID")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }

            Spacer(minLength: 32)
        }
        .background(Color(.systemBackground))
    }

    private func handlePayment() {
        isProcessing = true

        // Simulate Face ID / biometric delay
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2s
            withAnimation(.spring(response: 0.4)) {
                isProcessing = false
                showSuccess = true
            }
            // Brief moment to show success before dismissing
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s
            onPay()
        }
    }
}

#Preview {
    ApplePaySheetView(
        orderTotal: 85.88,
        locationName: "Jimmy John's - Atlanta, GA",
        onPay: {},
        onCancel: {}
    )
}
