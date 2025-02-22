//
//  SearchView.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/22/25.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        
        NavigationStack {
            ZStack {
                let gradientColors: [Color] = [.white, .mainGreen]
                let padding = 80
                Rectangle()
                    .fill(LinearGradient(colors: gradientColors, startPoint: UnitPoint(x: 0.5, y: 0.4), endPoint: .bottom))
                    .cornerRadius(20)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Search Page")
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
