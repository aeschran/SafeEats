//
//  ContentView.swift
//  SafeEats
//
//  Created by Ava Schrandt on 2/9/25.
//

import SwiftUI


struct ContentView: View {
//    @State private var tabSelected: Tab = .house
    @State private var tabSelected: Tab
    init() {
        UITabBar.appearance().isHidden = true
        _tabSelected = State(initialValue: AuthViewModel().userType == "Business" ? .building : .house)
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
                            //LandingPage()
                            MapView()
                        case .person:
                            MyProfileView()
                        case .building:
                            OwnerListingsView()
                        case .listing:
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
