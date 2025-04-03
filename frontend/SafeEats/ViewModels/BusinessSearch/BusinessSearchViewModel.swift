//
//  BusinessSearchViewModel.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/26/25.
//

import SwiftUI
import Combine
import CoreLocation

struct PreferenceStruct: Codable {
    let preference: String
    let preference_type: String
}

struct UserPreferences: Codable {
    let dietary_restrictions: [PreferenceStruct]
}

struct BusinessSearchRequest: Codable {
    let lat: Double
    let lon: Double
    let query: String
    var cuisines: [String]? = nil
    var dietary_restrictions: [PreferenceStruct]? = nil
    var radius: Int? = nil
}

class BusinessSearchViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var businesses: [Business] = []
    @Published var query: String = ""
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var selectedCuisines: Set<String> = []
    @Published var selectedDietaryRestrictions: Set<String> = []
    @Published var selectedAllergies: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var preferencesLoaded: Bool = false
    @Published var radius: Int = 5
    @Published var businessesMap: [BusinessMapLocation] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocation()
        
        fetchUserPreferences(userId: UserDefaults.standard.string(forKey: "id") ?? "")
        
    }
    
    // Request location permission
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func fetchUserPreferences(userId: String) {
        guard let url = URL(string: "http://localhost:8000/profile/preferences/\(userId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Request failed: \(error.localizedDescription)"
                }
                return
            }
            
            if let data = data {
                do {
                    let userPreferences = try JSONDecoder().decode(UserPreferences.self, from: data)
                    
                    var allergies: [String] = []
                    var diet: [String] = []
                    for preference in userPreferences.dietary_restrictions {
                        if preference.preference_type == "Allergy" {
                            allergies.append(preference.preference)
                        }
                        else {
                            diet.append(preference.preference)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.selectedDietaryRestrictions = Set(diet)
                        self.selectedAllergies = Set(allergies)
                        self.preferencesLoaded = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse user preferences: \(error.localizedDescription)"
                    }
                }
            }
        }
        task.resume()
    }
    
    // CLLocationManagerDelegate - Update location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.searchBusinesses()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }
    
    // Search businesses with current location
    func searchBusinesses() {
        guard latitude != 0, longitude != 0, preferencesLoaded else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://localhost:8000/business_search") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var all_preferences: [PreferenceStruct] = []
        
        for allergy in selectedAllergies {
            let preference = PreferenceStruct(preference: allergy, preference_type: "Allergy")
            all_preferences.append(preference)
        }
        
        for restriction in selectedDietaryRestrictions {
            let preference = PreferenceStruct(preference: restriction, preference_type: "Dietary Restriction")
            all_preferences.append(preference)
        }
        
        let requestBody = BusinessSearchRequest(lat: latitude, lon: longitude, query: query, cuisines: Array(selectedCuisines), dietary_restrictions: all_preferences)
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
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
                    let businesses: [Business] = try JSONDecoder().decode([Business].self, from: data)
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
    
    // Search businesses with current location
    func searchBusinessesMap() {
        guard latitude != 0, longitude != 0, preferencesLoaded else {
            print("Not ready yet")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://localhost:8000/business_search/map") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var all_preferences: [PreferenceStruct] = []
        
        for allergy in selectedAllergies {
            let preference = PreferenceStruct(preference: allergy, preference_type: "Allergy")
            all_preferences.append(preference)
        }
        
        for restriction in selectedDietaryRestrictions {
            let preference = PreferenceStruct(preference: restriction, preference_type: "Dietary Restriction")
            all_preferences.append(preference)
        }
        
        let requestBody = BusinessSearchRequest(lat: latitude, lon: longitude, query: query, cuisines: Array(selectedCuisines), dietary_restrictions: all_preferences, radius: Int(radius))
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
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
                    print("JSON data: \(String(data: data, encoding: .utf8) ?? "(no JSON data)")")
                    let businessesMap: [BusinessMapLocation] = try JSONDecoder().decode([BusinessMapLocation].self, from: data)
                    DispatchQueue.main.async {
                        self.businessesMap = businessesMap
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

