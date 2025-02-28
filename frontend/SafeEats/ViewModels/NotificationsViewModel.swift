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
    @Published var notificationId: String = ""
    @Published var navigateToProfile: Bool = false
    @Published var senderID: String? = nil
    @AppStorage("id") var id_:String?

    private let baseURL = "http://127.0.0.1:8000"  // Replace with your actual backend URL

    // Fetch Notifications from the Backend
    func fetchNotifications() {
        guard let id = id_ else {
                print("Error: User data is not available")
                return
            }
        guard let url = URL(string: "\(baseURL)/notifications/\(id)") else { return }

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

    func acceptRequest(notificationId: String, recipientId: String, senderId: String) {
        guard let url = URL(string: "http://localhost:8000/friends/accept") else { return }
        
        Task {
            do {
                var requestObj = URLRequest(url: url)
                requestObj.httpMethod = "POST"
                requestObj.setValue("application/json", forHTTPHeaderField: "Content-Type")
                requestObj.httpBody = try JSONEncoder().encode(["notification_id": notificationId, "user_id": recipientId, "friend_id": senderId])
                
                let (_, response) = try await URLSession.shared.data(for: requestObj)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                    await MainActor.run {
//                        print("Before removal: \(self.notifications.map { $0.id })")
//                        self.notifications.removeAll { $0.id == notificationId }
//                        print("After removal: \(self.notifications.map { $0.id })")
//                    }
                    DispatchQueue.main.async {
                        print("Before removal: \(self.notifications.map { $0.id })")
                        self.notifications.removeAll { $0.id == notificationId }
                        print("After removal: \(self.notifications.map { $0.id })")
                    }
                }
            } catch {
                print("Failed to accept request: \(error)")
            }
        }
    }
    
    func denyRequest(notificationId: String, recipientId: String, senderId: String) {
        guard let url = URL(string: "http://localhost:8000/friends/deny") else { return }
        
        Task {
            do {
                var requestObj = URLRequest(url: url)
                requestObj.httpMethod = "POST"
                requestObj.setValue("application/json", forHTTPHeaderField: "Content-Type")
                requestObj.httpBody = try JSONEncoder().encode(["notification_id": notificationId, "user_id": recipientId, "friend_id": senderId])
                
                let (_, response) = try await URLSession.shared.data(for: requestObj)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        print("Before removal: \(self.notifications.map { $0.id })")
                        self.notifications.removeAll { $0.id == notificationId }
                        print("After removal: \(self.notifications.map { $0.id })")
                        //                        self.notifications.removeAll { $0.senderId == notificationId }
                        //                    }
                        //                    await MainActor.run {
                        ////                        self.notifications = self.notifications.filter { $0.id != notificationId }
                        //
                        //                    }
                    }
                }
            } catch {
                print("Failed to deny request: \(error)")
            }
        }
    }
    
//    func respondToRequest(notificationId: String, accept: Bool) {
//        guard let url = URL(string: "\(baseURL)/notifications/\(notificationId)/response") else { return }
//        
//        let responseBody: [String: Any] = [
//            "accept": accept
//        ]
//        
//        Task {
//            do {
//                let requestData = try JSONSerialization.data(withJSONObject: responseBody)
//                var request = URLRequest(url: url)
//                request.httpMethod = "POST"
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.httpBody = requestData
//                
//                let (_, response) = try await URLSession.shared.data(for: request)
//                
//                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                    print("\(accept ? "Accepted" : "Denied") friend request successfully.")
//                    
//                    // Remove the notification after response
//                    DispatchQueue.main.async {
//                        self.notifications.removeAll { $0.senderId == notificationId }
//                    }
//                } else {
//                    print("Failed to send response: \(response)")
//                }
//            } catch {
//                print("Error responding to request: \(error.localizedDescription)")
//            }
//        }
//    }
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
    var sender_id: String { senderId }
    var recipient_id: String { recipientId }

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
