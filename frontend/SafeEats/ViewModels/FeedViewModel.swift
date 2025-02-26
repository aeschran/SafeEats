//
//  FeedViewModel.swift
//  SafeEats
//
//  Created by harshini on 2/25/25.
//

import Foundation
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [SearchUser] = []
    @Published var isSearching = false
    @AppStorage("user") var userData : Data?
    
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
    
    func searchUsers() {
        guard !searchText.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        Task {
            await fetchSearchResults()
        }
    }
    private let baseURL = "http://127.0.0.1:8000"

    private func fetchSearchResults() async {
        guard let user = user else {
                print("Error: User data is not available")
                return
            }
//        guard let url = URL(string: "\(baseURL)/profile/search?query=\(searchText)&user_id=\(user.id)") else { return }
        
        guard let searchQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let userId = user.id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/profile/search?query=\(searchQuery)&_id=\(userId)")
        else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedUsers = try JSONDecoder().decode([SearchUser].self, from: data)
            
            DispatchQueue.main.async {
                self.searchResults = decodedUsers
                self.isSearching = true
            }
        } catch {
            print("Error fetching search results:", error)
        }
    }
}
