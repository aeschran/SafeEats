//
//  LandingPage.swift
//  SafeEats
//
//  Created by Ava Schrandt on 2/17/25.
//

import SwiftUI

struct LandingPage: View {
    @AppStorage("user") var userData : Data?
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var navigateToAuth = false
    
    var user: User? {
        get {
            guard let userData else { return nil }
            return try? JSONDecoder().decode(User.self, from: userData)
        }
        set {
            guard let newValue = newValue else { return }
            if let encodedUser = try? JSONEncoder().encode(newValue) {
                self.userData = encodedUser
            }
        }
    }
    var body: some View {
        
        
        NavigationStack {
            ZStack {
                //                let gradientColors: [Color] = [.white, .mainGreen]
                //                let padding = 80
                //                Rectangle()
                //                    .fill(LinearGradient(colors: gradientColors, startPoint: UnitPoint(x: 0.5, y: 0.4), endPoint: .bottom))
                //                    .cornerRadius(20)
                //                    .ignoresSafeArea()
                
                VStack {
                } .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView().environmentObject(SettingsViewModel())) {
                            Image(systemName: "line.3.horizontal") // Settings icon
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }
    
}

#Preview {
    LandingPage()
        .environmentObject(AuthViewModel())
}
