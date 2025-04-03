//
//  CreateReviewViewModel.swift
//  SafeEats
//
//  Created by harshini on 3/31/25.
//

import SwiftUI
import Combine

struct ReviewCreationResponse: Decodable {
    let review_id: String
}

class CreateReviewViewModel: ObservableObject {
    @Published var reviews: [FriendReview] = []
    private let baseURL = "http://127.0.0.1:8000"
    @AppStorage("id") var id_: String?

    func submitReview(businessId: String, reviewContent: String, rating: Int, image: UIImage?) {
        guard let id = id_ else {
            print("ID is nil")
            return
        }
        
        let createReviewUrl = URL(string: "\(baseURL)/review/create")!
        
        // Convert image to base64 string if it exists
        let base64Image = image != nil ? convertImageToBase64(image: image!) : ""
        
        // Review data without image
        let reviewData: [String: Any] = [
            "user_id": id,
            "business_id": businessId,
            "review_content": reviewContent,
            "rating": rating
        ]
        
        guard let createReviewData = try? JSONSerialization.data(withJSONObject: reviewData) else {
            print("Failed to encode review data")
            return
        }
        
        var createReviewRequest = URLRequest(url: createReviewUrl)
        createReviewRequest.httpMethod = "POST"
        createReviewRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        createReviewRequest.httpBody = createReviewData
        
        // Make the first request to create the review
        URLSession.shared.dataTask(with: createReviewRequest) { data, response, error in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from the backend")
                return
            }
            
            // Decode the response using the ReviewCreationResponse struct
            do {
                
                let createdReview = try JSONDecoder().decode(ReviewCreationResponse.self, from: data)
                print(createdReview)
                let reviewId = createdReview.review_id
                
                print("Review created with ID: \(reviewId)")
                
                // If an image exists, submit it to the /addimage route
                if let image = image {
                    // Only call /addimage if the image is selected
                    let addImageUrl = URL(string: "\(self.baseURL)/review/addimage")!
                    
                    let imageData: [String: Any] = [
                        "review_id": reviewId,
                        "review_image": self.convertImageToBase64(image: image)
                    ]
                    
                    guard let imageDataJson = try? JSONSerialization.data(withJSONObject: imageData) else {
                        print("Failed to encode image data")
                        return
                    }
                    
                    var addImageRequest = URLRequest(url: addImageUrl)
                    addImageRequest.httpMethod = "POST"
                    addImageRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    addImageRequest.httpBody = imageDataJson
                    
                    // Make the second request to add the image
                    URLSession.shared.dataTask(with: addImageRequest) { data, response, error in
                        if let error = error {
                            print("Request error: \(error.localizedDescription)")
                            return
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                            print("Image successfully uploaded for review")
                        } else {
                            print("Failed to upload image")
                        }
                    }.resume()
                }
            } catch {
                print("Error decoding review creation response: \(error)")
            }
        }.resume()
    }

    
    private func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }
    
    func deleteReview(reviewID: String, completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "\(baseURL)/review/delete/\(reviewID)") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.reviews.removeAll { $0.reviewId == reviewID } // Update UI
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }.resume()
        }
    
    func editReview(reviewID: String, updatedReview: FriendReview, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/review/edit/\(reviewID)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            
            let jsonData = try JSONEncoder().encode(updatedReview)
            request.httpBody = jsonData
        } catch {
            print("Error encoding review update: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    if let index = self.reviews.firstIndex(where: { $0.reviewId == reviewID }) {
                        self.reviews[index] = updatedReview
                    }
                    var ratingModel = BusinessDetailViewModel()
                    ratingModel.updateAverageRating(businessId: updatedReview.businessId)
                    completion(true)
                }
            } else {
                completion(false)
            }
        }.resume()
    }
    
    
}
