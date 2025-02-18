//
//  AuthViewModel.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/17/25.
//

import Foundation

import Combine

enum LoginError: Error {
    case invalidPassword
    case usernameNotFound
    case unknownError
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    
    private let baseURL = "http://127.0.0.1:8000"
    
    var isValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    // handles user login
    func user_login() async {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            return
        }
        
        guard isValid else { self.errorMessage = "One or more fields is empty"
            return }
        
        let bodyString = "username=\(username)&password=\(password)"
        let bodyData = bodyString.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // success case
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = json["access_token"] as? String {
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(token, forKey: "authToken")
                            self.isAuthenticated = true
                            print("Success: authenticated")
                        }
                    }
                } else if httpResponse.statusCode == 400 {
                    // handles error response from the server
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = json["detail"] as? String {
                        DispatchQueue.main.async {
                            if errorMessage == "User does not exist" {
                                self.errorMessage = "The username you entered does not exist."
                            } else if errorMessage == "Wrong password" {
                                self.errorMessage = "The password you entered is incorrect."
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Invalid request. Please check your input."
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Login failed with status code \(httpResponse.statusCode)."
                    }
                }
                return
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
}
