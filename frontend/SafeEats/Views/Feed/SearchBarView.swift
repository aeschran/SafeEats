//
//  SearchBarView.swift
//  SafeEats
//
//  Created by harshini on 2/25/25.
//

import SwiftUI

//struct SearchBarView: View {
//    @State private var searchText = ""
//
//    var body: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//            TextField("I want a restaurant that’s...", text: $searchText)
//        }
//        .padding(10)
//        .background(RoundedRectangle(cornerRadius: 10).fill(Color.mainGreen.opacity(0.1)))
//        .padding(.horizontal)
//    }
//}
//

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search users...", text: $searchText)
        
        
//        HStack {
//            TextField("Search users...", text: $searchText)
//                .padding(10)
//                .background(Color(.systemGray6))
//                .cornerRadius(8)
//            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
//        .padding(.horizontal)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.mainGreen.opacity(0.1)))
        .padding(.horizontal)
    }
}


#Preview {
    @State var searchText = ""  // Define a local state for preview
    return SearchBarView(searchText: $searchText)
}
