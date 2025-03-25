//
//  ChangePasswordViewModel.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/23/25.
//

import Foundation
import SwiftUI

@MainActor
class ChangePasswordViewModel: ObservableObject {
    @AppStorage("authToken") private var token: String = ""
    @Published var oldPassword : String = ""
    @Published var newPassword : String = ""
    @Published var confirmNewPassword : String = ""
    @Published var isAuthenticated = false
    @Published var errorMessage : String?
    @AppStorage("username") var username: String?
    
    private let baseUrl = "http://127.0.0.1:8000"
    
    
    
    var isValid : Bool {
        !oldPassword.isEmpty && !newPassword.isEmpty && !confirmNewPassword.isEmpty
    }
    
    func validateFields() -> Bool {
        if !isValidPassword(newPassword) {
            errorMessage = "New password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character."
            return false
        } else if newPassword != confirmNewPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
        
        return true
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[a-z])(?=.*[A-Z])(?:(?=.*\d)|(?=.*[\W_])).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    func change_password() async {
        guard validateFields() else {
            return
        }
        
        guard let url = URL(string: "\(baseUrl)/users/change_password") else {
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode([
            "password": oldPassword,
            "username": username ?? "",
            "new_password": newPassword
        ]) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Response Status Code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.errorMessage = "Password change failed"
                }
                return
            }
            self.isAuthenticated = true
            print("Successful: password change")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
}
