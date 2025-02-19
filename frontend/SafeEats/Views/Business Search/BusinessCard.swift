//
//  BusinessCard.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/19/25.
//

import SwiftUI

struct BusinessCard: View {
    var title: String
    var rating: Double
    var imageName: String // Business logo
    var allergenIcons: [String] = ["Vegetarian", "Vegan", "Gluten-Free"] // Array of allergen indicator image names

    var body: some View {
        HStack {
            Image(systemName: "fork.knife.circle")
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text("Lively, family-friendly chain featuring Italian standards such as pastas & salads")

                // Allergen icons
                HStack(spacing: 6) {
                    ForEach(allergenIcons, id: \.self) { icon in
                        Image(systemName: "leaf.circle.fill") // Load from Assets
                            .resizable()
                            .foregroundColor(Color.green)
                            .frame(width: 20, height: 20) // Small icons
                    }
                }

                // Rating
                HStack(spacing: 3) {
                    Text("\(String(format: "%.1f", rating))")
                        .font(.subheadline)
                        .bold()
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("(200+)")
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
}
