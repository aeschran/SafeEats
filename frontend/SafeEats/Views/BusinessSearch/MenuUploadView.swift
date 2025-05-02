//
//  MenuUploadView.swift
//  SafeEats
//
//  Created by Jon Hurley on 5/1/25.
//

import SwiftUI
import Foundation
import UIKit
import PhotosUI

struct SafeEatsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 0.74, green: 0.84, blue: 0.58))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct MenuUploadView: View {
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isCamera = false
    @State private var isUploading = false
    @State private var showInstructions = true
    @State private var showUploadAlert = false
    @State private var uploadSuccess = false
    @StateObject private var viewModel = OCRViewModel()
    @State var isOfficial: Bool

    var businessId: String

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(red: 0.84, green: 0.91, blue: 0.76)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Upload Menu")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top)

                if showInstructions {
                    Text("📸 Take a photo of the menu in good lighting.\nEnsure it's flat and in focus.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                    Text("Does this look good?")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Button("Take Photo") {
                    isCamera = true
                    showImagePicker = true
                }
                .buttonStyle(SafeEatsButtonStyle())

                Button("Select from Gallery") {
                    isCamera = false
                    showImagePicker = true
                }
                .buttonStyle(SafeEatsButtonStyle())

                if selectedImage != nil {
                    Button("Upload Menu") {
                        isUploading = true
                        viewModel.uploadImage(selectedImage!, businessId: businessId) { success, duration in
                            isUploading = false
                            uploadSuccess = success
                            showUploadAlert = true
                            print("Upload \(success ? "succeeded" : "failed") in \(String(format: "%.2f", duration)) seconds")
                        }
                    }
                    .disabled(isUploading)
                    .buttonStyle(SafeEatsButtonStyle())
                    if isUploading {
                        ProgressView("Uploading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                isImagePickerPresented: $showImagePicker,
                image: $selectedImage,
                sourceType: .constant(isCamera ? .camera : .photoLibrary)
            )
        }
        .alert(isPresented: $showUploadAlert) {
            Alert(
                title: Text(uploadSuccess ? "Upload Successful" : "Upload Failed"),
                message: Text(uploadSuccess ? "The menu was uploaded successfully." : "There was a problem uploading the menu. Please try again."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    MenuUploadView(isOfficial: false, businessId: "67c0f434d995a74c126ecfd7")
}
