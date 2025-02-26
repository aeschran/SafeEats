//
//  NotificationsViewModel.swift
//  SafeEats
//
//  Created by harshini on 2/26/25.
//

import Foundation
import SwiftUI




class NotificationsViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @AppStorage("user") var userData : Data?
    
    @Published var senderID: String? = nil
    @Published var navigateToProfile: Bool = false
    
    var user: User? {
            get {
                guard let userData else { return nil }
                return try? JSONDecoder().decode(User.self, from: userData)
            }
            set {
                guard let newValue = newValue else { return }
                if let encodedUser = try? JSONEncoder().encode(newValue) {
                    self.userData = encodedUser
                }
            }
        }

    private let baseURL = "http://127.0.0.1:8000"  // Replace with your actual backend URL

    // Fetch Notifications from the Backend
    func fetchNotifications() {
        guard let user = user else {
                print("Error: User data is not available")
                return
            }
        
        guard let url = URL(string: "\(baseURL)/notifications/\(user.id)") else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let jsonString = String(data: data, encoding: .utf8) {
                                print("Raw JSON Response: \(jsonString)")  // Print the raw response
                            }
                let fetchedNotifications = try JSONDecoder().decode([Notification].self, from: data)
                
                DispatchQueue.main.async {
                    self.notifications = fetchedNotifications.sorted { $0.timestamp > $1.timestamp }
                    print("Fetched notifications: \(self.notifications)") // Check if notifications are being fetched
                                }
            } catch {
                print("Error fetching notifications: \(error)")
            }
        }
    }

    func respondToRequest(notificationId: String, accept: Bool) {
        guard let url = URL(string: "\(baseURL)/notifications/\(notificationId)/response") else { return }
        
        let responseBody: [String: Any] = [
            "accept": accept
        ]
        
        Task {
            do {
                let requestData = try JSONSerialization.data(withJSONObject: responseBody)
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = requestData
                
                let (_, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("\(accept ? "Accepted" : "Denied") friend request successfully.")
                    
                    // Remove the notification after response
                    DispatchQueue.main.async {
                        self.notifications.removeAll { $0.senderId == notificationId }
                    }
                } else {
                    print("Failed to send response: \(response)")
                }
            } catch {
                print("Error responding to request: \(error.localizedDescription)")
            }
        }
    }
}

struct Notification: Identifiable, Codable {
    let notificationId: String
    let recipientId: String
    let senderId: String
    let senderUsername: String
    let type: Int
    let content: String
    let timestamp: Double

    var id: String { notificationId }

    enum CodingKeys: String, CodingKey {
        case notificationId = "notification_id"
        case recipientId = "recipient_id"
        case senderId = "sender_id"
        case senderUsername = "sender_username"
        case type
        case content
        case timestamp
    }
}
