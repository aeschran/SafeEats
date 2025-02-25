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
                    
//                        HStack {
//
//                                Spacer()
//                                Thbext(viewModel.username)
//                                    .font(.subheadline)
//                                    .fontWeight(.semibold)
//                                    .multilineTextAlignment(.leading)
////                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    Spacer()
//                            
//                            
//                            
//                        }
//                    HStack {
//                        Spacer()
//                            
//
//                                NavigationLink(destination: SettingsView()) {
//                                    Image(systemName: "line.3.horizontal")
//                                        .font(.title2)
//                                    
//                                }
//                                .accentColor(.black)
//                                .padding(.trailing, 2)
//                            
//                        
//                    }
//                    .padding(8)
                    
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
                        
//                        Image("blank-profile")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width:88, height:88)
//                            .clipShape(Circle())
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
                                    NavigationLink(destination: SettingsView()) {
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
    }
}

#Preview {
    MyProfileView()
}
