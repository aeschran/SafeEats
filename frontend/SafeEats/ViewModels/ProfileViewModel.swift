//
//  ProfileViewModel.swift
//  SafeEats
//
//  Created by harshini on 2/25/25.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var name: String = "loading..."
    @Published var username: String = "loading..."
    @Published var bio: String = "loading..."
    @Published var friendCount: Int = 0
    @Published var reviewCount: Int = 0
    @Published var imageBase64: UIImage? = nil
    @Published var isFollowing: Bool = false
    @Published var isRequested: Bool = false
    @Published var isTrusted: Bool = false
    @Published var didTap: Bool = false
    @Published var reviews: [FriendReview] = []
    private var friendId: String
    @AppStorage("id") var id_: String?
    

    @Published var friend: Friend
    
    init(friendId: String) {
        self.friendId = friendId
        self.friend = Friend(id: "", name: "", username: "", friendSince: "")
        //        fetchUserProfile(friendId: friendId)
    }
    func fetchData() {
        print("1")
        print(self.friendId)
        Task {
            await fetchUserProfile(friendId: self.friendId)
        }
    }
    //
    //    // Fetch the friend data asynchronously
    //    func fetchUserProfile(friendId: String) {
    //        // Here, replace with an actual network request to fetch data by friendId
    //        Task {
    //            await fetchFromBackend(friendId: friendId)
    //        }
    //    }
    
    // Initialize the ProfileViewModel with the Friend data
    //        init(friend_id: id) {
    //            self.friend_id = id
    //        }
    //    @AppStorage("user") var userData : Data?
    //
    //    var user: User? {
    //            get {
    //                guard let userData else { return nil }
    //                return try? JSONDecoder().decode(User.self, from: userData)
    //            }
    //            set {
    //                guard let newValue = newValue else { return }
    //                if let encodedUser = try? JSONEncoder().encode(newValue) {
    //                    self.userData = encodedUser
    //                }
    //            }
    //        }
    //    @AppStorage("user") var userData : Data?
    
    //    var user: User? {
    //            get {
    //                guard let userData else { return nil }
    //                return try? JSONDecoder().decode(User.self, from: userData)
    //            }
    //            set {
    //                guard let newValue = newValue else { return }
    //                if let encodedUser = try? JSONEncoder().encode(newValue) {
    //                    self.userData = encodedUser
    //                }
    //            }
    //        }
    
    private let baseURL = "http://127.0.0.1:8000"
    
    // Replace with your actual backend API URL
    
    func fetchUserProfile(friendId: String) async {
        Task {
            guard let id = id_ else {
                print("Error: User data is not available")
                return
            }
            //        guard let user = user else {
            //                print("Error: User data is not available")
            //                return
            //            }
            guard let url = URL(string: "\(baseURL)/profile/\(id)/other/\(friendId)") else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
                let decodedProfile = try JSONDecoder().decode(ProfileResponse.self, from: data)
                print(decodedProfile)
                DispatchQueue.main.async {
                    self.name = decodedProfile.name
                    self.username = decodedProfile.username
                    self.bio = decodedProfile.bio
                    self.friendCount = decodedProfile.friendCount
                    self.reviewCount = decodedProfile.reviewCount
                    self.isFollowing = decodedProfile.isFollowing
                    //                    self.isRequested = decodeProfile.isRequested
                    self.isRequested = decodedProfile.isRequested
                    self.isTrusted = decodedProfile.isTrusted
                    
                    // Decode Base64 Image
                    //                    if let imageData = Data(base64Encoded: decodedProfile.imageBase64),
                    //                       let uiImage = UIImage(data: imageData) {
                    //                        self.imageBase64 = uiImage
                    //                    }
                    if let imageBase64 = decodedProfile.imageBase64, !imageBase64.isEmpty,
                       let imageData = Data(base64Encoded: imageBase64),
                       let uiImage = UIImage(data: imageData) {
                        self.imageBase64 = uiImage
                    } else {
                        // Optionally, set a default image if the image is null
                        self.imageBase64 = UIImage(named: "blank-profile") // Use a placeholder image
                    }
                    
                }
                print(decodedProfile.name)
            } catch {
                print("Failed to fetch user profile: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserReviews(friendId: String) {
        guard let id = id_ else {
            print("Error: User ID not found")
            return
        }
        
        print("current ID \(id)")
        guard let url = URL(string: "\(baseURL)/review/profile/\(friendId)") else {
            print("Invalid URL")
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedReviews = try JSONDecoder().decode([FriendReview].self, from: data)

                DispatchQueue.main.async {
                    self.reviews = decodedReviews
                    for review in self.reviews {
                        print(review.userName)
                        print(review.userId)
                    }
                }
            } catch {
                print("Error fetching your reviews:", error)
            }
        }
    }
    

    
    func sendFriendRequest() async {
        guard let id = id_ else {
            print("Error: User data is not available")
            return
        }
        
        let requestBody: [String: Any] = [
            "sender_id": id,
            "recipient_id": friendId,
            "type": 1,
            "content": "",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        guard let url = URL(string: "\(baseURL)/notifications/create") else { return }
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestBody)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.didTap = true
                    // Change the button text to "Requested" but do not change isFollowing yet
                    //                        self.isFollowing = false
                }
            } else {
                print("Failed to send friend request: \(response)")
            }
        } catch {
            print("Error sending friend request: \(error.localizedDescription)")
        }
    }
    
    func unfollowFriend() async {
        guard let id = id_ else {
            print("Error: User data is not available")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/friends/unfollow") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["notification_id": "", "user_id": id, "friend_id": friendId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.isFollowing = false
                }
            }
        } catch {
            print("Failed to unfollow friend: \(error)")
        }
    }
    
}

struct ProfileResponse: Codable {
    let name: String
    let bio: String
    let username: String
    let friendCount: Int
    let reviewCount: Int
    let imageBase64: String?
    let isFollowing: Bool
    let isRequested: Bool
    let isTrusted: Bool
    
    // If backend uses different naming conventions, we can map it here
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case bio = "bio"
        case username = "username"
        case friendCount = "friend_count"
        case reviewCount = "review_count"
        case imageBase64 = "image"
        case isFollowing = "is_following"
        case isRequested = "is_requested"
        case isTrusted = "is_trusted"
    }
}

