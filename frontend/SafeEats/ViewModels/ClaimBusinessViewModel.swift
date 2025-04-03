//
//  ClaimBusinessViewModel.swift
//  SafeEats
//
//  Created by harshini on 4/2/25.
//

import Foundation

class ClaimBusinessViewModel: ObservableObject {
    @Published var query = ""
    @Published var businesses: [Business] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://127.0.0.1:8000/business_owners/search"
    
    func fetchSearchResults() {
        guard let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?query=\(searchQuery)")
        else { return }
        
        isLoading = true
        errorMessage = nil
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Request failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            if let data = data {
                do {
                    let businesses = try JSONDecoder().decode([Business].self, from: data)
                    DispatchQueue.main.async {
                        self.businesses = businesses
                        self.isLoading = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse JSON: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }
        }
        task.resume()
    }
    
}
