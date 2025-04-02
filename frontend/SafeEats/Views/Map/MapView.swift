//
//  MapView.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/22/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: BusinessSearchViewModel
    @State private var showFilters: Bool = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4237, longitude: -86.9212), // Default to Purdue University
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map {
                    // User location radius
                    MapCircle(center: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude), radius: CLLocationDistance(viewModel.radius))
                        .foregroundStyle(.blue.opacity(0.2))
                    
                    // Specialized Markers for businesses
                    ForEach(viewModel.businessesMap) { business in
                        let coordinate = CLLocationCoordinate2D(latitude: business.location.lat, longitude: business.location.lon)
                        
                        Annotation(business.name, coordinate: coordinate) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.green.opacity(0.8))
                                    .frame(width: 40, height: 40)
                                Text("🍽️") // Customize with icons for different cuisines
                                    .font(.title)
                            }
                        }
                    }
                }
                .mapControlVisibility(.hidden)
                .ignoresSafeArea()
                .onAppear {
                    viewModel.searchBusinessesMap() // Start fetching data
                }
                .onReceive(viewModel.$businessesMap) { _ in
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude), 
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
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
                    viewModel.searchBusinessesMap()
                }
                
                VStack {
                    Text("Map Page")
                        .font(.title)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MapView(viewModel: BusinessSearchViewModel())
}
