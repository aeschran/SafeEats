//
//  FriendRequestView.swift
//  SafeEats
//
//  Created by Jon Hurley on 2/22/25.
//

import SwiftUI

struct FriendRequestView: View {
    let request: NotificationResponse
    var onAccept: () -> Void
    var onDeny: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: request.profileImageURL ?? "https://via.placeholder.com/150")) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.circle.fill").resizable().foregroundColor(Color.mainGreen)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            Text(request.sender_username)
                .font(.headline)

            Spacer()

            Button("Accept", action: onAccept)
                .buttonStyle(.borderedProminent)
                .tint(Color.mainGreen)
                .foregroundColor(.black)

            Button("Deny", action: onDeny)
                .buttonStyle(.bordered)
                .foregroundColor(.black)
        }
        .padding()
    }
}
