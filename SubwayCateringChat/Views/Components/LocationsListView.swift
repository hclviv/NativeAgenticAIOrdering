//
//  LocationsListView.swift
//  SubwayCateringChat
//
//  Clean, modern location cards
//

import SwiftUI

struct LocationsListView: View {
    let locationsModel: LocationsUIModel
    let onLocationSelect: (Location) -> Void

    var body: some View {
        VStack(spacing: 16) {
            ForEach(locationsModel.locations) { location in
                ModernLocationCard(location: location)
                    .onTapGesture {
                        onLocationSelect(location)
                    }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct ModernLocationCard: View {
    let location: Location

    var body: some View {
        HStack(spacing: 16) {
            // Icon/Distance Section
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryAccent.opacity(0.15), Color.primaryAccent.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundColor(.primaryAccent)
                }

                if let distance = location.distance {
                    Text(String(format: "%.1f mi", distance))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryAccent)
                }
            }

            // Location Info
            VStack(alignment: .leading, spacing: 6) {
                Text(location.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)

                if let cateringAvailable = location.cateringAvailable, cateringAvailable {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Catering Available")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.primaryAccent)
                }
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.title3)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.primaryAccent.opacity(0.3), Color.primaryAccent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Preview

#Preview {
    LocationsListView(
        locationsModel: LocationsUIModel(
            type: "locations",
            locations: [
                Location(
                    locationId: "CT-06484-001",
                    name: "Subway - Shelton, CT",
                    address: "123 Main St, Shelton, CT 06484",
                    phone: "(203) 123-4567",
                    distance: 0.8,
                    cateringAvailable: true
                ),
                Location(
                    locationId: "CT-06484-002",
                    name: "Subway - Bridgeport, CT",
                    address: "456 State St, Bridgeport, CT 06604",
                    phone: "(203) 987-6543",
                    distance: 2.3,
                    cateringAvailable: true
                ),
                Location(
                    locationId: "CT-06484-003",
                    name: "Subway - Milford, CT",
                    address: "789 Boston Post Rd, Milford, CT 06460",
                    phone: "(203) 555-0123",
                    distance: 4.1,
                    cateringAvailable: true
                )
            ],
            visualsAllowed: false
        ),
        onLocationSelect: { _ in }
    )
}
