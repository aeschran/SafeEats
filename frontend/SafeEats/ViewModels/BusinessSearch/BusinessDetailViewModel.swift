//
//  BusinessDetailViewModel.swift
//  SafeEats
//
//  Created by harshini on 3/31/25.
//

import Foundation
import SwiftUI

struct Review: Identifiable, Codable {
    let id: String  // Use 'id' instead of 'reviewID' for Identifiable
    let userID: String
    let businessID: String
    let userName: String
    let reviewContent: String
    let rating: Int
    let reviewTimestamp: Double
    var upvotes: Int
    var downvotes: Int
    var userVote: Int?

    enum CodingKeys: String, CodingKey {
        case id = "review_id"  // Maps JSON "review_id" to Swift "id"
        case userID = "user_id"
        case businessID = "business_id"
        case userName = "user_name"
        case reviewContent = "review_content"
        case rating
        case reviewTimestamp = "review_timestamp"
        case upvotes
        case downvotes
        case userVote = "user_vote"
    }
}




class BusinessDetailViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @AppStorage("id") var id_: String?
    @Published var collections: [Collection] = []
    @Published var errorMessage: String?
    
    private let baseURL = "http://127.0.0.1:8000"
    
    func fetchReviews(for businessID: String) {
        guard let id = id_ else {
            print("Error: User data is not available")
            return
        }
        guard let url = URL(string: "\(baseURL)/review/business/67c0f434d995a74c126ecfd7/\(id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching reviews:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let decodedReviews = try JSONDecoder().decode([Review].self, from: data)
                DispatchQueue.main.async {
                    self.reviews = decodedReviews.sorted { $0.reviewTimestamp > $1.reviewTimestamp }
                }
            } catch {
                print("Error decoding reviews:", error)
            }
        }.resume()
    }
    
    func upvoteReview(_ reviewID: String) {
        if let index = reviews.firstIndex(where: { $0.id == reviewID }) {
            var review = reviews[index]
            
            // If the user has already upvoted, remove the upvote
            if review.userVote == 1 {
                review.upvotes -= 1
                review.userVote = nil
                updateReviewVote(reviewID, vote: 3)  // Remove upvote
            } else {
                // If the user previously downvoted, remove the downvote
                if review.userVote == -1 {
                    review.downvotes -= 1
                }
                
                review.upvotes += 1
                review.userVote = 1
                updateReviewVote(reviewID, vote: 1)  // Add upvote
            }
            
            reviews[index] = review
        }
    }
    
    func downvoteReview(_ reviewID: String) {
        if let index = reviews.firstIndex(where: { $0.id == reviewID }) {
            var review = reviews[index]
            
            // If the user has already downvoted, remove the downvote
            if review.userVote == -1 {
                review.downvotes -= 1
                review.userVote = nil
                updateReviewVote(reviewID, vote: 2)  // Remove downvote
            } else {
                // If the user previously upvoted, remove the upvote
                if review.userVote == 1 {
                    review.upvotes -= 1
                }
                
                review.downvotes += 1
                review.userVote = -1
                updateReviewVote(reviewID, vote: 0)  // Add downvote
            }
            
            reviews[index] = review
        }
    }
    //    func removeUpvote(_ reviewID: String) {
    //        if let index = reviews.firstIndex(where: { $0.id == reviewID }) {
    //            if reviews[index].userVote == 1 {
    //                reviews[index].upvotes -= 1
    //                reviews[index].userVote = nil
    //                updateReviewVote(reviewID, vote: false)  // Remove the upvote
    //            }
    //        }
    //    }
    //
    //    func removeDownvote(_ reviewID: String) {
    //        if let index = reviews.firstIndex(where: { $0.id == reviewID }) {
    //            if reviews[index].userVote == -1 {
    //                reviews[index].downvotes -= 1
    //                reviews[index].userVote = nil
    //                updateReviewVote(reviewID, vote: false)  // Remove the downvote
    //            }
    //        }
    //    }
    
    private func updateReviewVote(_ reviewID: String, vote: Int) {
        guard let url = URL(string: "http://127.0.0.1:8000/review/vote/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "review_id": reviewID,
            "user_id": id_,  // Replace with the actual user ID
            "vote": vote
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = data
            
            URLSession.shared.dataTask(with: request) { _, _, _ in
                // Handle response or error if needed
            }.resume()
        } catch {
            print("Error encoding vote data:", error)
        }
        
        
    }
    
    func addBusinessToCollection(collectionName: String, businessID: String) async {
        guard let url = URL(string: "\(baseURL)/collections/add") else { return }
        

        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": id_,
            "collection_name": collectionName,
            "business_id": businessID
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
        } catch {
            print("Error adding business to collection:", error)
        }
    }
    
    func bookmarkBusiness(businessID: String) async {
        guard let url = URL(string: "\(baseURL)/collections/add") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": id_,
            "collection_name": "Bookmarks",
            "business_id": businessID
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
        } catch {
            print("Error adding business to bookmarks:", error)
        }
    }
    
    func removeBookmark(collectionId: String, businessId: String) async {
        guard let url = URL(string: "\(baseURL)/collections/remove-business") else { return }
        
        let requestBody: [String: Any] = [
            "collection_id": collectionId,
            "business_id": businessId
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to remove business from collection."
                }
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
            }
            
            return
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
        return
    }
}
