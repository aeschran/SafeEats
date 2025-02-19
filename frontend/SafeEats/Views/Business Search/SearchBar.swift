//
//  SearchBar.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/19/25.
//

import SwiftUI

struct SearchBar: View {
    @State private var searchText = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("I want a restaurant that’s...", text: $searchText)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.1)))
        .padding(.horizontal)
    }
}
