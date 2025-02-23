//
//  Notification.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/22/25.
//

struct Sender: Codable, Identifiable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
            case id = "_id"  // Map `_id` from JSON to `id` in Swift
            case name
        }
}

struct NotificationResponse: Codable, Identifiable {
    var id: String { "\(sender.id)-\(recipient_id)-\(timestamp)" } // Unique composite key
    let recipient_id: String
    let sender: Sender
    let type: Int
    let content: String?
    let timestamp: Float
    let profileImageURL: String?
}
