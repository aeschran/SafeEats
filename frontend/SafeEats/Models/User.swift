//
//  User.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/23/25.
//
import Foundation

struct User : Codable, Identifiable {
    let id : UUID = UUID()
    let name: String
    let email: String
    let username: String
    
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case name
        case email
        case username
        
    }
}
