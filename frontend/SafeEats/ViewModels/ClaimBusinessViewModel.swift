//
//  ClaimBusinessViewModel.swift
//  SafeEats
//
//  Created by Ava Schrandt on 4/2/25.
//

import SwiftUI



class ClaimBusinessViewModel: ObservableObject {
    @Published var verificationMessage: String? = nil
    @Published var isVerificationSuccessful = false

    private let baseURL = "http://127.0.0.1:8000/business_owners"
    @AppStorage("id") var id_: String?

    
    func verifyBusinessOwner(businessPhone: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/verify_business_owner") else { return }
        guard let ownerId = id_ else {return}
        print(businessPhone)
        if businessPhone == "" {
            completion(false, "Sorry, verification phone not provided for this business!")
            return
        }
        let body: [String: Any] = [
            "owner_id": ownerId,
            "business_phone": "(765) 543-5002"      // TODO: change to businessPhone, hardcoded number for testing
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, "Error: \(error.localizedDescription)")
                }
                return
            }
            
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let success = jsonResponse?["success"] as? Bool ?? false
                    let message = jsonResponse?["message"] as? String
                    DispatchQueue.main.async {
                        completion(success, message)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, "Invalid response format")
                    }
                }
            }
        }.resume()
    }
    
    func verifyPhoneCode(businessId: String, code: String, completion: @escaping (Bool, String?) -> Void) {
            guard let url = URL(string: "\(baseURL)/verify_phone_code") else { return }
            guard let ownerId = id_ else {return}
            
            let body: [String: Any] = [
                "owner_id": ownerId,
                "business_id": businessId,
                "code": code,
                "expires_at": ISO8601DateFormatter().string(from: Date())
            ]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(false, error.localizedDescription)
                        return
                    }
                    completion(true, nil)
                }
            }.resume()
        }

    

}
