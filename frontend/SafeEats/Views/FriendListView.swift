//
//  FriendListView.swift
//  SafeEats
//
//  Created by harshini on 2/25/25.
//

import SwiftUI

struct Friend: Identifiable {
    let id: String  // String ID from the backend
    let name: String
    let username: String
    let friendSince: String
}
    
struct FriendRow: View {
    let friend: Friend

    var body: some View {
        VStack(alignment: .leading) {
            Text(friend.name)
                .font(.headline)
            Text(friend.username)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Friend since: \(friend.friendSince)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct FriendListView: View {
    @StateObject private var viewModel = FriendListViewModel()
//    let friends: [Friend] = [
//        Friend(id: "123", name: "John Doe", username: "@johndoe", friendSince: "January 2021"),
//        Friend(id: "456", name: "Jane Smith", username: "@janesmith", friendSince: "March 2020"),
//        Friend(id: "789", name: "Alex Brown", username: "@alexbrown", friendSince: "July 2019")
//    ]
    
    var body: some View {
        NavigationStack {
            List(viewModel.friends) { friend in
                NavigationLink(destination: ProfileView(friendId: friend.id)) {
                    FriendRow(friend: friend)
                }
            }

                .navigationTitle("Friends")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewModel.fetchFriends()  // Fetch the data when the view appears
                }
        }
        .tint(.black)
    }

}

#Preview {
    FriendListView()
}
