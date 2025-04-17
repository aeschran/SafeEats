//
//  EditListingView.swift
//  SafeEats
//
//  Created by Aditi Patel on 4/13/25.
//

import SwiftUI

struct EditListingView: View {
    var businessId: String
    @State private var website: String = ""
    @State private var description: String = ""
    @State private var tel: String = ""
    @State private var instagram: String = ""
    @State private var twitter: String = ""
    @State private var facebook_id: String = ""
    
    @StateObject var viewModel: OwnerBusinessDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showSuccessMessage = false
    
    private let fieldWidth: CGFloat = 265
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Edit Business Listing")
                        .font(.headline)
                        .scaleEffect(1.2)
                        .bold()
                        .padding(.vertical, 10)
                    
                    
                    // Business Info Fields
                    VStack(spacing: 15) {
                        CustomTextField(label: "Website", text: $website)
                        CustomTextField(label: "Phone Number", text: $tel)
                        CustomTextField(label: "Facebook", text: $facebook_id)
                        CustomTextField(label: "Instagram", text: $instagram)
                        CustomTextField(label: "Twitter", text: $twitter)
                    }
                    .padding()
                    
                    // Save Button
                    Button(action: {
                        let editedListingData: [String: Any] = [
                            "website": website,
                            "tel": tel,
                            "facebook_id": facebook_id,
                            "instagram": instagram,
                            "twitter": twitter
                        ]
                        print("Edited Business Listing Data:", editedListingData)
                        viewModel.sendEditedBusinessData(editedListingData, businessId: businessId)
                        showSuccessMessage = true
                        
                        
                    }) {
                        Text("Save Listing")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 40)
                            .background(Color.mainGreen)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    .alert("Listing updated successfully!", isPresented: $showSuccessMessage) {
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


#Preview {
    EditListingView(businessId: "1", viewModel: OwnerBusinessDetailViewModel())
}
