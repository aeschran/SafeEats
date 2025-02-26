//
//  FriendsViewModel.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/22/25.
//

import SwiftUI

@Observable
class FriendsViewModel {
    var requests: [NotificationResponse] = []
    
    init() {
        fetchRequests()
    }
    
    func fetchRequests() {
        guard let url = URL(string: "http://localhost:8000/notifications/67be93f783402626a81f76da") else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedRequests = try JSONDecoder().decode([NotificationResponse].self, from: data)
                var friendRequests: [NotificationResponse] = []
                for request in decodedRequests {
                    if request.type == 1 {
                        friendRequests.append(request)
                    }
                }
                
                await MainActor.run {
                    self.requests = friendRequests
                }
            } catch {
                print("Failed to fetch friend requests: \(error)")
            }
        }
    }
    
    func acceptRequest(_ request: NotificationResponse) {
        guard let url = URL(string: "http://localhost:8000/friends/accept") else { return }
        
        Task {
            do {
                var requestObj = URLRequest(url: url)
                requestObj.httpMethod = "POST"
                requestObj.setValue("application/json", forHTTPHeaderField: "Content-Type")
                requestObj.httpBody = try JSONEncoder().encode(["user_id": request.recipient_id, "friend_id": request.sender_id])
                
                let (_, response) = try await URLSession.shared.data(for: requestObj)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    await MainActor.run {
                        self.requests.removeAll { $0.recipient_id == request.recipient_id }
                    }
                }
            } catch {
                print("Failed to accept request: \(error)")
            }
        }
    }
    
    func denyRequest(_ request: NotificationResponse) {
        guard let url = URL(string: "http://localhost:8000/friends/deny") else { return }
        
        Task {
            do {
                var requestObj = URLRequest(url: url)
                requestObj.httpMethod = "POST"
                
                let (_, response) = try await URLSession.shared.data(for: requestObj)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    await MainActor.run {
                        self.requests.removeAll { $0.recipient_id == request.recipient_id }
                    }
                }
            } catch {
                print("Failed to deny request: \(error)")
            }
        }
    }
}
