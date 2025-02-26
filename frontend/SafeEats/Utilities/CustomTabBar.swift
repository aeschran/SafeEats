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
        }
    }
    
    private var tabColor: Color {
        return Color.mainGreen 
    }
    private var filteredTabs: [Tab] {
        switch userType {
            case "Business":
                return [.house, .building]
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
                        .foregroundColor(selectedTab == tab ? tabColor : .gray)
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
            .background(.thinMaterial)
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
