//
//  Location.swift
//  SafeEats
//
//  Created by Jon Hurley on 4/1/25.
//

import Foundation
import MapKit

struct Location: Decodable {
    let lat: Double
    let lon: Double
}

class BusinessMapLocation: Decodable, Identifiable {
    let id: String
    let location: Location
    let name: String?
    let website: String?
    let description: String?
    let cuisines: [Int]?
    let menu: String?
    let address: String?
    let dietary_restrictions: [PreferenceResponse]?

    init(id: String, location: Location, name: String?, website: String?, description: String?, cuisines: [Int]?, menu: String?, address: String?, dietary_restrictions: [PreferenceResponse]?) {
        self.id = id
        self.location = location
        self.name = name
        self.website = website
        self.description = description
        self.cuisines = cuisines
        self.menu = menu
        self.address = address
        self.dietary_restrictions = dietary_restrictions
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case location
        case name
        case website
        case description
        case menu
        case cuisines
        case address
        case dietary_restrictions = "dietary_preferences"
    }
}

