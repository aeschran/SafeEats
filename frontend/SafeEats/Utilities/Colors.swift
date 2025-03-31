//
//  Colors.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/11/25.
//

import SwiftUI

extension Color {
    static let mainGreen = Color(red: 0.639, green: 0.729, blue: 0.490)
    static let mainGray = Color(red: 0.9, green: 0.9, blue: 0.9)
    static let customLightRed = Color(red: 255/255.0, green: 153/255.0, blue: 153/255.0)
    
    func darker(by percentage: Double = 0.2) -> Color {
            guard let components = UIColor(self).cgColor.components else { return self }
            let red = Double(components[0])
            let green = Double(components[1])
            let blue = Double(components[2])

            return Color(red: max(0, red - percentage),
                         green: max(0, green - percentage),
                         blue: max(0, blue - percentage))
        }
}
