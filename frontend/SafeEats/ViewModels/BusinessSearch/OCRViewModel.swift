//
//  OCRViewModel.swift
//  SafeEats
//
//  Created by Jon Hurley on 5/1/25.
//

import Foundation
import UIKit

class OCRViewModel: ObservableObject {
    @Published var menuImage: UIImage?
    @Published var boxes: [BoundingBox] = []
    @Published var selectedConflict: String?

    func loadData(businessId: String) {
        let url = URL(string: "http://localhost:8000/menu/\(businessId)/")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return }
            // decode the response
//            let decoded = try? JSONDecoder().decode(OCRResponse.self, from: data)
//            DispatchQueue.main.async {
//                self.menuImage = UIImage(data: Data(contentsOf: URL(string: decoded.image_url)!))
//                self.boxes = decoded.ocr_results.map { BoundingBox(from: $0) }
//            }
        }.resume()
    }
    
    func uploadImage(_ image: UIImage, businessId: String, completion: @escaping () -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return}
        let url = URL(string: "http://localhost:8000/menu/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"business_id\"\r\n\r\n")
        data.appendString("\(businessId)\r\n")
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"menu.jpg\"\r\n")
        data.appendString("Content-Type: image/jpeg\r\n\r\n")
        data.append(imageData)
        data.appendString("\r\n--\(boundary)--\r\n")

        URLSession.shared.uploadTask(with: request, from: data) { _, _, _ in
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }
}

struct BoundingBox: Identifiable {
    let id = UUID()
    let rect: CGRect
    let conflict: String

    func scaledRect(scale: CGFloat) -> CGRect {
        CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale
        )
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
