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
    var location: Location
    var name: String
    var cuisines: [Int]?
    var address: String?
    var dietary_restrictions: [PreferenceResponse]?
    
    init(id: String, location: Location, name: String, cuisines: [Int]? = nil, address: String? = nil, dietary_restrictions: [PreferenceResponse]? = nil) {
        self.id = id
        self.location = location
        self.name = name
        self.cuisines = cuisines
        self.address = address
        self.dietary_restrictions = dietary_restrictions
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case location
        case name
        case cuisines
        case address
        case dietary_restrictions = "dietary_preferences"
    }
}

