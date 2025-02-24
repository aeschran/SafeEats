//
//  CreateProfileViewModel.swift
//  SafeEats
//
//  Created by harshini on 2/24/25.
//

import Foundation
import SwiftUI

@MainActor
class CreateProfileViewModel: ObservableObject {

    @Published var isCreated = false
//    @AppStorage("isUserCreated") var isCreated: Bool = false
//    @AppStorage("isUserCreated") var isCreated: Bool = false
    
    private let baseURL = "http://127.0.0.1:8000"
    
    
    func sendProfileDataToBackend(_ profileData: [String: Any]) {
        isCreated = true
       
        guard let url = URL(string: "\(baseURL)/profile/create/67bcca4cff7e518d9926f5bd") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: profileData, options: [])
            request.httpBody = jsonData
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
