//
//  BusinessSearchView.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/19/25.
//

import SwiftUI

struct BusinessSearchView: View {
    @State private var showFilters = false
    @State private var selectedCuisines = Set<String>(["Italian"])
    @State private var selectedDietaryRestrictions: Set<String> = []
    @State private var selectedAllergies: Set<String> = []
    
    let cuisines = ["Italian", "Indian", "Mexican", "Thai"]
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar()
                
                List {
                    BusinessCard(title: "Olive Garden - West Lafayette", rating: 4.7, imageName: "self.crop.circle.fill")
                    BusinessCard(title: "Olive Garden - Greater Lafayette", rating: 4.8, imageName: "self.crop.circle.fill")
                }
                .listStyle(.inset)
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button( action: {
                        // Action to open filter modal
                        showFilters.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill") // A more stylish filter icon
                            .resizable()
                            .frame(width: 22, height: 22) // Adjust size
                            .foregroundColor(.green) // Match theme
                            .padding(10)
                            .background(Color.green.opacity(0.2)) // Light green background
                            .clipShape(Circle()) // Makes it circular
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(selectedCuisines: $selectedCuisines, selectedAllergies: $selectedAllergies, selectedDietaryRestrictions: $selectedDietaryRestrictions)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    BusinessSearchView()
}
