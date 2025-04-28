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
    var cuisines: [Int] = []
    let menu: String?
    let address: String?
    let dietary_restrictions: [PreferenceResponse]?
    var avg_rating: Double = 0.0
    let tel: String?
    let social_media: SocialMedia?
    let price: Int?
    let hours: BusinessHours?

    init(id: String, location: Location, name: String?, website: String?, description: String?, cuisines: [Int], menu: String?, address: String?, dietary_restrictions: [PreferenceResponse]?, avg_rating: Double, tel: String?, social_media: SocialMedia?, price: Int?, hours: BusinessHours?) {
        self.id = id
        self.location = location
        self.name = name
        self.website = website
        self.description = description
        self.cuisines = cuisines
        self.menu = menu
        self.address = address
        self.dietary_restrictions = dietary_restrictions
        self.avg_rating = avg_rating
        self.tel = tel
        self.social_media = social_media
        self.price = price
        self.hours = hours
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
        case dietary_restrictions
        case avg_rating
        case tel
        case social_media
        case price
        case hours
    }
}

