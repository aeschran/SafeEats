//
//  PickPreferences.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/22/25.
//

import SwiftUI

struct PickPreferences: View {
    @Binding var selectedCuisines: Set<String>
    @Binding var selectedAllergies: Set<String>
    @Binding var selectedDietaryRestrictions: Set<String>
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showCuisines = false
    @State private var showAllergies = false
    @State private var showDietaryRestrictions = false
    
    private let cuisines = ["Italian", "Indian", "Mexican", "Thai"]
    private let allergies = ["Peanuts", "Dairy", "Gluten", "Shellfish"]
    private let dietaryRestrictions = ["Vegan", "Vegetarian", "Halal", "Kosher"]
    
    private let optionsFontSize: CGFloat = 20
    private let categoryFontSize: CGFloat = 22
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    PreferenceDisclosureGroup(title: "Cuisines", isExpanded: $showCuisines, options: cuisines, selectedOptions: $selectedCuisines)
                    Divider().background(.gray)
                    PreferenceDisclosureGroup(title: "Allergies", isExpanded: $showAllergies, options: allergies, selectedOptions: $selectedAllergies)
                    Divider().background(.gray)
                    PreferenceDisclosureGroup(title: "Dietary Restrictions", isExpanded: $showDietaryRestrictions, options: dietaryRestrictions, selectedOptions: $selectedDietaryRestrictions)
                }
                .background(Color.mainGray)
                .cornerRadius(15)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .tint(.clear)
    }
}

struct PreferenceDisclosureGroup: View {
    let title: String
    @Binding var isExpanded: Bool
    let options: [String]
    @Binding var selectedOptions: Set<String>
    
    private let optionsFontSize: CGFloat = 20
    private let categoryFontSize: CGFloat = 22
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(spacing: 5) {
                ForEach(options, id: \..self) { option in
                    HStack {
                        Image(systemName: selectedOptions.contains(option) ? "checkmark.square" : "square")
                            .font(.system(size: optionsFontSize))
                        Text(option)
                            .foregroundColor(.black)
                            .font(.system(size: optionsFontSize))
                            .padding(.leading, 10) // padding betwen checkbox and text
                    }
                    .padding(.vertical, 5) // padding between options
                    .padding(.leading, 30) // padding between the edge and checkbox
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        if selectedOptions.contains(option) {
                            selectedOptions.remove(option)
                        } else {
                            selectedOptions.insert(option)
                        }
                    }
                }
            }
            .padding(.vertical, 5) // padding between category title and options
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: categoryFontSize, weight: .bold))
                    .frame(height: 35)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
            .padding(.horizontal, 20) // padding between category title and drop-down
            .foregroundColor(.black)
        }
        .padding(.vertical, 10) // padding for each section
        .animation(.easeInOut, value: isExpanded)
                    
    }
}
