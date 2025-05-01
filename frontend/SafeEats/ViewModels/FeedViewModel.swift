//
//  FeedViewModel.swift
//  SafeEats
//
//  Created by harshini on 2/25/25.
//

import Foundation
import SwiftUI

struct FriendReview: Identifiable, Codable {
    var id: String { reviewId } // Use `review_id` as the identifier
    let reviewId: String
    let userId: String
    let businessId: String
    let userName: String
    let businessName: String
    let reviewContent: String
    let rating: Int
    let reviewImage: String?
    let reviewTimestamp: Double
    let meal: String?
    let accommodations: [Accommodation]?


    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case userId = "user_id"
        case businessId = "business_id"
        case userName = "user_name"
        case businessName = "business_name"
        case reviewContent = "review_content"
        case rating
        case reviewImage = "review_image"
        case reviewTimestamp = "review_timestamp"
        case meal
        case accommodations = "accommodations"
    }
}

struct Accommodation: Codable, Hashable {
    let preferenceType: String
    let preference: String

    enum CodingKeys: String, CodingKey {
        case preferenceType = "preference_type"
        case preference
    }
}

class FeedViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [SearchUser] = []
    @Published var isSearching = false
    @Published var reviews: [FriendReview] = []
    @AppStorage("id") var id_: String?
    
    
    func searchUsers() {
        guard !searchText.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        Task {
            await fetchSearchResults()
        }
    }
    private let baseURL = "http://127.0.0.1:8000"
    
    private func fetchSearchResults() async {
        guard let id = id_ else {
            print("Error: User data is not available")
            return
        }
        //        guard let url = URL(string: "\(baseURL)/profile/search?query=\(searchText)&user_id=\(user.id)") else { return }
        
        guard let searchQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let userId = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/profile/search?query=\(searchQuery)&_id=\(userId)")
        else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedUsers = try JSONDecoder().decode([SearchUser].self, from: data)
            
            DispatchQueue.main.async {
                self.searchResults = decodedUsers
                self.isSearching = true
            }
        } catch {
            print("Error fetching search results:", error)
        }
    }
    
    func fetchFriendsReviews() {
            guard let id = id_ else {
                print("Error: User ID not found")
                return
            }
            
            guard let url = URL(string: "\(baseURL)/review/feed/\(id)") else {
                print("Invalid URL")
                return
            }

            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let decodedReviews = try JSONDecoder().decode([FriendReview].self, from: data)

                    DispatchQueue.main.async {
                        self.reviews = decodedReviews
                    }
                } catch {
                    print("Error fetching friends' reviews:", error)
                }
            }
        }

    

    func fetchMyReviews() {
        guard let id = id_ else {
            print("Error: User ID not found")
            return
        }
        
        print("current ID \(id)")
        guard let url = URL(string: "\(baseURL)/review/personal_feed/\(id)") else {
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

    
}
