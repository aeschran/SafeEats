//
//  ContentView.swift
//  SafeEats
//
//  Created by Ava Schrandt on 2/9/25.
//

import SwiftUI


struct ContentView: View {
    @State private var tabSelected: Tab = .house
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Group {
                        switch tabSelected {
                        case .house:
                            LandingPage()
                        case .search:
                            BusinessSearchView()
                        case .location:
                            // TODO: put actual mapview here
                            MapView()
                        case .person:
                            MyProfileView()
                        }
                    .animation(.none, value: tabSelected)
                }
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $tabSelected)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
