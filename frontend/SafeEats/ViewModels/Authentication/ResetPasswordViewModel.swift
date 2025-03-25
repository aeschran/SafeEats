import SwiftUI


@MainActor
class ResetPasswordViewModel: ObservableObject {
    
    
    @Published var email: String = ""
    @Published var verificationCode: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var validEmail: Bool = false
    @Published var validCode: Bool = false
    @Published var isReset: Bool = false
    @Published var step: Int = 1
    
    var accountType: AccountType
    private var baseURL: String
    
    init(accountType: AccountType) {
        self.accountType = accountType
        self.baseURL = accountType == .businessOwnerAccount ? "http://127.0.0.1:8000/business_auth" : "http://127.0.0.1:8000/auth"
        
    }
    
    
    func validateFields() -> Bool {
        if !isValidEmail(email) {
            errorMessage = "Invalid email format"
            return false
        }
        
        if !isValidPassword(newPassword) {
            errorMessage = "Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character."
            return false
        }
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
        
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[a-z])(?=.*[A-Z])(?:(?=.*\d)|(?=.*[\W_])).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    
    func sendResetCode() async {
        guard !email.isEmpty else {
            errorMessage = "Please enter a valid email."
            return
        }
        
        guard let url = URL(string: "\(baseURL)/forgot-password") else { return }
        
        let requestBody: [String: Any] = [
            "email": email.lowercased()
        ]
        
        // Convert the dictionary to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            errorMessage = "Failed to create JSON body."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Handle HTTP Response
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if httpResponse.statusCode == 400 {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = json["detail"] as? String {
                        DispatchQueue.main.async {
                            if errorMessage == "Business owner not found" {
                                self.errorMessage = "The email you entered does not have an existing account."
                            } else {
                                self.errorMessage = "Error: invalid email"
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error \(httpResponse.statusCode)."
                    }
                }
                return
            }
            
            if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = responseJSON["message"] as? String {
                
                self.validEmail = true
                self.errorMessage = nil
                self.successMessage = message
                
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    func verifyCode() async {
        guard verificationCode.count == 6 else {
            errorMessage = "Enter a valid 6-digit code."
            return
        }
        guard let url = URL(string: "\(baseURL)/verify-reset-code") else { return }
        
        let requestBody: [String: Any] = [
            "email": email.lowercased(),
            "code": verificationCode
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            errorMessage = "Failed to create JSON body."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if httpResponse.statusCode == 400 {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = json["detail"] as? String {
                        DispatchQueue.main.async {
                            if errorMessage == "Verification code expired" {
                                self.errorMessage = "This verifcation code has expired"
                            }
                            else {
                                self.errorMessage = errorMessage
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error \(httpResponse.statusCode)."
                    }
                }
                return
            }
            
            if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = responseJSON["message"] as? String {
                self.validCode = true
                self.errorMessage = nil
                self.successMessage = message
                
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    
    func resetPassword() async {
        guard !newPassword.isEmpty, newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        guard validateFields() == true else {
            return
        }
        
        guard let url = URL(string: "\(baseURL)/reset-password") else { return }
        
        let requestBody: [String: Any] = [
            "email": email.lowercased(),
            "code": verificationCode,
            "new_password": newPassword
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            errorMessage = "Failed to create JSON body."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                
                DispatchQueue.main.async {
                    self.errorMessage = "Error \(httpResponse.statusCode)."
                }
                
                return
            }
            
            if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = responseJSON["message"] as? String {
                self.isReset = true
                self.errorMessage = nil
                self.successMessage = message
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    
}
