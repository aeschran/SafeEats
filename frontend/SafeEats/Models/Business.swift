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

struct SocialMedia: Codable {
    var facebook_id: String?
    var instagram: String?
    var twitter: String?
}

struct BusinessHours: Codable {
    var display: String?          // e.g., "Mon-Sun 10:00AM-9:00PM"
    var is_local_holiday: Bool?
    var open_now: Bool?
    var regular: [BusinessRegularHours]?
}

struct BusinessRegularHours: Codable {
    var close: String?  // e.g., "21:00"
    var day: Int?       // 0 = Sunday, 1 = Monday, etc.
    var open: String?   // e.g., "10:00"
}

class Business: Decodable, Identifiable {
    let id: String
    let name: String?
    let website: String?
    let tel: String?
    let description: String?
    let cuisines: [Int]?
    let menu: String?
    let address: String?
    let dietary_restrictions: [PreferenceResponse]?
    var avg_rating: Double = 0.0
    let social_media: SocialMedia?
    let price: Int?
    let hours: BusinessHours?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case website
        case tel
        case description
        case cuisines
        case menu
        case address
        case dietary_restrictions
        case avg_rating
        case social_media
        case price
        case hours
    }
    
    init(id: String, name: String?, website: String?, description: String?, cuisines: [Int]?, menu: String?, address: String?, dietary_restrictions: [PreferenceResponse]?, tel: String?, avg_rating: Double, social_media: SocialMedia?, price: Int?, hours: BusinessHours?) {
        self.id = id
        self.name = name
        self.website = website
        self.description = description
        self.cuisines = cuisines
        self.menu = menu
        self.address = address
        self.dietary_restrictions = dietary_restrictions
        self.tel = tel
        self.avg_rating = avg_rating
        self.social_media = social_media
        self.price = price
        self.hours = hours
    }
}
    
    enum PreferenceCategories: String, CaseIterable {
        case dairy = "Dairy"
        case halal = "Halal"
        case kosher = "Kosher"
        case vegan = "Vegan"
        case vegetarian = "Vegetarian"
        case peanut = "Peanuts"
        case gluten = "Gluten"
        case shellfish = "Shellfish"
        
        /// Get the corresponding asset name from the enum
        var assetName: String {
            switch self {
            case .dairy:
                return "Dairy"
            case .halal:
                return "Halal"
            case .kosher:
                return "Kosher"
            case .vegan:
                return "Vegan"
            case .vegetarian:
                return "Vegetarian"
            case .peanut:
                return "Peanuts"
            case .gluten:
                return "Gluten"
            case .shellfish:
                return "Shellfish"
            }
        }
    }
    
    extension PreferenceCategories {
        /// Initialize from a string (handles invalid values gracefully)
        init?(from rawValue: String) {
            self.init(rawValue: rawValue)
        }
    }

