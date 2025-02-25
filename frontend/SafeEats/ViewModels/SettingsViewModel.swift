//
//  SettingsViewModel.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/24/25.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    
    @Published var tags: [Tag] = []
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    private var existingPreferences: [String] = []
    
    let baseUrl = "http://127.0.0.1:8000"
    
    init() {
            if tags.isEmpty {
                tags.append(Tag(value: "", isInitial: false))  // Ensure at least one input box is there
            }
        }
    
    func fetchExistingPreferences() async {
        guard let url = URL(string: "\(baseUrl)/preferences") else {
            return
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
            }
        } catch {
            DispatchQueue.main.async {
                print("error")
            }
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
            
            self.successMessage = "Your suggestions have been submitted to the developers! Keep an eye out for future updates!"
        }
    }
}


