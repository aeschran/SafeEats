//
//  BusinessNotificationView.swift
//  SafeEats
//
//  Created by Ava Schrandt on 4/22/25.
//
import SwiftUI

import SwiftUI

struct AllBusinessNotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    let businesses: [(id: String, name: String)]  // This comes from logged-in owner's business list
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(businesses, id: \.id) { business in
                    if let notifs = viewModel.businessGroupedNotifications[business.id], !notifs.isEmpty {
                        NavigationLink(destination: BusinessNotificationDetailView(businessName: business.name, notifications: notifs)) {
                            HStack(spacing: 16) {
                                Image(systemName: "bell.circle.fill")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(Color.mainGreen)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(business.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text("\(notifs.count) new notification\(notifs.count > 1 ? "s" : "")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text("\(notifs.count)")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(Color.mainGreen)
                                    .frame(alignment: .trailing)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchNotificationsForBusinesses(businesses)
        }
        .navigationTitle("Business Notifications")
    }
}


struct BusinessNotificationDetailView: View {
    let businessName: String
    @State var notifications: [Notification]
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if notifications.isEmpty {
                    VStack {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                        Text("No notifications remaining.")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                } else {
                    ForEach(notifications) { notif in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: iconForType(notif.type))
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color.mainGreen)
                                Text(titleForType(notif.type))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(notif.content)
                                .font(.body)
                            
                            Text(Date(timeIntervalSince1970: notif.timestamp), style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                           HStack(spacing: 12) {
                                Button(action: {
                                    viewModel.deleteNotification(notificationId: notif.id)
                                    notifications.removeAll { $0.id == notif.id }
                                }) {
                                    Text("Dismiss")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }

                                if notif.type == 2 {
                                    NavigationLink(destination: SuggestionDetailView(notification: notif)) {
                                        Text("View Details")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.mainGreen.opacity(0.15))
                                            .foregroundColor(.mainGreen)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(businessName)
    }

    func iconForType(_ type: Int) -> String {
        switch type {
        case 2: return "lightbulb.max.fill"
        case 3: return "star.bubble"
        default: return "bell"
        }
    }

    func titleForType(_ type: Int) -> String {
        switch type {
        case 2: return "Business Suggestion"
        case 3: return "New Review"
        default: return "Notification"
        }
    }
}

struct SuggestionDetailView: View {
    let notification: Notification

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggestion Detail")
                .font(.title2)
                .bold()
            Text(notification.content)
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationTitle("Suggestion")
    }
}

