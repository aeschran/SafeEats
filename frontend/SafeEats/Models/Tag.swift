//
//  Tag.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/24/25.
//

import SwiftUI

struct Tag: Identifiable, Hashable {
    var id: UUID = .init()
    var value: String
    var isInitial: Bool = false
}
