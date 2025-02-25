//
//  SafeEatsApp.swift
//  SafeEats
//
//  Created by Ava Schrandt on 2/9/25.
//

import SwiftUI

@main
struct SafeEatsApp: App {
    @StateObject private var viewModel = AuthViewModel()
    @StateObject private var createProfile = CreateProfileViewModel()
    var body: some Scene {
        WindowGroup {
            if viewModel.isAuthenticated {
                if createProfile.isCreated {
                    ContentView()
                        .environmentObject(viewModel)
                        .environmentObject(createProfile)
                } else {
                    CreateProfileView()
                        .environmentObject(createProfile)
                        .environmentObject(viewModel)
                }
            } else {
                AuthView()
                    .environmentObject(viewModel)
                    .environmentObject(createProfile)
            }
//            CreateProfileView()
        }
    }
}
