//
//  OwnerListingViewModel.swift
//  SafeEats
//
//  Created by harshini on 4/2/25.
//

import SwiftUI

class OwnerListingsViewModel: ObservableObject {
    @Published var businesses: [Business] = []
    @Published var isLoading = false
    @AppStorage("userType") private var userType: String?
    @AppStorage("id") var id_: String?

    func fetchOwnerListings() {
        guard let id = id_ else {return}

        
        isLoading = true
        let urlString = "http://127.0.0.1:8000/business_owners/listings/\(id)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                print("Error fetching listings: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode([Business].self, from: data)
                DispatchQueue.main.async {
                    self.businesses = decodedResponse
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }.resume()
    }
}
