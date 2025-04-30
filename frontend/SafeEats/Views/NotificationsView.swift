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
            List {
                ForEach(viewModel.notifications) { notification in
                    //                    ZStack {
                    //                                    RoundedRectangle(cornerRadius: 12)
                    //                                        .fill(Color.gray.opacity(0.1))
                        VStack(alignment: .leading, spacing: 8) {
                            if notification.type == 1 {
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
                                .padding(.bottom, 12)
                            } else if notification.type == 4 {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your report has been submitted!")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Text("You reported \(notification.senderUsername) on \(formattedDate(from: notification.timestamp)) for \(notification.content)")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                
                                .padding(.bottom, 12)
                            }
                            
                        }
                        .padding()
                        .listRowInsets(EdgeInsets())
                        .cornerRadius(12)
                        .listRowSeparator(.hidden) // Hide the default line separator
                        .listRowInsets(EdgeInsets()) // Remove default padding
                        .padding(.horizontal) // Add custom padding to simulate spacing
                        .background(Color.clear)
                        //                .background(Color.gray.opacity(0.1))
                        //                                    .cornerRadius(12)
                        //                                    .padding(.horizontal)
                        .overlay(
                            Divider()
                                .padding(.horizontal),
                            alignment: .bottom
                            )
                }
            }
            .navigationTitle("Notifications")
            .onAppear {
                viewModel.fetchNotifications()
            }
        }
    }
    private func formattedDate(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



#Preview {
    NotificationsView()
}
