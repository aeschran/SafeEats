//
//  DetailedReviewViewModel.swift
//  SafeEats
//
//  Created by harshini on 4/3/25.
//

import Foundation
import Combine
import UIKit


struct DetailedReview: Identifiable, Codable {
    let id: String  // Use 'id' instead of 'reviewID' for Identifiable
    let userID: String
    let businessID: String
    let userName: String
    let businessName: String
    let reviewContent: String
    let rating: Int
    let reviewTimestamp: Double
    var upvotes: Int
    var downvotes: Int
    var reviewImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // Maps JSON "review_id" to Swift "id"
        case userID = "user_id"
        case businessID = "business_id"
        case userName = "user_name"
        case businessName = "business_name"
        case reviewContent = "review_content"
        case rating
        case reviewTimestamp = "review_timestamp"
        case upvotes
        case downvotes
        case reviewImage = "review_image"
    }
    func decodedImage() -> UIImage? {
            guard let imageData = Data(base64Encoded: reviewImage ?? "", options: .ignoreUnknownCharacters) else {
                return nil
            }
            return UIImage(data: imageData)
        }
}

class DetailedReviewViewModel: ObservableObject {
    @Published var review: DetailedReview?
    @Published var comments: [Comment] = []
    
    private let baseURL = "http://127.0.0.1:8000"
    
    func fetchDetailedReview(reviewID: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/review/\(reviewID)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Create data task
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching detailed review:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            do {
                // Decode the response into a FriendReview model
                let decodedReview = try JSONDecoder().decode(DetailedReview.self, from: data)

                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code:", httpResponse.statusCode)
                    guard httpResponse.statusCode == 200 else {
                        print("Failed to fetch review, status code:", httpResponse.statusCode)
                        return
                    }
                }

                // Debug: Print raw response data
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response:", jsonString)
                }
                // Update the main thread with the fetched review data
                
            DispatchQueue.main.async {
                self!.review = decodedReview
                print("Successfully fetched review:", decodedReview)
                }
            } catch {
                print("Error decoding review:", error.localizedDescription)
            }
        }.resume()
    }
    
    func fetchComments(for reviewID: String) async {
            guard let url = URL(string: "\(baseURL)/comment/\(reviewID)") else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedComments = try JSONDecoder().decode([Comment].self, from: data)
                DispatchQueue.main.async {
                    self.comments = decodedComments.sorted { $0.commentTimestamp > $1.commentTimestamp }
                }
            } catch {
                print("Error fetching comments:", error)
            }
        }
        
    func postComment(reviewID: String, commentContent: String, isBusiness: Bool) async {
        guard let id = UserDefaults.standard.string(forKey: "id") else { return }
        guard let url = URL(string: "\(baseURL)/comment/create") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "review_id": reviewID,
            "commenter_id": id,
            "is_business": isBusiness,
            "comment_content": commentContent
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            let (_, _) = try await URLSession.shared.data(for: request)
            await fetchComments(for: reviewID) // Refresh comments
        } catch {
            print("Error posting comment:", error)
        }
    }

}
