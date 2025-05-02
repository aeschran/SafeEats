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
    private let baseURL = "https://b16d-46-110-43-50.ngrok-free.app"
    @AppStorage("id") var id_: String?

    func submitReview(businessId: String, reviewContent: String, rating: Int, image: UIImage?, mealName: String, selectedAccommodations: [String]) {
        guard let id = id_ else {
            print("ID is nil")
            return
        }
        
        let createReviewUrl = URL(string: "\(baseURL)/review/create")!
        
        // Convert image to base64 string if it exists
        let base64Image = image != nil ? convertImageToBase64(image: image!) : ""
        
        let accommodationsArray: [[String: String]] = selectedAccommodations.map { preference in
               if preference.lowercased().contains("free") {
                   return [
                       "preference_type": "Allergy",
                       "preference": preference.replacingOccurrences(of: " Free", with: "")
                   ]
               } else {
                   return [
                       "preference_type": "Dietary Restriction",
                       "preference": preference
                   ]
               }
           }
           
        // Review data without image
        let reviewData: [String: Any] = [
            "user_id": id,
            "business_id": businessId,
            "review_content": reviewContent,
            "rating": rating,
            "meal": mealName.isEmpty ? "" : mealName,
            "accommodations": accommodationsArray.isEmpty ? [] : accommodationsArray,
            
        ]
        print(reviewData)
        
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
                
                self.sendReviewNotification(businessId: businessId, rating: rating)
            } catch {
                print("Error decoding review creation response: \(error)")
            }
        }.resume()
    }

    
    private func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }
    
    func deleteReview(reviewID: String, businessID: String, completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "\(baseURL)/review/delete/\(reviewID)") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.reviews.removeAll { $0.reviewId == reviewID }
                        var ratingModel = BusinessDetailViewModel()
                        ratingModel.updateAverageRating(businessId: businessID)
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }.resume()
        }
    
    func editReview(reviewID: String, updatedReview: FriendReview, newImage: UIImage? = nil, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/review/edit/\(reviewID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
                    encoder.keyEncodingStrategy = .convertToSnakeCase
                    let data = try encoder.encode(updatedReview)
                    var reviewDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]

                    // 2. Then override/add `meal` and `accomodations`
                    reviewDict["meal"] = updatedReview.meal ?? ""

                    reviewDict["accommodations"] = updatedReview.accommodations?.map { accom in
                        [
                            "preference": accom.preference,
                            "preference_type": accom.preferenceType
                        ]
                    } ?? []

                    // 3. Re-encode to JSON
                    print(reviewDict)
                    let finalJsonData = try JSONSerialization.data(withJSONObject: reviewDict, options: [])
                    request.httpBody = finalJsonData
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

                    // If new image is selected, update the image
                    if let newImage = newImage {
                        self.updateReviewImage(reviewId: reviewID, image: newImage) { imageUpdated in
                            print("Image update success: \(imageUpdated)")
                            completion(true)
                        }
                    } else {
                        completion(true)
                    }
                }
            } else {
                completion(false)
            }
        }.resume()
    }
    
    func updateReviewImage(reviewId: String, image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/review/updateimage") else {
            print("Invalid update image URL")
            completion(false)
            return
        }

        guard let imageBase64 = convertImageToBase64(image: image) else {
            print("Failed to convert image to base64")
            completion(false)
            return
        }

        let imageData: [String: Any] = [
            "review_id": reviewId,
            "review_image": imageBase64
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: imageData) else {
            print("Failed to encode image data")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Update image request failed: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
               
                completion(false)
            }
        }.resume()
    }
    
    
    private func sendReviewNotification(businessId: String, rating: Int) {
        guard let id = id_ else {
            print("User ID missing, cannot send notification")
            return
        }
        
        let notificationURL = URL(string: "\(baseURL)/notifications/create")!
        
        let notificationData: [String: Any] = [
            "sender_id": id,
            "recipient_id": businessId,  // Assuming backend knows that businesses use their _id
            "type": 3,                   // Review notification type
            "content": "Your business has received a new review!\n\n\tRating: \(rating)",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: notificationData) else {
            print("Failed to encode notification data")
            return
        }
        
        var request = URLRequest(url: notificationURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send review notification: \(error.localizedDescription)")
            } else {
                print("Review notification sent successfully!")
            }
        }.resume()
    }



    
    
}
