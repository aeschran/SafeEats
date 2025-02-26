//
//  FeedContentView.swift
//  SafeEats
//
//  Created by harshini on 2/25/25.
//

import SwiftUI

struct FeedContentView: View {
    var body: some View {
        List {
            ForEach(1..<10) { index in
                Text("Post #\(index)")
            }
        }
    }
}


#Preview {
    FeedContentView()
}
