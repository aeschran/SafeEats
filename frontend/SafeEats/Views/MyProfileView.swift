//
//  MyProfileView.swift
//  SafeEats
//
//  Created by harshini on 2/22/25.
//

import SwiftUI

struct MyProfileView: View {
    @StateObject private var viewModel = MyProfileViewModel()
    
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
                        Text("Reviews")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .frame(width:190, height: 34)
                            .background(Color.mainGreen)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(.systemGray4))
                            )
                        Text("Collections")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .frame(width:190, height: 34)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(.systemGray4))
                            )
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
                    await viewModel.fetchUserProfile() // Fetch data when view appears
                }
            }
        }
        .tint(.black)
    }
}

#Preview {
    MyProfileView()
}
