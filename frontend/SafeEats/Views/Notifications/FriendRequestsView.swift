//
//  FriendRequestsView.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/22/25.
//

import SwiftUI

struct FriendRequestsView: View {
    @State private var viewModel = FriendsViewModel()
    
    var body: some View {
        NavigationStack {
            if viewModel.requests.isEmpty {
                VStack {
                    Text("No friend requests.")
                    Text("Wait for someone to add you as a friend!")
                    Image(systemName: "person.crop.circle.fill").resizable().frame(width: 100, height: 100)
                }
                .navigationTitle("Friend Requests")
            } else {
                List {
                    ForEach(viewModel.requests) { request in
                        FriendRequestView(
                            request: request,
                            onAccept: { viewModel.acceptRequest(request) },
                            onDeny: { viewModel.denyRequest(request) }
                        )
                    }
                }
                .navigationTitle("Friend Requests")
            }
        }
    }
}

#Preview {
    FriendRequestsView()
}
