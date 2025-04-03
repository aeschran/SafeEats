//
//  CollectionDetailView.swift
//  SafeEats
//
//  Created by Jack Rookstool on 3/31/25.
//

import SwiftUI

let businessCollections: [BusinessCollection] = [
    BusinessCollection(
        businessId: "biz001",
        businessName: "Sunrise Smoothies",
        businessDescription: "Fresh fruit smoothies and healthy snacks.",
        businessAddress: "101 Wellness Way, Springfield"
    ),

    BusinessCollection(
        businessId: "biz002",
        businessName: "Eco Eats",
        businessDescription: "Sustainable, plant-based meals made fresh daily.",
        businessAddress: "202 Green Street, Riverdale"
    ),
        
    BusinessCollection(
        businessId: "biz003",
        businessName: "BBQ Bros",
        businessDescription: "Classic Southern barbecue with a modern twist.",
        businessAddress: "303 Smokehouse Blvd, Austin"
    )
]

struct CollectionDetailView: View {
    @Binding var collection: Collection
    @StateObject var viewModel = CollectionDetailViewModel()
    @State private var selectedBusiness: Business?
    @State private var navigateToBusinessDetail = false
    @State private var isEditingName = false
    @State private var editedCollectionName: String = ""
    @State private var displayedName: String = ""
    @State private var hasAppeared = false
    
    func getBusinessInformation(businessId: String) async {
        await viewModel.getBusinessInformation(businessId: businessId)
        selectedBusiness = viewModel.business
        navigateToBusinessDetail = true
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(collection.name ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if collection.name != "Bookmarks" {
                    Button(action: {
                        editedCollectionName = collection.name
                        isEditingName = true
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            
            if collection.businesses.isEmpty {
                Spacer()
                Text("No businesses in this collection yet.")
                    .foregroundColor(.secondary)
            }
            else {
                List(collection.businesses, id: \.businessId) { business in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(business.businessName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(business.businessDescription)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(business.businessAddress)
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Button(action: {
                            // TODO: Remove business from collection
                            Task {
                                let b_id = business.businessId
                                let c_id = collection.id
                                if let updated = await viewModel.removeBusinessFromCollection(businessId: b_id, collectionId: c_id) {
                                    print(updated)
//                                    collection.businesses = updated.businesses
                                }
                                if let index = collection.businesses.firstIndex(where: { $0.businessId == b_id }) {
                                    collection.businesses.remove(at: index)
                                }
                            }
                        }) {
                            Image(systemName: "xmark.square")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.red)
                                .padding(8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onTapGesture {}
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            let b_id = business.businessId
                            await getBusinessInformation(businessId: b_id)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToBusinessDetail) {
            if let selectedBusiness = selectedBusiness {
                BusinessDetailView(business: selectedBusiness)
            }
        }
        .alert("Edit Collection Name", isPresented: $isEditingName) {
            TextField("Edit Collection Name", text: $editedCollectionName)
            Button("Cancel", role: .cancel) {
                isEditingName = false
            }
            Button("Save") {
                Task {
                    viewModel.errorMessage = nil
                    await viewModel.editCollectionName(collectionId: collection.id, editedName: editedCollectionName)
                    collection.name = editedCollectionName
//                    if let updatedName = collection.name {
//                        DispatchQueue.main.async {
//                            collection.name = updatedName
//                        }
//                    }
                    isEditingName = false
                    if viewModel.errorMessage != nil {
                        print("uh oh")
                    }
                }
            }
        }
    }
}

#Preview {
    CollectionDetailView(collection: .constant(Collection(id: "1", name: "Temp", userId: "1", businesses: businessCollections)), viewModel: CollectionDetailViewModel())
}
