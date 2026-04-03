//
//  MenuListView.swift
//  SubwayCateringChat
//
//  Instagram-style menu feed with large category images
//

import SwiftUI

struct MenuListView: View {
    let menuModel: MenuUIModel
    let onItemSelect: (MenuItem) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Catering Menu")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(menuModel.locationName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "fork.knife")
                        .foregroundColor(.primaryAccent)
                        .font(.title2)
                }
                .padding()
                .background(Color(.systemBackground))

                // Categories Feed
                ForEach(menuModel.categories) { category in
                    InstagramCategorySection(
                        category: category,
                        onItemSelect: onItemSelect
                    )
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Instagram-Style Category Section

struct InstagramCategorySection: View {
    let category: MenuCategory
    let onItemSelect: (MenuItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Large Category Image
            if let imageURL = category.imageURL {
                NetworkImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Text(category.name)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                            }
                        )
                } placeholder: {
                    ZStack {
                        LinearGradient(
                            colors: [Color.primaryAccent.opacity(0.8), Color.primaryAccent.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        VStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text(category.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                }
            } else {
                // Fallback for no image
                ZStack {
                    LinearGradient(
                        colors: [Color.primaryAccent.opacity(0.3), Color.primaryAccent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Text(category.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryAccent)
                }
                .frame(height: 200)
            }

            // Horizontal Scrolling Items
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(category.items.count) Items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(category.items) { item in
                            InstagramMenuItemCard(item: item)
                                .onTapGesture {
                                    onItemSelect(item)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Instagram-Style Menu Item Card

struct InstagramMenuItemCard: View {
    let item: MenuItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Item Image Placeholder with gradient
            ZStack {
                LinearGradient(
                    colors: [Color.primaryAccent.opacity(0.15), Color.primaryAccent.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(.primaryAccent.opacity(0.4))
            }
            .frame(width: 200, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 6) {
                // Item Name
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .frame(height: 36, alignment: .top)

                // Servings
                if let servingsText = item.servingsText {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption2)
                        Text("Serves \(servingsText)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                // Price and Add Button
                HStack {
                    Text("$\(String(format: "%.2f", item.displayPrice))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryAccent)

                    Spacer()

                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.primaryAccent)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 200)
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview {
    MenuListView(
        menuModel: MenuUIModel(
            type: "menu",
            locationId: "CT-06484-001",
            locationName: "Subway - Shelton, CT",
            categories: [
                MenuCategory(
                    categoryId: "PLATTERS",
                    name: "Platters",
                    imageURL: "https://www.subway.com/en-us/-/media/northamerica/usa/catering/catering-1536x1019-1.png?la=en-US&h=1280&w=1280&mw=1280",
                    items: [
                        MenuItem(
                            itemId: "101",
                            name: "Classic Sandwich Platter",
                            description: "Assorted classic subs cut into thirds",
                            basePrice: 57.79,
                            serves: MenuItemServes(min: 7, max: 7)
                        ),
                        MenuItem(
                            itemId: "102",
                            name: "Premium Sandwich Platter",
                            description: "Premium subs with extra toppings",
                            basePrice: 67.99,
                            serves: MenuItemServes(min: 7, max: 7)
                        ),
                        MenuItem(
                            itemId: "103",
                            name: "Wrap Platter",
                            description: "Fresh wraps variety",
                            basePrice: 68.39,
                            serves: MenuItemServes(min: 8, max: 8)
                        )
                    ]
                ),
                MenuCategory(
                    categoryId: "DESSERTS",
                    name: "Desserts",
                    imageURL: "https://www.subdelivery.com.sg/orders/axmenu/images/category/67/20241116071011-Cookies-Platter.jpg",
                    items: [
                        MenuItem(
                            itemId: "201",
                            name: "Cookie Platter",
                            description: "36 freshly baked cookies",
                            basePrice: 23.99,
                            serves: MenuItemServes(min: 36, max: 36)
                        ),
                        MenuItem(
                            itemId: "202",
                            name: "Footlong Cookie",
                            description: "Giant cookie perfect for sharing",
                            basePrice: 5.00,
                            serves: MenuItemServes(min: 6, max: 6)
                        )
                    ]
                )
            ],
            visualsAllowed: false
        ),
        onItemSelect: { _ in }
    )
}
