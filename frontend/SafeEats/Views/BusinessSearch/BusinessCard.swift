//
//  BusinessCard.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/19/25.
//

import SwiftUI

struct BusinessCard: View {
    var business: Business
    var rating: Double
    var imageName: String // Business logo
    
    var body: some View {
        HStack {
            Image(systemName: "fork.knife.circle")
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(business.name ?? "No Name")
                    .font(.headline)
                Text(business.description ?? "No Description")
                
                // Allergen icons
                HStack(spacing: 6) {
                    ForEach(business.dietary_restrictions ?? [], id: \.self) { icon in
                        Image(systemName: "leaf.circle.fill") // Load from Assets
                            .resizable()
                            .foregroundColor(Color.mainGreen)
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
