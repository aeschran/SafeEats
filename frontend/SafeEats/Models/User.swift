//
//  User.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/23/25.
//
import Foundation

struct User : Codable, Identifiable {
    let id : String
    let name: String?
    let email: String
    let phone: String
    let username: String
    let isVerified: Bool?
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case email
        case phone
        case username
        case isVerified
        
    }
}
