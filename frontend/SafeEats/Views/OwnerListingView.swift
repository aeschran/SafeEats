//
//  OwnerListingView.swift
//  SafeEats
//
//  Created by harshini on 4/2/25.
//

import SwiftUI

struct OwnerListingsView: View {
    @StateObject private var viewModel = OwnerListingsViewModel()
//    let business: Business
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading listings...")
                        .padding()
                } else if viewModel.businesses.isEmpty {
                    Text("You have no business listings.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.businesses, id: \.id) { business in
                                OwnerBusinessCardView(business: business)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                    }
                }
            }
            .onAppear {
                viewModel.fetchOwnerListings()
            }
            .navigationBarTitle("My Listings", displayMode: .inline)
        }
    }
}

struct OwnerBusinessCardView: View {
    let business: Business

    var body: some View {
        NavigationLink(destination: OwnerBusinessDetailView(business: business)) {
            BusinessCard(
                business: business,
                rating: 4.5,
                imageName: "fork.knife.circle"
            )
        }
        .buttonStyle(PlainButtonStyle()) // Removes default NavigationLink styling
    }
}

