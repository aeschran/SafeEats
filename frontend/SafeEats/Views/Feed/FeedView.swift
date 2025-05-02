//
//  FeedView.swift
//  SafeEats
//
//  Created by harshini on 2/25/25.
//

import SwiftUI

struct SearchUser: Identifiable, Codable {
    let id: String
    let name: String
    let username: String
}
//import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    @State private var navigateToProfile = false
    @State private var selectedUserId: String?
    @State private var navigateToNotifications = false
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBarView(searchText: $viewModel.searchText, onNotificationsTap: {
                    navigateToNotifications = true
                })
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.searchUsers()
                }
                .padding(.top, 8)
                
                if viewModel.isSearching {
                    ScrollView {
                        VStack {
                            ForEach(viewModel.searchResults) { user in
                                NavigationLink(destination: ProfileView(friendId: user.id)) {
                                    VStack(alignment: .leading) {
                                        Text(user.name)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Text(user.username)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: Color.gray.opacity(0.2), radius: 2, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    FeedContentView(viewModel: viewModel) // Keep `List` for FeedContentView
                        .padding(.top, 10)
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white) // Ensure background stays white
            .navigationDestination(isPresented: $navigateToProfile) {
                if let userId = selectedUserId {
                    ProfileView(friendId: userId)
                }
            }
            NavigationLink(destination: NotificationsView(), isActive: $navigateToNotifications) {
                
            }
        }
        .background(Color.white)
    }
}


#Preview {
    FeedView()
}
