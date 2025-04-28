//
//  OwnerListingView.swift
//  SafeEats
//
//  Created by harshini on 4/2/25.
//

import SwiftUI

struct OwnerListingsView: View {
    @StateObject private var viewModel = OwnerListingsViewModel()
    @StateObject private var notifViewModel = NotificationsViewModel()
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
                viewModel.fetchOwnerListings{
                    notifViewModel.fetchNotificationsForBusinesses(viewModel.businessIdsAndNames)
                }
            
            }
            
            
            .navigationBarTitle("My Listings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack(alignment: .bottomTrailing) {
                        NavigationLink(destination: AllBusinessNotificationsView(businesses: viewModel.businessIdsAndNames)) {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(Color.mainGreen)
                        }

                        if notifViewModel.showBellDot {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                                .offset(x:-10, y: -8)
                            
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView().environmentObject(SettingsViewModel())) {
                        Image(systemName: "line.3.horizontal") // Settings icon
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                
            }
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

