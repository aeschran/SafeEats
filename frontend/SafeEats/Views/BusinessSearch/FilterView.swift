//
//  FilterView.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/19/25.
//

import SwiftUI

struct FilterView: View {
    @Binding var selectedCuisines: Set<String>
    let cuisines = ["Italian", "Indian", "Mexican", "Asian"]
    @Binding var selectedAllergies: Set<String>
    @Binding var selectedDietaryRestrictions: Set<String>
    @Environment(\.dismiss) var dismiss
    
    @State private var showAllergies = false
    @State private var showDietaryRestrictions = false
    @State private var showCuisines = false
    
    
    let allergies = ["Peanuts", "Dairy", "Gluten", "Shellfish"]
    let dietaryRestrictions = ["Vegan", "Vegetarian", "Halal", "Kosher"]
    
    var body: some View {
        NavigationStack {
            // Cuisine Filters (Expandable)
            ScrollView {
                VStack {
                    DisclosureGroup("Cuisines", isExpanded:  $showCuisines) {
                        ForEach(cuisines, id: \.self) { cuisine in
                            Toggle(isOn: Binding(
                                get: { selectedCuisines.contains(cuisine) },
                                set: { newValue in
                                    if newValue {
                                        selectedCuisines.insert(cuisine)
                                    } else {
                                        selectedCuisines.remove(cuisine)
                                    }
                                }
                            )) {
                                Text(cuisine)
                            }
                        }
                    }
                    .bold()
                    .disclosureGroupStyle()
                    
                    // Allergy Filters (Expandable)
                    DisclosureGroup("Allergies", isExpanded: $showAllergies) {
                        ForEach(allergies, id: \.self) { allergy in
                            Toggle(allergy, isOn: Binding(
                                get: { selectedAllergies.contains(allergy) },
                                set: { newValue in
                                    if newValue {
                                        selectedAllergies.insert(allergy)
                                    } else {
                                        selectedAllergies.remove(allergy)
                                    }
                                }))
                        }
                    }
                    .bold()
                    .disclosureGroupStyle()
                    
                    // Dietary Restrictions (Expandable)
                    DisclosureGroup("Dietary Restrictions", isExpanded: $showDietaryRestrictions) {
                        ForEach(dietaryRestrictions, id: \.self) { restriction in
                            Toggle(restriction, isOn: Binding(
                                get: {selectedDietaryRestrictions.contains(restriction) },
                                set: { newValue in
                                    if newValue {
                                        selectedDietaryRestrictions.insert(restriction)
                                    } else {
                                        selectedDietaryRestrictions.remove(restriction)
                                    }
                                }))
                        }
                    }
                    .bold()
                    .disclosureGroupStyle()
                }
                .navigationTitle("Filter")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func disclosureGroupStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.mainGreen.opacity(0.4), Color.white]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.mainGreen.opacity(0.8), lineWidth: 2)
            )
            .padding(.horizontal)
            .font(.title2)
    }
}
