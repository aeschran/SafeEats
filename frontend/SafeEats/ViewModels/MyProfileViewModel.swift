//
//  MyProfileViewModel.swift
//  SafeEats
//
//  Created by harshini on 2/24/25.
//

import Foundation
import SwiftUI

@MainActor
class MyProfileViewModel: ObservableObject {
    
    @Published var name: String = "loading..."
    @Published var username: String = "loading..."
    @Published var bio: String = "loading..."
    @Published var friendCount: Int = 0
    @Published var reviewCount: Int = 0
    @Published var imageBase64: UIImage? = nil
    @Published var collectionName: String = ""
    @Published var errorMessage: String?
    @Published var collections: [Collection] = []
    @AppStorage("id") var id_ : String?
    
    private let baseURL = "http://127.0.0.1:8000"
    
    // Replace with your actual backend API URL
    
    func fetchUserProfile() async {
        guard let id = id_ else {
            print("ID is nil")
            return
        }
        guard let url = URL(string: "\(baseURL)/profile/\(id)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
            let decodedProfile = try JSONDecoder().decode(MyProfileResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.name = decodedProfile.name
                self.username = decodedProfile.username
                self.bio = decodedProfile.bio
                self.friendCount = decodedProfile.friendCount
                self.reviewCount = decodedProfile.reviewCount
                
                // Decode Base64 Image
                if let imageData = Data(base64Encoded: decodedProfile.imageBase64),
                   let uiImage = UIImage(data: imageData) {
                    self.imageBase64 = uiImage
                }
            }
        } catch {
            print("Failed to fetch user profile: \(error.localizedDescription)")
        }
    }
    
    func createNewCollection() async {
        guard let id = id_ else {
            print("ID is nil")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/collections") else { return }
        
        if collectionName == "" {
            print("empty")
            errorMessage = "Collection name cannot be empty."
            return
        }
        
        let requestBody: [String: Any] = [
            "name": collectionName,
            "user_id": id,
            "businesses": []
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            print("sending")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print(data)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Response Status Code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.errorMessage = "Registration failed"
                }
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                self.collections.append(Collection(id: json["_id"] as! String, name: json["name"] as! String, userId: json["user_id"] as! String, businesses: json["businesses"] as! [BusinessCollection]))
                self.collectionName = ""
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response data"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    func getUserCollections() async {
        guard let id = id_ else {
            print("ID is nil")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/collections/\(id)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
            let decodedCollections = try JSONDecoder().decode([Collection].self, from: data)
            self.collections = decodedCollections
            UserDefaults.standard.set(try? JSONEncoder().encode(decodedCollections), forKey: "collections")
        } catch {
            print("Failed to fetch user collections: \(error.localizedDescription)")
        }
    }
}

struct MyProfileResponse: Codable {
    let name: String
    let bio: String
    let username: String
    let friendCount: Int
    let reviewCount: Int
    let imageBase64: String
    
    // If backend uses different naming conventions, we can map it here
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case bio = "bio"
        case username = "username"
        case friendCount = "friend_count"
        case reviewCount = "review_count"
        case imageBase64 = "image"
    }
}

struct BusinessCollection: Codable {
    let businessId: String
    let businessName: String
    let businessDescription: String
    let businessAddress: String
    
    enum CodingKeys: String, CodingKey {
        case businessId = "business_id"
        case businessName = "business_name"
        case businessDescription = "business_description"
        case businessAddress = "business_address"
    }
}

struct Collection: Codable {
    let id: String
    let name: String
    let userId: String
    let businesses: [BusinessCollection]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name = "name"
        case userId = "user_id"
        case businesses = "businesses"
    }
}

struct CollectionResponse: Codable {
    let collections: [Collection]
}
