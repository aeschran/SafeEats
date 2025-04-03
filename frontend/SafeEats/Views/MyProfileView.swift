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
                    } else if selectedTab == "Reviews"{
                        ProfileReviewView(viewModel: FeedViewModel())
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

struct ProfileReviewView: View {
    @ObservedObject var viewModel: FeedViewModel
    @ObservedObject var reviewViewModel: CreateReviewViewModel = CreateReviewViewModel()
    @State private var showDeleteConfirmation = false
    @State private var reviewToDelete: FriendReview? = nil
    
    @State private var showEditSheet = false
    @State private var reviewToEdit: FriendReview? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.reviews, id: \.reviewId) { review in
                    ProfileReviewCard(review: review, onEdit: { editReview(review) },
                                      onDelete: { deleteReview(review) })
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            viewModel.fetchMyReviews()
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("You are about to delete this review."),
                primaryButton: .destructive(Text("Delete")) {
                    confirmDeleteReview()
                },
                secondaryButton: .cancel()
            )
        }
        
        .sheet(isPresented: $showEditSheet) {
            if let review = reviewToEdit {
                EditReviewView(review: review, onSave: { updatedReview in
                    // Handle save logic here (e.g., update the review)
                    print("Updated Review: \(updatedReview)")
                    showEditSheet = false
                })
            }
        }
    }
    private func editReview(_ review: FriendReview) {
        reviewToEdit = review
        showEditSheet = true
    }
    private func deleteReview(_ review: FriendReview) {
        reviewToDelete = review
        showDeleteConfirmation = true
    }

    private func confirmDeleteReview() {
        if let review = reviewToDelete {
            reviewViewModel.deleteReview(reviewID: review.reviewId) { success in
                if success {
                    print("Review deleted successfully")
                } else {
                    print("Failed to delete review")
                }
            }
        }
        showDeleteConfirmation = false
    }
    
}

import SwiftUI

struct ProfileReviewCard: View {
    let review: FriendReview
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(review.businessName)
                        .font(.headline)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .truncationMode(.tail) // Ensure it doesn't wrap too soon
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(review.reviewContent)
                        .font(.body)
                    
                    HStack {
                        ForEach(0..<review.rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text("Reviewed on \(formattedDate(review.reviewTimestamp))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }.padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
            .frame(maxWidth: .infinity)

            // Overlay with edit and delete buttons
            HStack(spacing: 10) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.mainGreen)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                }
            }
            .padding()
        }
    }

    private func formattedDate(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct EditReviewView: View {
    @State private var editedContent: String
    @State private var mutableReview: FriendReview
    
    var onSave: (FriendReview) -> Void

    init(review: FriendReview, onSave: @escaping (FriendReview) -> Void) {
        self._mutableReview = State(initialValue: review) // Using a mutable copy of review
        self._editedContent = State(initialValue: review.reviewContent)
        self.onSave = onSave
    }

    var body: some View {
        VStack {
            Text("Edit Review")
                .font(.headline)
                .padding()

            TextField("Review Content", text: $editedContent)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

        }
        .padding()
    }
}



#Preview {
    MyProfileView()
}
