//
//  CollectionDetailView.swift
//  SafeEats
//
//  Created by Jack Rookstool on 3/31/25.
//

import SwiftUI

let businessCollections: [BusinessCollection] = []

struct CollectionDetailView: View {
    let collection: Collection
    
    var body: some View {
        VStack {
            // TODO: Display the actual items from the collection here
            if collection.businesses.isEmpty {
                Spacer()
                Text("No businesses in this collection yet.")
                    .foregroundColor(.secondary)
            }
            else {
                List(collection.businesses, id: \.businessId) { business in
                                Button(action: {
                                    let business_id = business.businessId
                                    let business: Business = await
                                }) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(business.businessName)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(business.businessDescription)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(business.businessAddress)
                                            .font(.footnote)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
            }
            
            
            
            Spacer()
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CollectionDetailView(collection: Collection(id: "1", name: "Temp", userId: "1", businesses: businessCollections))
}
