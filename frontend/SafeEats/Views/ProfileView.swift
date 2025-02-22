//
//  ProfileView.swift
//  SafeEats
//
//  Created by harshini on 2/22/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var didTap: Bool = false
    @State private var isFollowing: Bool = false
    var body: some View {
        ScrollView{
            VStack{
                HStack{
                    Image(systemName: "chevron.left").font(.title2)
                    Spacer()
                    
                    Text("username").font(.subheadline).fontWeight(.semibold)
                    Spacer()
                    
                    
                }.padding(2)
                HStack{
                    Image("blank-profile")
                        .resizable()
                        .scaledToFill()
                        .frame(width:88, height:88)
                        .clipShape(Circle())
                    Spacer()
                    HStack(spacing: 32) {
                        VStack(spacing: 2){
                            Text("5")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Reviews")
                                .font(.caption)
                        }
                        VStack(spacing: 2){
                            Text("10")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Friends")
                                .font(.caption)
                        }
                    }.padding(.horizontal, 30)
                    Spacer()
                }.padding(5)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("First Last")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    Text("Hi! This is my bio")
                        .font(.caption)
                    
                }.padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            
                HStack{
                    if isFollowing {
                        Text("Following")
                            .foregroundColor(.black)
                            .padding()
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .frame(width:400, height: 34)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(.systemGray4))
                            )
                        
                    } else {
                        Button(action: {
                            didTap.toggle()
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
    }
}

#Preview {
    ProfileView()
}
