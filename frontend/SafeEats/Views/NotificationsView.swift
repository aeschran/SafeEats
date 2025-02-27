//
//  NotificationsView.swift
//  SafeEats
//
//  Created by harshini on 2/26/25.
//

import SwiftUI


struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.notifications) { notification in
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        // set navigateToProfile and senderID here
                        viewModel.navigateToProfile = true
                        viewModel.senderID = notification.senderId
                    }) {
                        Text("\(notification.senderUsername) wants to be your friend")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Button("Accept") {
                            print(notification.id)
                            viewModel.respondToRequest(notificationId: notification.id, accept: true)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                        Button("Deny") {
                            print(notification.id)
                            viewModel.respondToRequest(notificationId: notification.id, accept: false)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Notifications")
            .onAppear {
                viewModel.fetchNotifications()
            }
            .navigationDestination(isPresented: $viewModel.navigateToProfile) {
                ProfileView(friendId: viewModel.senderID ?? "")
            }
        }
    }
}

#Preview {
    NotificationsView()
}
