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

extension View {
    func preferenceDisclosureGroup(title: String, isExpanded: Binding<Bool>, options: [String], selectedOptions: Binding<Set<String>>) -> some View {
        DisclosureGroup(isExpanded: isExpanded) {
            VStack() {
                ForEach(options, id: \..self) { option in
                    HStack {
                        Image(systemName: selectedOptions.wrappedValue.contains(option) ? "checkmark.square" : "square")
                            .font(.footnote)
                            .scaleEffect(1.3)
                        Text(option)
                            .foregroundColor(.black)
                            .font(.footnote)
                            .scaleEffect(1.3)
                            .padding(.leading, 10) // padding between checkbox and text
                    }
                    .padding(.vertical, 5) // padding between options
                    .padding(.leading, 30) // padding bewteen edge and checkbox
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        if selectedOptions.wrappedValue.contains(option) {
                            selectedOptions.wrappedValue.remove(option)
                        } else {
                            selectedOptions.wrappedValue.insert(option)
                        }
                    }
                }
            }
            .padding(.vertical, 5) // padding between category title and options
        } label: {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .frame(height: 35)
                Spacer()
                Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
            }
            .padding(.horizontal, 20) // padding between category title and drop down
            .foregroundColor(.black)
        }
        .padding(.vertical, 5) // padding for each section
        .animation(.easeInOut, value: isExpanded.wrappedValue)
    }
}
