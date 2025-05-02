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
    @Published var originalImageWidth: Int?
    @Published var originalImageHeight: Int?

    func loadData(businessId: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "http://localhost:8000/menu/get_menu/\(businessId)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data returned from server")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(OCRResponse.self, from: data)
                print(decoded)
                DispatchQueue.main.async {
                    guard !decoded.image_url.isEmpty,
                          let imageURL = URL(string: decoded.image_url) else {
                        print("No valid image URL returned")
                        DispatchQueue.main.async {
                            self.menuImage = nil
                            self.boxes = []
                            completion(false)
                        }
                        return
                    }

                    URLSession.shared.dataTask(with: imageURL) { imageData, _, _ in
                        guard let imageData = imageData,
                              let image = UIImage(data: imageData) else {
                            DispatchQueue.main.async {
                                self.menuImage = nil
                                self.boxes = []
                                completion(false)
                            }
                            return
                        }

                        DispatchQueue.main.async {
                            self.menuImage = image
                            self.originalImageWidth = decoded.image_width
                            self.originalImageHeight = decoded.image_height
                            if decoded.ocr_results.isEmpty {
                                print("No OCR bounding boxes returned")
                                self.boxes = []
                            } else {
                                self.boxes = decoded.ocr_results.map { result in
                                    let minX = CGFloat(result.bbox.map { $0[0] }.min() ?? 0)
                                    let minY = CGFloat(result.bbox.map { $0[1] }.min() ?? 0)
                                    let maxX = CGFloat(result.bbox.map { $0[0] }.max() ?? 0)
                                    let maxY = CGFloat(result.bbox.map { $0[1] }.max() ?? 0)
                                    let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                                    let conflictText = result.conflict?.joined(separator: ", ") ?? ""
                                    return BoundingBox(rect: rect, conflict: conflictText)
                                }
                            }
                            completion(true)
                        }
                    }.resume()
                }
            } catch {
                print("Failed to decode OCRResponse: \(error)")
            }
        }.resume()
    }
    
    func loadOfficialData(businessId: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "http://localhost:8000/menu/get_official_menu/\(businessId)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data returned from server")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(OCRResponse.self, from: data)
                print(decoded)
                DispatchQueue.main.async {
                    guard !decoded.image_url.isEmpty,
                          let imageURL = URL(string: decoded.image_url) else {
                        print("No valid image URL returned")
                        DispatchQueue.main.async {
                            self.menuImage = nil
                            self.boxes = []
                            completion(false)
                        }
                        return
                    }

                    URLSession.shared.dataTask(with: imageURL) { imageData, _, _ in
                        guard let imageData = imageData,
                              let image = UIImage(data: imageData) else {
                            DispatchQueue.main.async {
                                self.menuImage = nil
                                self.boxes = []
                                completion(false)
                            }
                            return
                        }

                        DispatchQueue.main.async {
                            self.menuImage = image
                            self.originalImageWidth = decoded.image_width
                            self.originalImageHeight = decoded.image_height
                            if decoded.ocr_results.isEmpty {
                                print("No OCR bounding boxes returned")
                                self.boxes = []
                            } else {
                                self.boxes = decoded.ocr_results.map { result in
                                    let minX = CGFloat(result.bbox.map { $0[0] }.min() ?? 0)
                                    let minY = CGFloat(result.bbox.map { $0[1] }.min() ?? 0)
                                    let maxX = CGFloat(result.bbox.map { $0[0] }.max() ?? 0)
                                    let maxY = CGFloat(result.bbox.map { $0[1] }.max() ?? 0)
                                    let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                                    let conflictText = result.conflict?.joined(separator: ", ") ?? ""
                                    return BoundingBox(rect: rect, conflict: conflictText)
                                }
                            }
                            completion(true)
                        }
                    }.resume()
                }
            } catch {
                print("Failed to decode OCRResponse: \(error)")
            }
        }.resume()
    }
    
    func uploadImage(_ image: UIImage, businessId: String, completion: @escaping (Bool, TimeInterval) -> Void) {
        let startTime = Date()
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

        URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            let elapsed = Date().timeIntervalSince(startTime)
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false, elapsed)
                }
                return
            }
            DispatchQueue.main.async {
                completion(httpResponse.statusCode == 200, elapsed)
            }
        }.resume()
    }
    
    func uploadOfficialImage(_ image: UIImage, businessId: String, completion: @escaping (Bool, TimeInterval) -> Void) {
        let startTime = Date()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return}
        let url = URL(string: "http://localhost:8000/menu/upload_official")!
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

        URLSession.shared.uploadTask(with: request, from: data) { _, response, _ in
            let elapsed = Date().timeIntervalSince(startTime)
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                completion(success, elapsed)
            }
        }.resume()
    }
    
    func uploadMenuURL(_ url: String, businessId: String, completion: @escaping (Bool, TimeInterval) -> Void) {
        let startTime = Date()
        let endpoint = URL(string: "http://localhost:8000/menu/upload_url")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyComponents = "business_id=\(businessId)&url=\(url)"
        request.httpBody = bodyComponents.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let elapsed = Date().timeIntervalSince(startTime)
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                completion(success, elapsed)
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
