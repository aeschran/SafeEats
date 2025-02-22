import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var phoneNumber: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://127.0.0.1:8000"
    
    var isValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    

    func validateFields() -> Bool {
        if !isValidEmail(email) {
            errorMessage = "Invalid email format"
            return false
        }
        
        if !isValidPassword(password) {
            errorMessage = "Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character."
            return false
        }
        
        if !isValidPhoneNumber(phoneNumber) {
            errorMessage = "Invalid phone number format. Use (XXX) XXX-XXXX or XXX-XXX-XXXX."
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
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = #"^\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}$"#
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phoneNumber)
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
    
    func user_register() async {
        guard validateFields() else { return }
        guard let url = URL(string: "\(baseURL)/users") else { return }
        
        let requestBody: [String: Any] = [
            "name": username,
            "email": email,
            "password": password,
            "username": username // TODO: talk to group about this
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Response Status Code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.errorMessage = "Registration failed"
                }
                return
            }

            
                self.isAuthenticated = true
                print("Successful: registration")
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
                }
            
        }
    }
    
    
    
    func busines_owner_login() async {
        guard let url = URL(string: "\(baseURL)/business_auth/login") else { return }
        
        let body = "username=\(email)&password=\(password)".data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.errorMessage = "Login failed"
                }
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let token = json["access_token"] as? String {
                    
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(token, forKey: "authToken")
                        self.isAuthenticated = true
                        print("Success: authenticated")
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
                }
        }
    }

    // Function to handle registration
    func business_owner_register() async {
        guard validateFields() else { return }
        guard let url = URL(string: "\(baseURL)/business_owners") else { return }
        
        let requestBody: [String: Any] = [
            "name": username,
            "email": email,
            "password": password,
            "phone_number": phoneNumber,
            "isVerified": false
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Response Status Code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.errorMessage = "Registration failed"
                }
                return
            }

            DispatchQueue.main.async {
                self.isAuthenticated = true
                print("Successful: registration")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
                }
            
        }
    }
}
