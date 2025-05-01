//
//  CollectionDetailViewModel.swift
//  SafeEats
//
//  Created by Jack Rookstool on 4/2/25.
//

import Foundation
import Combine

@MainActor
class CollectionDetailViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var updatedName: Bool = false
    
    @Published var business: Business?
    
    private let baseURL = "http://localhost:8000"
    
    func getBusinessInformation(businessId: String) async {
        guard let url = URL(string: "\(baseURL)/business_search/get/\(businessId)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let jsonString = String(data: data, encoding: .utf8) {
                
            }
            let decodedBusiness = try JSONDecoder().decode(Business.self, from: data)
            
            self.business = decodedBusiness
        } catch {
            print("Failed to fetch business information: \(error.localizedDescription)")
        }
    }
    
    func editCollectionName(collectionId: String, editedName: String) async -> Void {
        guard let url = URL(string: "\(baseURL)/collections/edit") else { return }
        
        if editedName == "" {
            errorMessage = "Collection name cannot be empty."
            return
        }
        
        let requestBody: [String: Any] = [
            "collection_id": collectionId,
            "name": editedName
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let json = String(data: jsonData, encoding: .utf8) {
            
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to update collection name."
                }
                return
            }
            
            print(data, response)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
                if jsonString == "null" {
                    self.errorMessage = "There is a collection by this name already."
                }
            }
            
            DispatchQueue.main.async {
                self.updatedName.toggle()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    func removeBusinessFromCollection(businessId: String, collectionId: String) async -> Collection? {
        guard let url = URL(string: "\(baseURL)/collections/remove-business") else { return nil }
        
        let requestBody: [String: Any] = [
            "collection_id": collectionId,
            "business_id": businessId
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to remove business from collection."
                }
                return nil
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
            }
            
            return try! JSONDecoder().decode(Collection.self, from: data)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
        return nil
    }
}
