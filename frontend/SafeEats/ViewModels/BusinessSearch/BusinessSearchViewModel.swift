//
//  BusinessSearchViewModel.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/26/25.
//

import SwiftUI
import Combine
import CoreLocation

struct BusinessSearchRequest: Codable {
    let lat: Double
    let lon: Double
    let query: String
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

    private var cancellables = Set<AnyCancellable>()
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestLocation()
    }

    // Request location permission
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
        guard latitude != 0, longitude != 0 else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://localhost:8000/business_search") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = BusinessSearchRequest(lat: latitude, lon: longitude, query: query)
        
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
                    let jsonString = String(data: data, encoding: .utf8)
                    print(jsonString)
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
}

