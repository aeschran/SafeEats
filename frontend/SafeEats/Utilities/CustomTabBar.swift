//
//  CustomTabBar.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/22/25.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case house
    case search
    case location
    case person
    case building
    case listing
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @AppStorage("userType") var userType: String?
    
    private func iconName(for tab: Tab) -> String {
        switch tab {
            
        case .house:
            return selectedTab == tab ? "house.fill" : "house"
        case .search:
            return "magnifyingglass"
        case .location:
            return selectedTab == tab ? "location.fill" : "location"
        case .person:
            return selectedTab == tab ? "person.fill" : "person"
        case .building:
            return selectedTab == tab ? "building.2.fill" : "building.2"
        case .listing:
            return selectedTab == tab ? "list.bullet.clipboard.fill" : "list.bullet.clipboard"
        
        }
    }
    
    private var tabColor: Color {
        return Color.white
    }
    private var filteredTabs: [Tab] {
        switch userType {
        case "Business":
            return [.listing, .building]
        case "User":
            return [.house, .location, .search, .person]
        default:
            return []
        }
    }
    var body: some View {
        VStack {
            HStack {
                ForEach(filteredTabs, id: \.rawValue) { tab in
                    
                    Spacer()
                    Image(systemName: iconName(for: tab))
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundColor(selectedTab == tab ? tabColor : .white)
                        .font(.system(size: 20))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(height: 60)
            //            .background(.white)
            //            .background(.thinMaterial)
            .background(Color.mainGreen.opacity(0.9))
            .cornerRadius(20)
            .padding()
        }
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.house))
    }
}
