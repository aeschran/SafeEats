//
//  CreateListingView.swift
//  SafeEats
//
//  Created by Aditi Patel on 3/31/25.
//

import SwiftUI

struct CreateListingView: View {
    @State private var businessName: String = ""
    @State private var website: String = ""
    @State private var description: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var tel: String = ""
    @State private var zipcode: String = ""
    @State private var selectedCuisines: Set<String> = []
    @State private var selectedDietaryRestrictions: Set<String> = []
    @State private var selectedAllergies: Set<String> = []
    @State private var menuLink: String = ""
    let cuisineMapping: [String: Int] = [
        "Asian": 13100,
        "Italian": 13236,
        "Mexican": 13308,
        "Indian": 13198
    ]
    var selectedCuisineNumbers: [Int] {
        selectedCuisines.compactMap { cuisineMapping[$0] }
    }
    
    @StateObject var viewModel: CreateListingViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showSuccessMessage = false
    
    private let fieldWidth: CGFloat = 265
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Create Business Listing")
                        .font(.headline)
                        .scaleEffect(1.2)
                        .bold()
                        .padding(.bottom, 10)
                    
                    
                    // Business Info Fields
                    VStack(spacing: 15) {
                        CustomTextField(label: "Business Name", text: $businessName)
                        CustomTextField(label: "Website", text: $website)
                        CustomTextField(label: "Phone Number", text: $tel)
                        CustomTextField(label: "Menu Link", text: $menuLink)
                        CustomTextField(label: "Street Address", text: $address)
                        CustomTextField(label: "City", text: $city)
                        CustomTextField(label: "State", text: $state)
                        CustomTextField(label: "Zip Code", text: $zipcode)
                            .keyboardType(.numberPad) // Restrict input to numbers
                                    .onChange(of: zipcode) { newValue in
                                        zipcode = newValue.filter { $0.isNumber }
                                    }
                        
                        
                        VStack(alignment: .leading) {
                            Text("Description")
                                .fontWeight(.semibold)
                                .frame(width: 100, alignment: .leading)
                            TextEditor(text: $description)
                                .frame(height: 60)
                                .padding(6)
                                .scrollContentBackground(.hidden)
                                .background(Color.mainGray)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGray.darker()))
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    
                    
                    VStack {
                        Text("Accommodations")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 5)
                        PickPreferences(selectedCuisines: $selectedCuisines, selectedAllergies: $selectedAllergies, selectedDietaryRestrictions: $selectedDietaryRestrictions)
                    }
                    .padding(.vertical, 10)
                    // Save Button
                    Button(action: {
                        let preferences = selectedAllergies.map { ["preference": $0, "preference_type": "Allergy"] } +
                        selectedDietaryRestrictions.map { ["preference": $0, "preference_type": "Dietary Restriction"] }

                        let listingData: [String: Any] = [
                            "name": businessName,
                            "website": website,
                            "tel": tel,
                            "menu": menuLink,
                            "description": description,
                            "address": "\(address), \(city), \(state) \(zipcode)",
                            "cuisines": Array(selectedCuisineNumbers),
                            "dietary_restrictions": preferences,
                        ]
                        print(listingData)
                        print("Business Listing Data:", listingData)
                        viewModel.sendCreatedBusinessData(listingData)
                        showSuccessMessage = true
                        
                        
                    }) {
                        Text("Create Listing")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 40)
                            .background(Color.mainGreen)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .alert("Listing saved successfully!", isPresented: $showSuccessMessage) {
                        Button("OK") {
                            
                            presentationMode.wrappedValue.dismiss() // Navigate back to OwnerListingsView
                        }
                    }
                }
                .padding()
            }
        }
    }
}


struct CustomTextField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.semibold)
                .font(.callout)
                .frame(width: 150, alignment: .leading)
            TextField("", text: $text)
                .padding(8)
                .background(Color.mainGray)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGray.darker()))
        }
        .padding(.horizontal)
    }
}


#Preview {
    CreateListingView(viewModel: CreateListingViewModel())
}

