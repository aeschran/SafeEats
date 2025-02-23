//
//  NotificationsView.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/22/25.
//

import SwiftUI

struct NotificationsView: View {
    @State private var viewModel = FriendsViewModel()
        
        var body: some View {
            NavigationStack {
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

#Preview {
    NotificationsView()
}
