//
//  CollectionDetailViewModel.swift
//  SafeEats
//
//  Created by Jack Rookstool on 4/2/25.
//

import Foundation
import Combine

class CollectionDetailViewModel: ObservableObject {
    @Published var collection: Collection
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://127.0.0.1:8000"

    init(collection: Collection) {
        self.collection = collection
    }

    func getBusinessInformation(businessId: String) async {
        guard let url = URL(string: "\(baseURL)/")
    }
}
