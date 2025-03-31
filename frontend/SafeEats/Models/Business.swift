//
//  Business.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/26/25.
//
import Foundation

class PreferenceResponse: Codable, Hashable {
    
    let preference: String
    let preference_type: String
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(preference) // or any other property that can uniquely identify the object
        }
        
    static func ==(lhs: PreferenceResponse, rhs: PreferenceResponse) -> Bool {
        return lhs.preference == rhs.preference // or compare other properties
    }
    
    init(preference: String, preference_type: String) {
        self.preference = preference
        self.preference_type = preference_type
    }
}

class Business: Decodable, Identifiable {
    let id: String
    let name: String?
    let website: String?
    let description: String?
    let cuisines: [Int]?
    let menu: String?
    let address: String?
    let dietary_restrictions: [PreferenceResponse]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case website
        case description
        case cuisines
        case menu
        case address
        case dietary_restrictions
    }
}
