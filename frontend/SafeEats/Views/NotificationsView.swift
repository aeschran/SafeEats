//
//  NotificationsView.swift
//  SafeEats
//
//  Created by harshini on 2/26/25.
//

import SwiftUI


struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List(viewModel.notifications) { notification in
                VStack(alignment: .leading, spacing: 8) {
                    NavigationLink(destination: ProfileView(friendId: notification.senderId)) {
                        Text("\(notification.senderUsername) wants to be your friend!")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Button("Accept") {
                            print(notification.id)
                            print(notification.recipient_id)
                            print(notification.sender_id)
                            viewModel.acceptRequest(notificationId: notification.id, recipientId: notification.recipient_id, senderId: notification.sender_id)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                        Button("Deny") {
                            print(notification.id)
                            viewModel.denyRequest(notificationId: notification.id, recipientId: notification.recipient_id, senderId: notification.sender_id)
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
        }
    }
}

#Preview {
    NotificationsView()
}
