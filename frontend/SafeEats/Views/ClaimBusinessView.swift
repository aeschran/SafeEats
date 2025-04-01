//
//  ClaimBusinessView.swift
//  SafeEats
//
//  Created by Aditi Patel on 3/31/25.
//

import SwiftUI

struct ClaimBusinessView: View {
    @StateObject private var viewModel = BusinessSearchViewModel()
    @State private var isCreatingListing = false
    
    var body: some View {
        NavigationStack {
            VStack {
                BusinessSearchBar(viewModel: viewModel)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
//                } else if viewModel.businesses.isEmpty {
//                    VStack {
//                        Text("No businesses found.")
//                        NavigationLink(destination: CreateListingView(), isActive: $isCreatingListing) {
//                            Button("Create a New Listing") {
//                                isCreatingListing = true
//                            }
//                            .buttonStyle(.borderedProminent)
//                            .padding()
//                        }
//                        
//                    }
                } else {
                    List {
                        let exactMatchExists = viewModel.businesses.contains { business in
                            business.name?.localizedCaseInsensitiveCompare(viewModel.query) == .orderedSame
                        }
                        
                        if !exactMatchExists {
                            HStack(alignment: .center) {
                                Text("Didn't find your business?")
                                    .font(.headline)
                                    .padding()
                                
                                NavigationLink(destination: CreateListingView(), isActive: $isCreatingListing) {
                                    Button("Create a New Listing") {
                                        isCreatingListing = true
                                    }
                                    .padding()
                                    .background(Color.mainGreen)
                                    .cornerRadius(17)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                }
                                .padding()
                                
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowInsets(EdgeInsets()) // Ensures it spans across the list
                            
                        }
                        
                        // Display businesses
                        ForEach(viewModel.businesses, id: \.name) { business in
                            VStack(spacing: 10) {
                                HStack {
                                    NavigationLink(destination: BusinessDetailView(business: business)) {
                                        BusinessCard(
                                            title: business.name ?? "No Name",
                                            rating: 4.5,
                                            imageName: "self.crop.circle.fill",
                                            description: truncatedDescription(for: business.description ?? "No Description")
                                        )
                                    }
                                    Spacer()
                                }
                                
                                Button("Claim") {
                                    // TODO: add claim listing logic
                                }
                                .buttonStyle(AuthButtonType())
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listStyle(.inset)
                }
                
                
            }
            .navigationTitle("Claim a Business")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Helper function to truncate description
    func truncatedDescription(for text: String, limit: Int = 100) -> String {
        if text.count > limit {
            let index = text.index(text.startIndex, offsetBy: limit)
            return text[..<index] + "..."
        }
        return text
    }
    
}

#Preview {
    ClaimBusinessView()
}
