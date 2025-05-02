//
//  ProfileView.swift
//  SafeEats
//
//  Created by harshini on 2/22/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    let friendId: String
    
    // Accept the friendId
    init(friendId: String) {
        self.friendId = friendId
        _viewModel = StateObject(wrappedValue: ProfileViewModel(friendId: friendId))
    }
    //    friend.id
    @State private var id: String = ""
    @State private var name: String = ""
    @State private var username: String = "Loading..."
    @State private var didTap: Bool = false
    @State private var isFollowing: Bool = false
    @State private var isRequested: Bool = false
    @State private var showUnfollowAlert: Bool = false
    //    print(viewModel.isFollowing)
    //    print(viewModel.isRequested)
    @State private var navigateToReport = false
    
    var body: some View {
        NavigationStack{
            
            
            ScrollView{
                VStack{
                    //                    HStack{
                    //                        Image(systemName: "chevron.left").font(.title2)
                    //                        Spacer()
                    //
                    //                        Text(viewModel.username).font(.subheadline).fontWeight(.semibold)
                    //                        Spacer()
                    //
                    //
                    //                    }.padding(2)
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
                                Text("\(viewModel.friendCount)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Friends")
                                    .font(.caption)
                            }
                        }.padding(.horizontal, 30)
                        Spacer()
                    }.padding(5)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(viewModel.name)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            if viewModel.isTrusted {
                                Text(" Trusted Reviewer")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .italic(true)
                                    .foregroundColor(.mainGreen)
                            }
                        }
                        
                        Text(viewModel.bio)
                            .font(.caption)
                        
                    }.padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    
                    HStack {
                        if viewModel.isFollowing {
                            Button(action: {
                                showUnfollowAlert = true
                            }) {
                                Text("Following")
                                    .foregroundColor(.black)
                                    .padding()
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .frame(width: 400, height: 34)
                                    .background(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(.systemGray4)))
                            }
                            .alert(isPresented: $showUnfollowAlert) {
                                Alert(
                                    title: Text("Unfollow"),
                                    message: Text("Are you sure you want to unfollow?"),
                                    primaryButton: .destructive(Text("Yes")) {
                                        Task { await viewModel.unfollowFriend() }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }

                        } else if viewModel.isRequested || didTap {
                            // Disabled "Requested" state
                            Text("Requested")
                                .foregroundColor(.black)
                                .padding()
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .frame(width: 400, height: 34)
                                .background(Color.mainGray)
                                .cornerRadius(6)

                        } else {
                            Button(action: {
                                didTap = true
                                Task { await viewModel.sendFriendRequest() }
                            }) {
                                Text("Follow")
                                    .foregroundColor(.black)
                                    .padding()
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .frame(width: 400, height: 34)
                                    .background(Color.mainGreen)
                                    .cornerRadius(6)
                            }
                        }
                    }

                    HStack {
                        Text("Reviews")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .frame(width:400, height: 34)
                            .padding(.top, 10)
                        /*.padding(.bottom, 5)*/ // Add padding above the border
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.5) // Border thickness
                                    .foregroundColor(.black), // Border color
                                alignment: .bottom
                                
                            )
                       
                        
                    }
                }.padding(6)
                OtherProfileReviewView(friendId: friendId)
            }
            .onAppear {
                // Fetch the data after the view appears
                viewModel.fetchData()
            }
            .navigationTitle(viewModel.username) // Centered title
            .navigationBarTitleDisplayMode(.inline) // Ensures it's in the center
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        Button(action: {
                            navigateToReport = true
                        }) {
                            Image(systemName: "exclamationmark.bubble")
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                        }
                        NavigationLink(
                            destination: ReportUserView(friendId: friendId, username: viewModel.username),
                            isActive: $navigateToReport
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    }
                }
            }
        }
    }
}

struct OtherProfileReviewView: View {
    @StateObject var viewModel: ProfileViewModel
    let friendId: String
    
    // Accept the friendId
    init(friendId: String) {
        self.friendId = friendId
        _viewModel = StateObject(wrappedValue: ProfileViewModel(friendId: friendId))
    }
    
    @State private var showDeleteConfirmation = false
    @State private var reviewToDelete: FriendReview? = nil
    
