//
//  OCRResponse.swift
//  SafeEats
//
//  Created by Jon Hurley on 5/1/25.
//

import Foundation

struct OCRResponse: Codable {
    let image_url: String
    let image_width: Int
    let image_height: Int
    let ocr_results: [OCRResult]
}

struct OCRResult: Codable {
    let bbox: [[Int]]          // e.g. [[x1, y1], [x2, y2], [x3, y3], [x4, y4]]
    let conflict: [String]?    // optional, based on previous examples
}
