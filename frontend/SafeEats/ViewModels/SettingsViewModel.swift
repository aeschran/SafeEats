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
                    existingPreferences.append(json["preference"] as! String)
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("help")
            }
        }
    }
    
    func submitSuggestions() async {
        var prefSuggestions: [String] = []
        for tag in tags {
            prefSuggestions.append(tag.value)
        }
        
        for suggestion in prefSuggestions {
            if existingPreferences.contains(suggestion) {
                self.errorMessage = "We already support \(suggestion)."
            }
        }
        
        if self.errorMessage == nil {
            
            // TODO: talk to Ava about Sendgrid stuff! Then all done with ViewModel
            
            self.successMessage = "Your suggestions have been submitted to the developers! Keep an eye out for future updates!"
        }
    }
}
