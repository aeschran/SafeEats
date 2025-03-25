//
//  Business.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/26/25.
//
import Foundation

class PreferenceResponse: Codable {
    let preference: String
    let preference_type: String
    
    init(preference: String, preference_type: String) {
        self.preference = preference
        self.preference_type = preference_type
    }
}

class Business: Decodable, Identifiable {
    let id = UUID()
    let name: String?
    let website: String?
    let description: String?
    let cuisines: [Int]?
    let menu: String?
    let address: String?
    let dietary_restrictions: [PreferenceResponse]?
}
