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
    @AppStorage("user") var userData : Data?
//    @Published var createdProfile: Bool?
    @AppStorage("createdProfile") var createdProfile: Bool = false
    

//    @AppStorage("isUserCreated") var isCreated: Bool = false
//    @AppStorage("isUserCreated") var isCreated: Bool = false
    
    var user: User? {
            get {
                guard let userData else { return nil }
                return try? JSONDecoder().decode(User.self, from: userData)
            }
            set {
                guard let newValue = newValue else { return }
                if let encodedUser = try? JSONEncoder().encode(newValue) {
                    self.userData = encodedUser
                }
            }
        }
    
    private let baseURL = "http://127.0.0.1:8000"
    
    
    func sendProfileDataToBackend(_ profileData: [String: Any]) {
        self.createdProfile = true
        guard let user = user else {
                print("Error: User data is not available")
                return
            }
       
        guard let url = URL(string: "\(baseURL)/profile/create/\(user.id)") else { return }
        
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
