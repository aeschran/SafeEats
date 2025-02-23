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
        guard let url = URL(string: "http://localhost:8000/notifications/67ac266c4a7e2c0dbc97bdaa") else { return }
        
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
        
        // remove when requests is fully implemented
        if requests.isEmpty {
            requests = [
                NotificationResponse(recipient_id: "1", sender: .init(id: "3", name: "Alice"), type: 1, content: "", timestamp: 1234567890.0, profileImageURL: "https://via.placeholder.com/50"),
                NotificationResponse(recipient_id: "2", sender: .init(id: "4", name: "Bob"), type: 1, content: "", timestamp: 1234567891.0, profileImageURL: "https://via.placeholder.com/50"),
            ]
        }
    }
    
    func acceptRequest(_ request: NotificationResponse) {
        guard let url = URL(string: "http://localhost:8000/friend-requests/\(request.sender.id)/accept") else { return }
        
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
                print("Failed to accept request: \(error)")
            }
        }
    }
    
    func denyRequest(_ request: NotificationResponse) {
        guard let url = URL(string: "http://localhost:8000/notifications/\(request.sender.id)/deny") else { return }
        
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
