//
//  SearchBar.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/19/25.
//

import SwiftUI

struct SearchBar: View {
    @ObservedObject var viewModel: BusinessSearchViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("I want a restaurant that’s...", text: $viewModel.query)
                .onSubmit {
                    viewModel.searchBusinesses()
                }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.mainGreen.opacity(0.1)))
        .padding(.horizontal)
    }
}

struct ClaimBusinessSearchBar: View {
    @ObservedObject var viewModel: ClaimBusinessViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search for business...", text: $viewModel.query)
                .onSubmit {
                    viewModel.fetchSearchResults()
                }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.mainGreen.opacity(0.1)))
        .padding(.horizontal)
    }
}
