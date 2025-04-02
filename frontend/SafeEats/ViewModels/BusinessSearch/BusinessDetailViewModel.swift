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
    private let baseURL = "http://127.0.0.1:8000"
    

    
    func fetchReviews(for businessId: String) {
        guard let id = id_ else {
            print("Error: User data is not available")
            return
        }
        print(businessId)
        guard let url = URL(string: "\(baseURL)/review/business/\(businessId)/\(id)") else { return }
        
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
            
            if review.userVote == 1 {
                // Remove upvote
                review.upvotes -= 1
                review.userVote = nil
                updateReviewVote(reviewID, vote: 3)
            } else {
                if review.userVote == -1 {
                    // Remove downvote first
                    review.downvotes -= 1
                    updateReviewVote(reviewID, vote: 2)
                }
                
                // Apply upvote
                review.upvotes += 1
                review.userVote = 1
                updateReviewVote(reviewID, vote: 1)
            }

            reviews[index] = review
        }
    }

    func downvoteReview(_ reviewID: String) {
        if let index = reviews.firstIndex(where: { $0.id == reviewID }) {
            var review = reviews[index]
            
            if review.userVote == -1 {
                // Remove downvote
                review.downvotes -= 1
                review.userVote = nil
                updateReviewVote(reviewID, vote: 2)
            } else {
                if review.userVote == 1 {
                    // Remove upvote first
                    review.upvotes -= 1
                    updateReviewVote(reviewID, vote: 3)
                }
                
                // Apply downvote
                review.downvotes += 1
                review.userVote = -1
                updateReviewVote(reviewID, vote: 0)
            }

            reviews[index] = review
        }
    }
        private func updateReviewVote(_ reviewID: String, vote: Int) {
            guard let id = id_ else {
                print("Error: User data is not available")
                return
            }
            guard let url = URL(string: "http://127.0.0.1:8000/review/vote/") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "review_id": reviewID,
                "user_id": id,  // Replace with the actual user ID
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
    
    func sortReviews(by filter: String) {
            switch filter {
            case "Most Recent":
                reviews.sort { $0.reviewTimestamp > $1.reviewTimestamp }
            case "Least Recent":
                reviews.sort { $0.reviewTimestamp < $1.reviewTimestamp }
            case "Most Popular":
                reviews.sort { ($0.upvotes - $0.downvotes) > ($1.upvotes - $1.downvotes) }
            case "Least Popular":
                reviews.sort { ($0.upvotes - $0.downvotes) < ($1.upvotes - $1.downvotes) }
            case "Lowest Rating":
                reviews.sort{ $0.rating < $1.rating }
            case "Highest Rating":
                reviews.sort{ $0.rating > $1.rating }
            default:
                break
            }
        }
}
