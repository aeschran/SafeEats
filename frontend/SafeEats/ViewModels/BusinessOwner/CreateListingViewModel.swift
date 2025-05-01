//
//  CreateListingViewModel.swift
//  SafeEats
//
//  Created by harshini on 4/3/25.
//

import Foundation
import SwiftUI

class CreateListingViewModel: ObservableObject {
    @AppStorage("id") var id_: String?
    

    
    private let baseURL = "http://localhost:8000"
    
    
    func sendCreatedBusinessData(_ listingData: [String: Any]) {
        
        guard let id = id_ else {
            print("ID is nil")
            return
        }
        guard let url = URL(string: "\(baseURL)/business_owners/listings/create") else { return }
        var modifiedListingData = listingData  // Create a mutable copy
        modifiedListingData["owner_id"] = id
        modifiedListingData["avg_rating"] = 0.0
        modifiedListingData["social_media"] = [
            "facebook_id": nil,
            "instagram": nil,
            "twitter": nil
        ]



        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(modifiedListingData)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: modifiedListingData, options: [])
            request.httpBody = jsonData
            print(jsonData)
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending data: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Server Response: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
}
