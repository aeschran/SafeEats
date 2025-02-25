//
//  SettingsViewModel.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/24/25.
//

import Foundation


class SettingsViewModel: ObservableObject {
    
    @Published var prefs: [Tag] = []
    
    let baseUrl = "http://127.0.0.1:8000"
    
    func fetchExistingPreferences() {
        
    }
    
    func submitSuggestions() {
        
    }
}
