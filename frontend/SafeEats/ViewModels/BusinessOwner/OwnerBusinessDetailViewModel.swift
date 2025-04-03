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
    
    private let baseURL = "http://127.0.0.1:8000"

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
}