    @State private var showEditSheet = false
    @State private var reviewToEdit: FriendReview? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.reviews, id: \.reviewId) { review in
                    OtherProfileReviewCard(review: review)
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            viewModel.fetchUserReviews(friendId: friendId)
        }
//        .alert(isPresented: $showDeleteConfirmation) {
//            Alert(
//                title: Text("Are you sure?"),
//                message: Text("You are about to delete this review."),
//                primaryButton: .destructive(Text("Delete")) {
//                    confirmDeleteReview()
//                },
//                secondaryButton: .cancel()
//            )
//        }
//        
//        .sheet(isPresented: $showEditSheet) {
//            if let review = reviewToEdit {
//                
//                EditReviewView(viewModel: viewModel, businessId: review.businessId, review: review)
//            } else {
//               Text("INVALID")
//            }
//        }
    }
//    private func editReview(_ review: FriendReview) {
//        DispatchQueue.main.async {
//            reviewToEdit = review
//            
//        }
//        showEditSheet = true
//    }
//    private func deleteReview(_ review: FriendReview) {
//        reviewToDelete = review
//        showDeleteConfirmation = true
//    }

//    private func confirmDeleteReview() {
//        if let review = reviewToDelete {
//            reviewViewModel.deleteReview(reviewID: review.reviewId, businessID: review.businessId) { success in
//                if success {
//                    print("Review deleted successfully")
//                    viewModel.fetchMyReviews()
//                } else {
//                    print("Failed to delete review")
//                }
//            }
//        }
//        showDeleteConfirmation = false
//    }
    
}


struct OtherProfileReviewCard: View {
    let review: FriendReview
//    var onEdit: () -> Void
//    var onDelete: () -> Void

    var body: some View {
        NavigationLink(destination: DetailedReviewView(reviewId: review.id)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Title: "{user} reviewed {business}"
                    HStack(spacing: 0) {
                        Text("\(review.userName) reviewed ")
//                            .font(.footnote)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                        Text(review.businessName)
                            //.font(.footnote)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.tail) // Ensure it doesn't wrap too soon
                        /*.frame(maxWidth: .infinity, alignment: .leading)*/ // Extend as much as possible
                            .frame(maxWidth: 200, alignment: .leading)
                            .fontWeight(.semibold)
                    }
                    
                    // Star Rating
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < review.rating ? "star.fill" : "star")
                                .foregroundColor(index < review.rating ? .yellow : .gray)
                        }
                    }
                    
                    // Review Content (Highlighted in black)
                    Text(review.reviewContent)
                        .font(.system(size: 16, weight: .regular, design: .default))
//                        .font(.footnote)
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    // Timestamp
                    Text("reviewed on \(formattedDate(from: review.reviewTimestamp))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 2)
        }
        .buttonStyle(PlainButtonStyle())
        
//        ZStack(alignment: .topTrailing) {
//            HStack {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(review.businessName)
//                        .font(.headline)
//                        .foregroundColor(.black)
//                        .lineLimit(1)
//                        .truncationMode(.tail) // Ensure it doesn't wrap too soon
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    Text(review.reviewContent)
//                        .font(.body)
//                    
//                    HStack {
//                        ForEach(0..<review.rating, id: \.self) { _ in
//                            Image(systemName: "star.fill")
//                                .foregroundColor(.yellow)
//                        }
//                    }
//                    
//                    Text("reviewed on \(formattedDate(from: review.reviewTimestamp))")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                .padding()
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }.padding()
//            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
//            .frame(maxWidth: .infinity)
//
//            // Overlay with edit and delete buttons
////            HStack(spacing: 10) {
////                Button(action: onEdit) {
////                    Image(systemName: "pencil")
////                        .foregroundColor(.mainGreen)
////                        .padding(8)
////                        .background(Color.white)
////                        .clipShape(Circle())
////                        .shadow(radius: 1)
////                }
////
////                Button(action: onDelete) {
////                    Image(systemName: "trash")
////                        .foregroundColor(.red)
////                        .padding(8)
////                        .background(Color.white)
////                        .clipShape(Circle())
////                        .shadow(radius: 1)
////                }
////            }
//            .padding()
//        }
    }

    private func formattedDate(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


#Preview {
    ProfileView(friendId: "67ad36ed4f59c3ecd1434482")
}
