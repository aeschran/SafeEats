//
//  User.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/23/25.
//
import Foundation

struct User : Codable, Identifiable {
    var id : UUID = UUID()
    let name: String
    let email: String
    let username: String
    let preferences: [Preference] = []
    
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case name
        case email
        case username
        case preferences
        
    }
}

struct Preference: Codable, Identifiable {
    var id: UUID = UUID()
    let preference: String
    let preference_type: String
}
