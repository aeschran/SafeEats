//
//  SettingsViewModel.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/24/25.
//

import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    
    @Published var tags: [Tag] = []
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @AppStorage("id") var id_: String?
    
    private var existingPreferences: [String] = []
    
    let baseUrl = "http://localhost:8000"
    
    init() {
        if tags.isEmpty {
            tags.append(Tag(value: "", isInitial: false))  // Ensure at least one input box is there
        }
    }
    
    func fetchExistingPreferences() async -> [String]{
        guard let url = URL(string: "\(baseUrl)/preferences") else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for json in jsonArray {
                    let pref = json["preference"] as! String
                    existingPreferences.append(pref.lowercased())
                }
                return existingPreferences
            }
        } catch {
            DispatchQueue.main.async {
                print("error")
                
            }
            
        }
        return []
    }
    
    func fetchUserPreferences() async -> [String: Set<String>] {
        guard let id = id_ else {
            print("Error: User data is not available")
            return [:] 
        }
        guard let url = URL(string: "\(baseUrl)/profile/preferences/\(id)") else {
            print("Invalid URL")
            return [:]
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Failed to fetch preferences: \(httpResponse.statusCode)")
                return [:]
            }
            
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let preferencesArray = jsonDict["dietary_restrictions"] as? [[String: Any]] {
                
                var categorizedPreferences: [String: Set<String>] = [:]
                for prefDict in preferencesArray {
                    if let preference = prefDict["preference"] as? String,
                       let preferenceType = prefDict["preference_type"] as? String {
                            categorizedPreferences[preferenceType, default: []].insert(preference)
                    }
                }
                print("Success:", categorizedPreferences)
                return categorizedPreferences
            } else {
                print("Failure: Unexpected JSON structure")
            }
        } catch {
            print("Error fetching user preferences: \(error)")
        }
        return [:]
    }

    
    func updateDietaryPreferences(updatedPreferences: [String:Any]) async {
        guard let id = id_ else {
            print("Error: User data is not available")
            return 
        }
        guard let url = URL(string: "\(baseUrl)/profile/preferences/\(id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = updatedPreferences
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Successfully updated preferences.")
            } else {
                print("Failed to update preferences. Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
            
        } catch {
            print("Error updating preferences: \(error)")
        }
    }

    
    func submitSuggestions() async {
        await fetchExistingPreferences()
        var prefSuggestions: [String] = []
        for tag in tags {
            prefSuggestions.append(tag.value)
        }
        
        for suggestion in prefSuggestions {
            if existingPreferences.contains(suggestion.lowercased()) {
                self.errorMessage = "We already support \(suggestion)."
            }
        }
        
        if self.errorMessage == nil {
            if prefSuggestions.isEmpty {
                self.errorMessage = "Please enter at least one suggestion."
                return
            }
            
            guard let url = URL(string: "\(baseUrl)/preferences/suggest") else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try! JSONSerialization.data(withJSONObject: ["preferences": prefSuggestions], options: [])
            request.httpBody = try? JSONEncoder().encode(prefSuggestions)
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("Response Status Code: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        self.errorMessage = "There was an error submitting your suggestions. Try again."
                    }
                    return
                }
                print("Successful: submit suggestions")
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
            }
            
            if (self.errorMessage == nil) {
                self.errorMessage = "Your suggestions have been submitted to the developers! Keep an eye out for future updates!"
            }
            
        }
    }
}


