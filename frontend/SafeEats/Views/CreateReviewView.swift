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
    @State private var mealName: String = ""
    @State private var selectedAccommodations: [String] = []
    @State private var showAccommodationDropdown = false

    private let accommodationOptions = [
        "Vegetarian", "Halal", "Vegan", "Kosher",
        "Peanut Free", "Dairy Free", "Gluten Free", "Shellfish Free"
    ]
    var onReviewSubmitted: () -> Void
    
    
    
    let businessId: String
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Rate this Restaurant")
                    .font(.headline)
                
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
            }
            
            
            VStack(alignment: .leading, spacing: 8) {
                // Meal Name
                Text("Meal Name")
                    .font(.headline)
                //.fontWeight(.semibold)
                
                TextField("Enter the meal you ate", text: $mealName)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            // Accommodations
            VStack(alignment: .leading, spacing: 8) {
                Text("Accommodations")
                    .font(.headline)
                //                .fontWeight(.semibold)
                
                Button(action: {
                    showAccommodationDropdown = true
                }) {
                    HStack {
                        Text(selectedAccommodations.isEmpty ? "Select Accommodations" : selectedAccommodations.joined(separator: ", "))
                            .foregroundColor(selectedAccommodations.isEmpty ? .gray : .black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    //                .background(Color.white)
                    .cornerRadius(10)
                    .background(Color.gray.opacity(0.1))
                    //                .overlay(
                    //                    RoundedRectangle(cornerRadius: 8)
                    //                        .stroke( lineWidth: 1)
                    //                )
                }
                .sheet(isPresented: $showAccommodationDropdown) {
                    VStack {
                        Text("Select Accommodations")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                        
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(accommodationOptions, id: \.self) { option in
                                    Button(action: {
                                        if selectedAccommodations.contains(option) {
                                            selectedAccommodations.removeAll { $0 == option }
                                        } else {
                                            selectedAccommodations.append(option)
                                        }
                                    }) {
                                        HStack {
                                            Text(option)
                                                .foregroundColor(.black)
                                            Spacer()
                                            if selectedAccommodations.contains(option) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.mainGreen)
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Button(action: {
                            showAccommodationDropdown = false
                        }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.mainGreen)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Write your review")
                    .font(.headline)
                
                
                TextEditor(text: $reviewText)
                    .padding(8)
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
            }

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
                viewModel.submitReview(businessId: businessId, reviewContent: reviewText, rating: rating, image: selectedImage, mealName: mealName, selectedAccommodations: selectedAccommodations)
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
