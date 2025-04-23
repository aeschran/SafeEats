//
//  FilterMapView.swift
//  SafeEats
//
//  Created by Jon Hurley on 4/3/25.
//

import SwiftUI

struct FilterMapView: View {
    @Binding var selectedCuisines: Set<String>
    @Binding var selectedAllergies: Set<String>
    @Binding var selectedDietaryRestrictions: Set<String>
    @Binding var radius: Double  // New binding for search radius
    @Binding var cuisineOrRestrictionSelected: Bool

    @Environment(\.dismiss) var dismiss

    @State private var showCuisines = false
    @State private var showAllergies = false
    @State private var showDietaryRestrictions = false

    private let cuisines = ["Italian", "Asian", "Mexican", "Indian"]
    private let allergies = ["Peanuts", "Dairy", "Gluten", "Shellfish"]
    private let dietaryRestrictions = ["Vegan", "Vegetarian", "Halal", "Kosher"]
    
    private let radiusSteps: [Double] = [1, 5, 10, 25]  // Fixed values for radius selection

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    // Radius Selection Slider
                    VStack(alignment: .leading) {
                        Text("Search Radius: \(Int(radius)) miles")
                            .bold()
                            .padding(.bottom, 4)

                        Slider(value: $radius, in: 1...25, step: 1)
                            .padding(.horizontal)

                        HStack {
                            ForEach(radiusSteps, id: \.self) { step in
                                Text("\(Int(step))")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    
                    // Switch for dietary restriction or cuisine icons
                    Button(action: {
                        cuisineOrRestrictionSelected.toggle()
                    }) {
                        Label(cuisineOrRestrictionSelected ? "Display Restrictions" : "Display Cuisines", systemImage: "arrow.up")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                    }

                    // Preference Sections
                    preferenceDisclosureGroup(title: "Cuisines", isExpanded: $showCuisines, options: cuisines, selectedOptions: $selectedCuisines)
                    Divider().background(.gray)
                    preferenceDisclosureGroup(title: "Allergies", isExpanded: $showAllergies, options: allergies, selectedOptions: $selectedAllergies)
                    Divider().background(.gray)
                    preferenceDisclosureGroup(title: "Dietary Restrictions", isExpanded: $showDietaryRestrictions, options: dietaryRestrictions, selectedOptions: $selectedDietaryRestrictions)
                }
                .background(Color.mainGray)
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
            }
        }
        .tint(.clear)
    }
}
