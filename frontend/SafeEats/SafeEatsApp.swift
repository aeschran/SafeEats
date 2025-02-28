//
//  SafeEatsApp.swift
//  SafeEats
//
//  Created by Ava Schrandt on 2/9/25.
//

import SwiftUI

@main
struct SafeEatsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = AuthViewModel()
    @StateObject private var createProfile = CreateProfileViewModel()
    private var login: Bool = false
    
//    init() {
//        self.login = UserDefaults.standard.bool(forKey: "loggedIn")
//    }
    
    //    @AppStorage("loggedIn") var loggedIn: Bool = false {
    //        didSet {
    //            print("loggedIn changed to:", loggedIn)
    //        }
    //    }
    //    @AppStorage("createdProfile") var createdProfile : Bool = false
    
    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "loggedIn") {
                if viewModel.isAuthenticated ?? false {
                    if UserDefaults.standard.bool(forKey: "createdProfile") {
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
            } else {
                AuthView()
                    .environmentObject(viewModel)
                    .environmentObject(createProfile)
            }
            //            CreateProfileView()
        }
    }
}
