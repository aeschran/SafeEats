//
//  MyProfileView.swift
//  SafeEats
//
//  Created by harshini on 2/22/25.
//

import SwiftUI

struct MyProfileView: View {
    @StateObject private var viewModel = MyProfileViewModel()
    @State private var selectedTab: String = "Reviews"
    @State var showNewCollectionPopup = false
    @State var newCollectionName = ""
    @State var displayError: Bool = false
    
    func saveCollectionsToUserDefaults(_ collections: [Collection]) {
        if let data = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(data, forKey: "collections")
        }
    }

    func loadCollectionsFromUserDefaults() -> [Collection] {
        if let data = UserDefaults.standard.data(forKey: "collections"),
           let collections = try? JSONDecoder().decode([Collection].self, from: data) {
            return collections
        }
        return []
    }
    
    func loadProfileData() async {
        print("hello!")
        await viewModel.fetchUserProfile()
        await viewModel.getUserCollections()
        saveCollectionsToUserDefaults(viewModel.collections)
    }
    
    func collectionButton(for collection: Collection) -> some View {
        Group {
            if let index = viewModel.collections.firstIndex(where: { $0.id == collection.id }) {
                NavigationLink(destination: CollectionDetailView(collection: $viewModel.collections[index], viewModel: CollectionDetailViewModel())) {
                    Text(collection.name)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .frame(width: 380, height: 68)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack{
                    HStack{
                        if let profileImage = viewModel.imageBase64 {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                        } else {
                            Image("blank-profile")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        HStack(spacing: 32) {
                            VStack(spacing: 2){
                                
                                Text("\(viewModel.reviewCount)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Reviews")
                                    .font(.caption)
                            }
                            VStack(spacing: 2){
                                NavigationLink(destination: FriendListView()) {
                                    Text("\(viewModel.friendCount)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    //                                        .underline()
                                }
                                //                                Text("\(viewModel.friendCount)")
                                //                                    .font(.subheadline)
                                //                                    .fontWeight(.semibold)
                                Text("Friends")
                                    .font(.caption)
                            }
                            .navigationBarTitleDisplayMode(.inline)
                            .tint(.black)
                        }.padding(.horizontal, 30)
                        Spacer()
                    }.padding(5)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.name)
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Text(viewModel.bio)
                            .font(.caption)
                        
                    }.padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    
                    HStack{
                        Button(action: {
                            
                        }) {
                            Text("Edit Profile")
                                .foregroundColor(.black)
                                .padding()
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .frame(width:380, height: 34)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(.systemGray4))
                                )
                        }
                        
                    }
                    HStack {
                        Button(action: {
                            selectedTab = "Reviews"
                        }) {
                            Text("Reviews")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .frame(width: 190, height: 34)
                                .background(selectedTab == "Reviews" ? Color.mainGreen : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(.systemGray4))
                                )
                        }

                        Button(action: {
                            selectedTab = "Collections"
                        }) {
                            Text("Collections")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .frame(width: 190, height: 34)
                                .background(selectedTab == "Collections" ? Color.mainGreen : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(.systemGray4))
                                )
                        }
                    }
                    if selectedTab == "Collections" {
                        collectionsView
                    }
                }
                .padding(6)
                .navigationTitle(viewModel.username) // Centered title
                .navigationBarTitleDisplayMode(.inline) // Ensures it's in the center
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView().environmentObject(SettingsViewModel())) {
                            Image(systemName: "line.3.horizontal") // Settings icon
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                }
                .task {
//                    viewModel.collections = loadCollectionsFromUserDefaults()
                    await loadProfileData()
                }
            }
        }
        .tint(.black)
    }
    
    var collectionsView: some View {
        VStack {
            Divider() // Horizontal line added here
            if viewModel.collections.isEmpty {
                Text("You have no collections created.")
            }
            ForEach(viewModel.collections, id: \.id) { collection in
                collectionButton(for: collection)
            }
            Divider()
            Button(action: {
                showNewCollectionPopup = true
            }) {
                Text("Create New Collection")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .frame(width: 190, height: 40) // Match width with the tabs above
                    .background(Color.mainGreen.opacity(1))
                    .cornerRadius(4)
            }
            .alert("New Collection", isPresented: $showNewCollectionPopup) {
                TextField("Enter collection name", text: $viewModel.collectionName)
                Button("Cancel", role: .cancel) {
                    showNewCollectionPopup = false
                    newCollectionName = ""
                }
                Button("Create") {
                    Task {
                        viewModel.errorMessage = nil
                        var message = await viewModel.createNewCollection()
                        if let error = viewModel.errorMessage, !error.isEmpty {
                            displayError = true
                        } else {
                            await viewModel.getUserCollections()
                        }
                    }
                    newCollectionName = ""
                    showNewCollectionPopup = false
                    if viewModel.errorMessage != nil {
                        print("uh oh")
                    }
                }
            }
            .alert("Error", isPresented: $displayError) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onChange(of: viewModel.collections.count) { _, _ in
            viewModel.objectWillChange.send()
        }
    }
}



#Preview {
    MyProfileView()
}
