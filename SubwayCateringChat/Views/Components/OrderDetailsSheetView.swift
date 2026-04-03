//
//  OrderDetailsSheetView.swift
//  SubwayCateringChat
//
//  Catering checkout form — shown when user initiates checkout.
//  Collects order instructions, curbside info, and gratuity.
//  "Place Order" proceeds to Apple Pay, then calls the checkout API.
//

import SwiftUI

struct OrderDetailsSheetView: View {
    @State private var numberOfGuests: Int = 8
    @State private var selectedComplimentaryItems: Set<String> = ["NAPKINS", "PLATES"]
    @State private var specialInstructions: String = ""
    @State private var vehicleType: String = "SUV"
    @State private var vehicleColor: String = "Black"
    @State private var mobilePhone: String = ""
    @State private var gratuityPercent: Int = 18

    let locationName: String?
    let onPlaceOrder: (OrderFormData) -> Void
    let onCancel: () -> Void

    private let vehicleTypes = ["SUV", "Sedan", "Truck", "Van", "Minivan", "Other"]
    private let vehicleColors = ["Black", "White", "Silver", "Gray", "Red", "Blue", "Green", "Yellow", "Other"]
    private let gratuityOptions = [0, 15, 18, 20]
    private let complimentaryOptions: [(id: String, label: String)] = [
        ("NAPKINS", "Napkins"),
        ("PLATES", "Plates"),
        ("UTENSILS", "Utensils"),
        ("CONDIMENTS", "Condiments"),
        ("CUPS", "Cups"),
        ("ICE", "Ice"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // System drag indicator space
            Color.clear.frame(height: 28)

            // Header
            HStack {
                Button("Cancel", action: onCancel)
                    .foregroundColor(.primaryAccent)
                Spacer()
                Text("Catering Checkout")
                    .font(.headline)
                Spacer()
                Text("Cancel").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Location banner
                    if let location = locationName {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.primaryAccent)
                            Text(location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                    }

                    // MARK: Order Instructions

                    CheckoutSectionHeader("Order Instructions")

                    // Number of Guests
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Guests")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 16) {
                            Button {
                                if numberOfGuests > 1 { numberOfGuests -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primaryAccent)
                            }

                            Text("\(numberOfGuests)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(minWidth: 32)
                                .multilineTextAlignment(.center)

                            Button {
                                if numberOfGuests < 200 { numberOfGuests += 1 }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primaryAccent)
                            }

                            Spacer()
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    // Complimentary Items
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Complimentary Items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 10
                        ) {
                            ForEach(complimentaryOptions, id: \.id) { option in
                                ComplimentaryChip(
                                    label: option.label,
                                    isSelected: selectedComplimentaryItems.contains(option.id)
                                ) {
                                    if selectedComplimentaryItems.contains(option.id) {
                                        selectedComplimentaryItems.remove(option.id)
                                    } else {
                                        selectedComplimentaryItems.insert(option.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    // Special Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Special Instructions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField(
                            "e.g., Call when ready. No-contact curbside pickup.",
                            text: $specialInstructions,
                            axis: .vertical
                        )
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .lineLimit(3...6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                    Divider()

                    // MARK: Pickup Method

                    CheckoutSectionHeader("Pickup Method: Curbside")

                    CheckoutPickerRow(label: "Vehicle Type", selection: $vehicleType, options: vehicleTypes)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)

                    CheckoutPickerRow(label: "Vehicle Color", selection: $vehicleColor, options: vehicleColors)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mobile Phone")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("2035551212", text: $mobilePhone)
                            .keyboardType(.phonePad)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                    Divider()

                    // MARK: Gratuity

                    CheckoutSectionHeader("Gratuity")

                    HStack(spacing: 10) {
                        ForEach(gratuityOptions, id: \.self) { percent in
                            Button {
                                gratuityPercent = percent
                            } label: {
                                Text(percent == 0 ? "No tip" : "\(percent)%")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(gratuityPercent == percent ? .white : .primaryAccent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        gratuityPercent == percent
                                            ? Color.primaryAccent
                                            : Color.primaryAccent.opacity(0.1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)

                    // MARK: Place Order Button

                    Button {
                        let formData = OrderFormData(
                            numberOfGuests: numberOfGuests,
                            complimentaryItems: selectedComplimentaryItems,
                            specialInstructions: specialInstructions,
                            vehicleType: vehicleType,
                            vehicleColor: vehicleColor,
                            mobilePhone: mobilePhone,
                            gratuityPercent: gratuityPercent
                        )
                        onPlaceOrder(formData)
                    } label: {
                        Text("Place Order")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.primaryAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Supporting Views

private struct CheckoutSectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CheckoutPickerRow: View {
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

private struct ComplimentaryChip: View {
    let label: String
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 5) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .primaryAccent : .secondary)
                    .font(.subheadline)
                Text(label)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.primaryAccent.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.primaryAccent : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    OrderDetailsSheetView(
        locationName: "Jimmy John's - Atlanta, GA",
        onPlaceOrder: { _ in },
        onCancel: {}
    )
}
