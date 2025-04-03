//
//  ClaimBusinessView.swift
//  SafeEats
//
//  Created by Aditi Patel on 3/31/25.
//

import SwiftUI

struct ClaimBusinessView: View {
    @StateObject private var viewModel = ClaimBusinessViewModel()
    @State private var isCreatingListing = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ClaimBusinessSearchBar(viewModel: viewModel)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if viewModel.businesses.isEmpty {
                    VStack {
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
                } else {
                    List(viewModel.businesses, id: \.name) { business in
                        VStack(spacing: 10) {
                            HStack {
                                NavigationLink(destination: BusinessDetailView(business: business)) {
                                    BusinessCard(
                                        business: business,
                                        rating: 4.5,
                                        imageName: "self.crop.circle.fill"
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
                    .listStyle(.inset)
                }
                                    
            }
            
        }
        .navigationTitle("Claim a Business")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct ClaimBusinessSearchBar: View {
//    @ObservedObject var viewModel: ClaimBusinessViewModel
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//            TextField("Search for business...", text: $viewModel.query)
//                .onSubmit {
//                    viewModel.fetchSearchResults()
//                }
//        }
//        .padding(10)
//        .background(RoundedRectangle(cornerRadius: 10).fill(Color.mainGreen.opacity(0.1)))
//        .padding(.horizontal)
//    }
//}

// Helper function to truncate description
func truncatedDescription(for text: String, limit: Int = 100) -> String {
    if text.count > limit {
        let index = text.index(text.startIndex, offsetBy: limit)
        return text[..<index] + "..."
    }
    return text
}


#Preview {
    ClaimBusinessView()
}
