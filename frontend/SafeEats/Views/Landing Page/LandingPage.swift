//
//  LandingPage.swift
//  SafeEats
//
//  Created by Ava Schrandt on 2/17/25.
//

import SwiftUI

struct LandingPage: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var navigateToAuth = false
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
                    Text("Login/Registration Successful")
                }
            }
        }
    }
    
}

#Preview {
    LandingPage()
        .environmentObject(AuthViewModel())
}
