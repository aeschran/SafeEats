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
    @StateObject private var viewModel = BusinessDetailViewModel()
    
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
                        if let restriction = PreferenceCategories(from: icon.preference) {
                            Image(restriction.assetName)
                                .resizable()
                                .renderingMode(.template) // Optional for coloring
                                .foregroundColor(Color.mainGreen)
                                .frame(width: 20, height: 20)
                        } else {
                            // Fallback if no match is found
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                // Rating
                HStack(spacing: 3) {
                    if let avg_rating = viewModel.avg_rating, viewModel.total_reviews != nil {
                        if avg_rating == 0.0 {
                            Text("No reviews")
                                .font(.headline)
                                .bold()
                        } else {
                            Text("\(String(format: "%.1f", avg_rating))")
                                .font(.headline)
                                .bold()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("(\(viewModel.total_reviews!))")
                                .foregroundColor(.gray)
                        }
                    } else {
                        ProgressView()
                            .font(.title)
                    }
                    let business_price = priceToDollarSigns(business.price)
                    if business_price != "No price" {
                        Text("•")
                        Text(business_price)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            await viewModel.fetchBusinessData(businessID: business.id)
        }
    }
    
    
}

