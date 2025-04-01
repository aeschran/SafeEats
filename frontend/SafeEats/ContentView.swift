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
                            FeedView()
                        case .search:
                            BusinessSearchView()
                        case .location:
                            LandingPage()
                            //                            MapView()
                        case .person:
                            MyProfileView()
                        case .building:
                            ClaimBusinessView()
                        }
                        
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
