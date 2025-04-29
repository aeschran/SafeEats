//
//  BusinessSearchView.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/19/25.
//

import SwiftUI

enum SortOption {
    case priceLowToHigh
    case priceHighToLow
    case ratingsLowToHigh
    case ratingsHighToLow
    // Add more if needed
}

struct BusinessSearchView: View {
    @ObservedObject var viewModel: BusinessSearchViewModel
    @State private var showFilters = false
    let cuisines = ["Italian", "Indian", "Mexican", "Asian"]
    @State private var showRandomRestaurant = false
    @State private var selectedBusiness: Business? = nil
    @State private var isTryingAgain = false
    @State private var isFetchingRandomBusiness = false


    
    
    @State private var sortOption: SortOption?
    
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
                    HStack {
                        Text("Can't choose? Let us choose for you!")
                            .font(.headline)
                            .padding()
                        
                        
                        Button("Pick for me") {
                            isFetchingRandomBusiness = true
                            viewModel.fetchRandomRestaurant()
                        }
                        .onChange(of: viewModel.didFetchRandomBusiness) { _, _ in
                            showRandomRestaurant = true
                            isTryingAgain = false
                            isFetchingRandomBusiness = false
                        }
                        .padding()
                        .background(Color.mainGray)
                        .cornerRadius(17)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                    }
                    Divider().background(Color.gray)
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
                ToolbarItem(placement: .topBarLeading) {
                    /* TODO: add functionality to sorting */
                    Menu {
                        Button("Price: Low to High") {
                            sortOption = .priceLowToHigh
                            viewModel.businesses = viewModel.businesses.sorted {
                                $0.price ?? 0 <= $1.price ?? 0
                            }
                        }
                        Button("Price: High to Low") {
                            sortOption = .priceHighToLow
                            viewModel.businesses = viewModel.businesses.sorted {
                                $0.price ?? 0 >= $1.price ?? 0
                            }
                        }
                        Button("Ratings: Low to High") {
                            sortOption = .ratingsLowToHigh
                            viewModel.businesses = viewModel.businesses.sorted {
                                $0.avg_rating ?? 0 <= $1.avg_rating ?? 0
                            }
                        }
                        Button("Ratings: High to Low") {
                            sortOption = .ratingsHighToLow
                            viewModel.businesses = viewModel.businesses.sorted {
                                $0.avg_rating ?? 0 >= $1.avg_rating ?? 0
                            }
                        }
                        // Add more filters if needed
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.square.fill")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.mainGreen)
                            .padding(10)
                            .background(Color.mainGreen.opacity(0.2))
                            .clipShape(Circle())
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
            .sheet(isPresented: $showRandomRestaurant) {
                if let randomBusiness = viewModel.randomBusiness {
                    NavigationStack {
                        ScrollView {
                            VStack(alignment: .center, spacing: 24) {
                                
                                Text("🎉 We chose this place for you!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, 30)
                                
                                Text(randomBusiness.name ?? "No business name")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)
                                
                                if let description = randomBusiness.description {
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                
                                Divider()
                                    .padding(.vertical)
                                
                                Text("Check out more information below!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                
                                NavigationLink(destination: BusinessDetailView(business: randomBusiness)) {
                                    Text("View Full Business Page")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.mainGreen)
                                        .cornerRadius(12)
                                        .padding(.horizontal, 40)
                                }
                                .padding(.top, 20)
                                
                                Button(action: {
                                    isTryingAgain = true
                                    isFetchingRandomBusiness = true
                                    viewModel.fetchRandomRestaurant()
                                }) {
                                    if isTryingAgain {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.mainGray)
                                            .cornerRadius(12)
                                            .padding(.horizontal, 40)
                                    } else {
                                        Text("Try Again")
                                            .font(.headline)
                                            .foregroundColor(Color.black)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.mainGray)
                                            .cornerRadius(12)
                                            .padding(.horizontal, 40)
                                    }
                                }
                                .padding(.bottom, 30)

                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    VStack {
                        Text("No restaurant meets your criteria.")
                            .font(.title2)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                }
            }

        }
    }
}

#Preview {
    BusinessSearchView(viewModel: BusinessSearchViewModel())
}
