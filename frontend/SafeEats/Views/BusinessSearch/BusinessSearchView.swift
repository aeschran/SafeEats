//
//  BusinessSearchView.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/19/25.
//

import SwiftUI

struct BusinessSearchView: View {
    @ObservedObject var viewModel: BusinessSearchViewModel
    @State private var showFilters = false
    
    let cuisines = ["Italian", "Indian", "Mexican", "Asian"]
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(viewModel: viewModel)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    List(viewModel.businesses, id: \.id) { business in
                        NavigationLink(destination: BusinessDetailView(business: business)) {
                            
                            BusinessCard(
                                business: business,
                                rating: 4.5,
                                imageName: "self.crop.circle.fill"
                            )
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .onAppear(perform: viewModel.searchBusinesses)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button( action: {
                        // Action to open filter modal
                        showFilters.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill") // A more stylish filter icon
                            .resizable()
                            .frame(width: 22, height: 22) // Adjust size
                            .foregroundColor(.mainGreen) // Match theme
                            .padding(10)
                            .background(Color.mainGreen.opacity(0.2)) // Light green background
                            .clipShape(Circle()) // Makes it circular
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                PickPreferences(selectedCuisines: $viewModel.selectedCuisines, selectedAllergies: $viewModel.selectedAllergies, selectedDietaryRestrictions: $viewModel.selectedDietaryRestrictions)
                    .presentationDetents([.medium, .large])
                    .padding(.top, 40)
            }
            .onChange(of: showFilters) { oldValue, newValue in
                viewModel.searchBusinesses()
            }
        }
    }
}

#Preview {
    BusinessSearchView(viewModel: BusinessSearchViewModel())
}
