//
//  MyProfileView.swift
//  SafeEats
//
//  Created by harshini on 2/22/25.
//

import SwiftUI

struct MyProfileView: View {
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack{
                    HStack{
                        Spacer()
                        
                        Text("username").font(.subheadline).fontWeight(.semibold)
                        Spacer()
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                            
                        }
                        .accentColor(.black)
                        .padding(.horizontal, 10)
                        
                    }
                    .padding(2)
                    
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
                }.padding(6)
            }
        }
    }
}

#Preview {
    MyProfileView()
}
