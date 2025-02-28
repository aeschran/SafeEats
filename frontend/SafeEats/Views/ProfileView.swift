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
    @State private var showUnfollowAlert: Bool = false
    
    var body: some View {
        NavigationStack{
            
            
            ScrollView{
                VStack{
                    HStack{
                        Image(systemName: "chevron.left").font(.title2)
                        Spacer()
                        
                        Text(viewModel.username).font(.subheadline).fontWeight(.semibold)
                        Spacer()
                        
                        
                    }.padding(2)
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
                        Text(viewModel.name)
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Text(viewModel.bio)
                            .font(.caption)
                        
                    }.padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    
                    HStack{
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
                                        Task {
                                            await viewModel.unfollowFriend()
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                            
                        } else {
                            Button(action: {
                                didTap = true
                                Task {
                                    await viewModel.sendFriendRequest()
                                }
                                
                            }) {
                                Text(didTap ? "Requested" : "Follow")
                                    .foregroundColor(didTap ? Color.black : Color.black)
                                    .padding()
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .frame(width:400, height: 34)
                                    .background(didTap ? Color.mainGray : Color.mainGreen)
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
            }
            .onAppear {
                // Fetch the data after the view appears
                viewModel.fetchData()
            }
        }
    }
}


#Preview {
    ProfileView(friendId: "67ad36ed4f59c3ecd1434482")
}
