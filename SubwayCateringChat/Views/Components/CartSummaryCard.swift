//
//  CartSummaryCard.swift
//  SubwayCateringChat
//
//  Simple cart summary component
//

import SwiftUI

struct CartSummaryCard: View {
    let cartText: String

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "cart.fill")
                    .foregroundColor(.white)
                Text("Your Cart")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.green)

            // Cart Items - Simple list
            VStack(spacing: 0) {
                ForEach(extractCartItems(from: cartText), id: \.self) { item in
                    SimpleCartItemRow(item: item)
                    if item != extractCartItems(from: cartText).last {
                        Divider()
                    }
                }

                // Total at bottom
                if let total = extractTotal(from: cartText) {
                    Divider()
                        .background(Color.green.opacity(0.3))
                        .padding(.top, 8)

                    HStack {
                        Text("Total")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text(total)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.05))
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    // MARK: - Helper Methods

    private func extractTotal(from text: String) -> String? {
        // Extract total like "$61.84" from "**Total**: $61.84"
        let pattern = #"\*\*Total\*\*:\s*\$?([\d,]+\.?\d*)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text) {
            return "$" + String(text[range])
        }
        return nil
    }

    private func extractCartItems(from text: String) -> [String] {
        // Extract lines like "- **Classic Sandwich Platter**: 2 @ $57.79 each"
        var items: [String] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            // Match pattern: "- **ItemName**: quantity @ $price each"
            if line.contains("**") && line.contains("@") && !line.contains("Subtotal") && !line.contains("Total") && !line.contains("Tax") {
                items.append(line)
            }
        }

        return items
    }

    private func extractPriceBreakdown(from text: String) -> PriceBreakdown? {
        let subtotal = extractPrice(from: text, label: "Subtotal")
        let tax = extractPrice(from: text, label: "Tax")
        let total = extractPrice(from: text, label: "Total")

        if subtotal != nil || tax != nil || total != nil {
            return PriceBreakdown(subtotal: subtotal, tax: tax, total: total)
        }
        return nil
    }

    private func extractPrice(from text: String, label: String) -> String? {
        let pattern = "\\*\\*\(label)\\*\\*:\\s*\\$?([\\d,]+\\.?\\d*)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text) {
            return "$" + String(text[range])
        }
        return nil
    }
}

// MARK: - Supporting Views

struct SimpleCartItemRow: View {
    let item: String

    var body: some View {
        HStack(spacing: 12) {
            // Item Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: "fork.knife")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
            }

            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                Text(extractItemName(from: item))
                    .font(.headline)
                    .fontWeight(.semibold)

                if let details = extractItemDetails(from: item) {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }

    private func extractItemName(from item: String) -> String {
        // Extract "Classic Sandwich Platter" from "- **Classic Sandwich Platter**: 2 @ $57.79 each"
        if let startRange = item.range(of: "**"),
           let endRange = item.range(of: "**:", range: startRange.upperBound..<item.endIndex) {
            return String(item[startRange.upperBound..<endRange.lowerBound])
        }
        return item
    }

    private func extractItemDetails(from item: String) -> String? {
        // Extract "2 @ $57.79 each" from "- **Classic Sandwich Platter**: 2 @ $57.79 each"
        if let colonRange = item.range(of: "**: ") {
            let details = String(item[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            return details.isEmpty ? nil : details
        }
        return nil
    }
}

struct PriceRow: View {
    let label: String
    let amount: String
    let isTotal: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(isTotal ? .primary : .secondary)

            Spacer()

            Text(amount)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(isTotal ? .green : .primary)
        }
    }
}

struct PriceBreakdown {
    let subtotal: String?
    let tax: String?
    let total: String?
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        CartSummaryCard(cartText: """
        You've added 2 Classic Sandwich Platters to your cart. Here's a summary:

        - **Classic Sandwich Platter**: 2 @ $57.79 each
        - **Subtotal**: $115.58
        - **Tax**: $8.09
        - **Total**: $123.67

        Would you like to review nutrition or allergen information for your order, or proceed to checkout?
        """)

        Spacer()
    }
    .padding()
}
