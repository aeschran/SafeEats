//
//  OwnerBusinessDetailViewModel.swift
//  SafeEats
//
//  Created by Jack Rookstool on 4/3/25.
//

import Foundation
import SwiftUI

class OwnerBusinessDetailViewModel: ObservableObject {
    
    @Published var dietPref: [String] = []
    @Published var allergy: [String] = []
    @Published var enabled: [String: Int] = [
        "Halal": 0,
        "Kosher": 0,
        "Vegetarian": 0,
        "Vegan": 0,
        "Dairy": 0,
        "Gluten": 0,
        "Peanuts": 0,
        "Shellfish": 0
    ]
    
    private let baseURL = "http://localhost:8000"
    @Published var business: Business?

    func addPreferencesToBusiness(businessID: String) async {
        guard let url = URL(string: "\(baseURL)/businesses/\(businessID)/addPreferences") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "dietPref": dietPref,
            "allergy": allergy
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response JSON: \(jsonString)")
            }
        } catch {
            print("whoops")
        }
    }
    
    func sendEditedBusinessData(_ data: [String: Any], businessId: String) {
        
        guard let url = URL(string: "\(baseURL)/businesses/\(businessId)/edit-business") else { return }
        let modifiedListingData = data
    

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
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
    
    func getBusinessInformation(businessId: String) async {
        guard let url = URL(string: "\(baseURL)/business_search/get/\(businessId)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let jsonString = String(data: data, encoding: .utf8) {
                
            }
            let decodedBusiness = try JSONDecoder().decode(Business.self, from: data)

            DispatchQueue.main.async {
                self.business = decodedBusiness
            }

        } catch {
            print("Failed to fetch business information: \(error.localizedDescription)")
        }
    }
}
