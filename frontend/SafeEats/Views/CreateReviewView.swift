//
//  CreateReviewView.swift
//  SafeEats
//
//  Created by harshini on 3/31/25.
//

import SwiftUI



struct CreateReviewView: View {
    @ObservedObject var viewModel = CreateReviewViewModel()
    @ObservedObject var notifViewModel = NotificationsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showSuccessMessage = false
    var onReviewSubmitted: () -> Void
    
    
    
    let businessId: String
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Rate this Restaurant")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            HStack {
                ForEach(1...5, id: \..self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            rating = star
                        }
                }
            }
            
            Text("Write your review")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextEditor(text: $reviewText)
                .frame(height: 150)
                .border(Color.gray, width: 1)
                .padding(.bottom)
            
            Button(action: {
                showImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Add Image")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.mainGreen)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .sheet(isPresented: $showImagePicker) {
                ReviewImagePicker(image: $selectedImage)
            }
            // Display selected image
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.vertical)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.submitReview(businessId: businessId, reviewContent: reviewText, rating: rating, image: selectedImage)
                onReviewSubmitted()
                
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Create Review")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.mainGreen)
                    .cornerRadius(10)
            }
//            .alert("Your review has been created!", isPresented: $showSuccessMessage) {
//                Button("OK") {
//                }
//            }
        }
        .padding()
        .navigationTitle("Write a Review")
    }
    
    private func submitReview() {
        print("Review submitted with rating: \(rating) and text: \(reviewText)")
    }
}

struct ReviewImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ReviewImagePicker
        
        init(_ parent: ReviewImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            picker.dismiss(animated: true)
        }
    }
}


#Preview {
    CreateReviewView(onReviewSubmitted: {}, businessId: "67c0f434d995a74c126ecfd7")
}
