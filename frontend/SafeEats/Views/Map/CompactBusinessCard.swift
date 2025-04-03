//
//  CompactBusinessCard.swift
//  SafeEats
//
//  Created by Jon Hurley on 4/2/25.
//

import SwiftUI

struct CompactBusinessCard: View {
    var business: Business
    var rating: Double
    
    var body: some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                NavigationLink(destination: BusinessDetailView(business: business))
                {
                    Text(business.name ?? "No Name")
                        .font(.title3)
                        .bold()
                }
               
                
                HStack(spacing: 3) {
                    Text("\(String(format: "%.1f", rating))")
                        .font(.body)
                        .bold()
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.yellow)
                }
            }
            
            HStack(spacing: 4) {
                ForEach(business.dietary_restrictions ?? [], id: \.self) { restriction in
                    if let category = PreferenceCategories(from: restriction.preference) {
                        Image(category.assetName)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.green)
                            .frame(width: 6, height: 6)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 2))
    }
}
