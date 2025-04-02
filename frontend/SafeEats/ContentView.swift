//
//  ContentView.swift
//  SafeEats
//
//  Created by Ava Schrandt on 2/9/25.
//

import SwiftUI


struct ContentView: View {
    @State private var tabSelected: Tab = .house
    @StateObject private var viewModel = BusinessSearchViewModel()
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
                            BusinessSearchView(viewModel: viewModel)
                        case .location:
                            //LandingPage()
                            MapView(viewModel: viewModel)
                        case .person:
                            MyProfileView()
                        case .building:
                            LandingPage()
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
