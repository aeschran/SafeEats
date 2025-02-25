//
//  MyProfileViewModel.swift
//  SafeEats
//
//  Created by harshini on 2/24/25.
//

import Foundation
import SwiftUI

class MyProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var bio: String = ""
    @Published var friendCount: Int = 0
    @Published var reviewCount: Int = 0
    @Published var imageBase64: UIImage? = nil
    
    private let baseURL = "http://127.0.0.1:8000"
    
      // Replace with your actual backend API URL

    func fetchUserProfile() async {
        guard let url = URL(string: "\(baseURL)/profile/67bcca4cff7e518d9926f5bd") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
            let decodedProfile = try JSONDecoder().decode(ProfileResponse.self, from: data)
            
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
}

struct ProfileResponse: Codable {
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

