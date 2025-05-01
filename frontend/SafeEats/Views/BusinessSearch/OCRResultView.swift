//
//  OCRResultView.swift
//  SafeEats
//
//  Created by Jon Hurley on 5/1/25.
//

import SwiftUI
import Vision
import Combine
import CoreML

struct OCRResultView: View {
    @StateObject var viewModel = OCRViewModel()
    var businessId: String

    var body: some View {
        VStack {
            if let image = viewModel.menuImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            GeometryReader { geo in
                                ForEach(viewModel.boxes, id: \.id) { box in
                                    let scale = geo.size.width / image.size.width
                                    let rect = box.scaledRect(scale: scale)

                                    Rectangle()
                                        .stroke(Color.red, lineWidth: 2)
                                        .frame(width: rect.width, height: rect.height)
                                        .position(x: rect.midX, y: rect.midY)
                                        .onTapGesture {
                                            viewModel.selectedConflict = box.conflict
                                        }
                                }
                            }
                        )
                }
            }

            if let conflict = viewModel.selectedConflict {
                Text("⚠️ Conflict: \(conflict)")
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            viewModel.loadData(businessId: businessId)
        }
    }
}
