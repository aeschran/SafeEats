import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var id: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var isVerified: Bool?
    
    @AppStorage("id") var id_: String?
    @AppStorage("email") var email_: String?
    @AppStorage("username") var username_: String?
    @AppStorage("name") var name_: String?
    @AppStorage("phone") var phone_: String?
    @AppStorage("isVerified") var isVerified_: Bool?
    
    
    @AppStorage("isAuthenticated") var isAuthenticated: Bool?
    @Published var errorMessage: String?
    //    @Published var createProfileViewModel = CreateProfileViewModel()
    @AppStorage("createdProfile") var createdProfile: Bool = false
    @AppStorage("userType") var userType: String?
    @AppStorage("isUserCreated") var isCreated: Bool = false
    @AppStorage("loggedIn") var loggedIn: Bool = false
    @AppStorage("trustedReviewer") var trustedReviewer: Bool = false
    
    
    
    
    
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
        
        if !isValidPhoneNumber(phone) {
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
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let accessToken = json["access_token"] as? String,
                           let id = json["id"] as? String,
                           let name = json["name"] as? String,
                           let email = json["email"] as? String,
                           let phone = json["phone"] as? String,
                           let username = json["username"] as? String,
                            let trustedReviewer = json["trusted_reviewer"] as? Bool {
                            DispatchQueue.main.async {
                                self.id_ = id
                                self.username_ = username
                                self.email_ = email
                                self.phone_ = phone
                                self.name_ = name
                                //self.set_user_data()
                                self.isAuthenticated = true
                                self.createdProfile = true
                                UserDefaults.standard.set(true, forKey: "loggedIn")
                                UserDefaults.standard.set(trustedReviewer, forKey: "trustedReviewer")
                                print("Success: registered")
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                self.errorMessage = "Invalid response data"
                            }
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
        print("this is currently loggedIn: \(loggedIn == true)")
        guard validateFields() else { return }
        guard let url = URL(string: "\(baseURL)/users") else { return }
        
        let requestBody: [String: Any] = [
            "name": username,
            "email": email.lowercased(),
            "phone": phone,
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
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let accessToken = json["access_token"] as? String,
                   let id = json["id"] as? String,
                   let name = json["name"] as? String,
                   let email = json["email"] as? String,
                   let phone = json["phone"] as? String,
                   let username = json["username"] as? String {
                    self.id_ = id
                    DispatchQueue.main.async {
                        self.id_ = id
                        self.name_ = name
                        self.username_ = username
                        self.email_ = email
                        self.phone_ = phone
                        //self.set_user_data()
                        self.isAuthenticated = true
                        self.createdProfile = false
                        UserDefaults.standard.set(true, forKey: "loggedIn")
                        UserDefaults.standard.set(false, forKey: "trustedReviewer")
                        print("Success: registered")
                    }
                    loggedIn = true
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid response data"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
            
        }
    }
    
    
    
    func busines_owner_login() async {
        //TODO: is there a reason we are using email to login vs username? might be good to keep consistent with reg user login
        guard let url = URL(string: "\(baseURL)/business_auth/login") else { return }
        
        let body = "username=\(email.lowercased())&password=\(password)".data(using: .utf8)
        print(username)
        print(password)
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if httpResponse.statusCode == 400 {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = json["detail"] as? String {
                        DispatchQueue.main.async {
                            if errorMessage == "Business owner not found" {
                                self.errorMessage = "The email you entered does not have an existing account."
                            } else if errorMessage == "Invalid password" {
                                self.errorMessage = "Invalid password."
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
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let accessToken = json["access_token"] as? String,
                   let id = json["id"] as? String,
                   let username = json["name"] as? String,
                   let email = json["email"] as? String,
                   let phone = json["phone"] as? String,
                   let isVerified = json["isVerified"] as? Bool {
                    DispatchQueue.main.async {
                        self.id_ = id
                        self.username_ = username
                        self.email_ = email
                        self.phone_ = phone
                        self.isVerified_ = isVerified
                        self.createdProfile = true
                        
                        print((self.email_ ?? "") + " EMAIL")
                        print(self.id_)
                        self.isCreated = true
                        self.isAuthenticated = true
                        print("Success: authenticated")
                        UserDefaults.standard.set(true, forKey: "loggedIn")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid response data"
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
            "email": email.lowercased(),
            "password": password,
            "phone": phone,
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
                if httpResponse.statusCode == 400 {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = json["detail"] as? String {
                        DispatchQueue.main.async {
                            self.errorMessage = "Business account already exists."
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Invalid request. Please check your input."
                        }
                    }
                }
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let accessToken = json["access_token"] as? String,
                   let id = json["id"] as? String,
                   let username = json["name"] as? String,
                   let email = json["email"] as? String,
                   let phone = json["phone"] as? String,
                   let isVerified = json["isVerified"] as? Bool {
                    DispatchQueue.main.async {
                        self.id_ = id
                        self.username_ = username
                        self.email_ = email
                        self.phone_ = phone
                        self.isVerified_ = isVerified
                        self.isAuthenticated = true
                        self.createdProfile = true
                        print("ID\(self.id_)")
                        print("Success: authenticated")
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid response data"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
            
        }
    }
    
    func delete_account() async {
        guard let id = id_ else {return}
        var url: URL?
        if self.userType == "User" {
            url = URL(string: "\(baseURL)/users/\(id)")
        } else if self.userType == "Business" {
            url = URL(string: "\(baseURL)/business_owners/\(id)")
        }
        
        guard let url = url else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.isAuthenticated = false
                        self.email = ""
                        self.username = ""
                        self.phone = ""
                        self.password = ""
                        self.errorMessage = nil
                        self.createdProfile = true
                        self.trustedReviewer = false
                        self.clear_user_data()
                        print("Account successfully deleted")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to delete account. Status code: \(httpResponse.statusCode)"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    func createBookmarksCollection() async {
        guard let id = id_ else {
            print("ID is nil")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/collections") else { return }
        
        
        let requestBody: [String: Any] = [
            "name": "Bookmarks",
            "user_id": id,
            "businesses": []
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    self.errorMessage = "Registration failed"
                }
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response data"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    func set_user_data() {
        DispatchQueue.main.async {
            self.email_ = self.email
            self.username_ = self.username
            self.phone_ = self.phone
            self.name_ = self.name
            self.isVerified_ = self.isVerified
        }
    }
    
    func clear_user_data() {
        self.email_ = nil
        self.username_ = nil
        self.phone_ = nil
        self.name_ = nil
        self.isVerified_ = nil
    }
    /**
     logout function to remove authToken and set isAuthenticated to false
     */
    func logout() {
        
        isAuthenticated = false
        clear_user_data()
        self.email = ""
        self.username = ""
        self.phone = ""
        self.password = ""
        self.errorMessage = nil
        self.createdProfile = false
        self.loggedIn = false
        self.trustedReviewer = false
        
        DispatchQueue.main.async {
            
            //            self.email = ""
            //            self.username = ""
            //            self.phone = ""
            //            self.password = ""
            //            self.errorMessage = nil
            //            self.createdProfile = false
            self.clear_user_data()
            //            self.createProfileViewModel = CreateProfileViewModel()
            //            self.createProfileViewModel.createdProfile = false
        }
    }
    
}
