//
//  Business.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/26/25.
//
import Foundation

class PreferenceResponse: Decodable {
    let preference: String
    let preference_type: String
}

class Business: Decodable, Identifiable {
    let id = UUID()
    let name: String?
    let website: String?
    let description: String?
    let cuisines: [String]?
    let menu: String?
    let address: String?
    let dietary_restrictions: [PreferenceResponse]?
}
