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
    var body: some Scene {
        WindowGroup {
//            if viewModel.isAuthenticated {
//                ContentView()
//                    .environmentObject(viewModel)
//            } else {
//                AuthView()
//                    .environmentObject(viewModel) 
//            }
            CreateProfileView()

        }
    }
}
