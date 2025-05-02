//
//  AnnotatedMenu.swift
//  SafeEats
//
//  Created by Jon Hurley on 5/1/25.
//


import SwiftUI

struct AnnotatedMenu: View {
    @StateObject private var viewModel = OCRViewModel()
    var official: Bool
    var businessId: String

    var body: some View {
        VStack {
            if let image = viewModel.menuImage {
                Group {
                    guard let originalWidth = viewModel.originalImageWidth,
                          let originalHeight = viewModel.originalImageHeight else {
                        return AnyView(EmptyView())
                    }
                    let imageSize = CGSize(width: CGFloat(originalWidth), height: CGFloat(originalHeight))
                    return AnyView(
                        GeometryReader { geo in
                            ZStack(alignment: .topLeading) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width, alignment: .top)
                                    .clipped()

                                let containerSize = geo.size
                                let scale = min(containerSize.width / imageSize.width,
                                                containerSize.height / imageSize.height)

                                let displayedImageWidth = imageSize.width * scale
                                let displayedImageHeight = imageSize.height * scale

                                let horizontalOffset = (containerSize.width - displayedImageWidth) / 2
                                let verticalOffset = (containerSize.height - displayedImageHeight) / 2

                                ForEach(viewModel.boxes) { box in
                                    Rectangle()
                                        .stroke(Color.red, lineWidth: 2)
                                        .frame(width: box.rect.width * scale, height: box.rect.height * scale)
                                        .position(
                                            x: box.rect.midX * scale + horizontalOffset,
                                            y: box.rect.midY * scale + verticalOffset
                                        )
                                        .onTapGesture {
                                            viewModel.selectedConflict = box.conflict
                                        }
                                }
                            }
                        }
                    )
                }
            } else {
                ProgressView("Loading Menu...")
            }

            if let conflict = viewModel.selectedConflict {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.red)
                            .clipShape(Circle())

                        Text("Allergen Conflict Detected")
                            .font(.headline)
                            .foregroundColor(.red)
                    }

                    let labelMap: [String: String] = [
                        "halal": "Halal",
                        "vegetarian": "Vegetarian",
                        "vegan": "Vegan",
                        "gluten_free": "Gluten",
                        "dairy_free": "Dairy",
                        "peanut_free": "Peanuts",
                        "kosher": "Kosher",
                        "shellfish_free": "Shellfish"
                    ]
                    let formattedConflict = conflict
                        .split(separator: ",")
                        .map { labelMap[String($0).trimmingCharacters(in: .whitespacesAndNewlines)] ?? String($0) }
                        .joined(separator: ", ")

                    Text(formattedConflict)
                        .font(.body)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                .padding([.horizontal, .top])
            }
        }
        .onAppear {
            if official {
                viewModel.loadOfficialData(businessId: businessId) { success in
                    if !success {
                        print("Failed to load menu image and data")
                    }
                }
            } else {
                viewModel.loadData(businessId: businessId) { success in
                    if !success {
                        print("Failed to load menu image and data")
                    }
                }
            }
        }
        .navigationTitle("Annotated Menu")
        .navigationBarTitleDisplayMode(.inline)
    }
}
