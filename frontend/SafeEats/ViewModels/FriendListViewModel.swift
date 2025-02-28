//
//  FriendListViewModel.swift
//  SafeEats
//
//  Created by harshini on 2/25/25.
//

import SwiftUI
import Combine

class FriendListViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    
    private let baseURL = "http://127.0.0.1:8000"
    @AppStorage("id") var id_: String?

    func fetchFriends() {
        guard let id = id_ else {
                print("Error: User data is not available")
                return
            }
        // Replace this URL with the actual URL for your backend endpoint
        guard let url = URL(string: "\(baseURL)/friends/\(id)") else { return }
        
        // Start the network request
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                do {
                        // Decode JSON directly into an array of FriendData
                        let decodedResponse = try JSONDecoder().decode([FriendData].self, from: data)
                        print(decodedResponse)
                        DispatchQueue.main.async {
                            self.friends = decodedResponse.map { friend in
                                Friend(
                                    id: friend.friend_id,
                                    name: friend.name,
                                    username: friend.username,
                                    friendSince: self.convertDateToString(friendSince: friend.friend_since)
                                )
                            }
                        }
                } catch {
                    print("Error decoding response: \(error)")
                }
            }
        }.resume()
    }
    
    
    private func convertDateToString(friendSince: Double) -> String {
        // Convert the friend_since timestamp to a readable date string
        let date = Date(timeIntervalSince1970: friendSince)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
}

//struct FriendList: Codable, Identifiable {
//    let id: String
//    let name: String
//    let username: String
//    let friendSince: String
//}

struct FriendData: Codable {
    let friend_id: String
    let friend_since: Double
    let name: String
    let username: String
}
