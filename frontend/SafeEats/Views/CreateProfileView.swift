//
//  SwiftUIView.swift
//  SafeEats
//
//  Created by harshini on 2/22/25.
//

import SwiftUI
import UIKit
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isImagePickerPresented: Bool
    @Binding var image: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType // Change from value to binding
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isImagePickerPresented = false
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.isImagePickerPresented = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType // Now uses a binding
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        uiViewController.sourceType = sourceType // Ensure it updates
    }
}


struct CreateProfileView: View {
    
    @EnvironmentObject var viewModel: CreateProfileViewModel
    @State private var navigateToLandingPage = false
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var image: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    //    @State private var isCameraRoll: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    private let fieldWidth: CGFloat = 265
    
    @State private var selectedCuisines: Set<String> = []
    @State private var selectedDietaryRestrictions: Set<String> = []
    @State private var selectedAllergies: Set<String> = []
    @State private var selectedReasons: Set<String> = []
    @AppStorage("id") var id: String?
    let reasons = [
        "Easier dining decisions",
        "Finding trustworthy restaurants",
        "Support local businesses",
        "Doordash is down",
        "Other"
    ]
    
    @State private var showSuccessMessage = false
    
    
    
    func convertImageToBase64(image: UIImage?) -> String? {
        guard let imageData = image?.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }
    
    //    func sendProfileDataToBackend(_ profileData: [String: Any]) {
    ////        guard let userId = userData.id else { return }
    //        guard let url = URL(string: "\(baseURL)/profile/create/\(userId)") else { return }
    //
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "PUT"
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //
    //        do {
    //            let jsonData = try JSONSerialization.data(withJSONObject: profileData, options: [])
    //            request.httpBody = jsonData
    //        } catch {
    //            print("Error encoding JSON: \(error)")
    //            return
    //        }
    //
    //        URLSession.shared.dataTask(with: request) { data, response, error in
    //            if let error = error {
    //                print("Error sending data: \(error)")
    //                return
    //            }
    //
    //            if let httpResponse = response as? HTTPURLResponse {
    //                print("Server Response: \(httpResponse.statusCode)")
    //            }
    //        }.resume()
    //    }
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack{
                    HStack{
                        Text("Create Profile")
                            .font(.headline)
                            .scaleEffect(1.2)
                            .bold()
                        
                    }.padding(5)
                    HStack{
                        if let selectedImage = image {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 95, height: 95)
                                .clipShape(Circle())
                        } else {
                            Image("blank-profile") // Placeholder image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 95, height: 95)
                                .clipShape(Circle())
                        }
                        //                    Spacer()
                        VStack(spacing: 10){
                            Button(action: {
                                sourceType = .camera
                                isImagePickerPresented = true
                                // Set to camera
                            }) {
                                Text("Take Photo")
                                    .font(.footnote)
                                    .foregroundColor(Color.black)
                                    .frame(width:150, height: 30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.mainGreen)
                                    )
                            }
                            Button(action: {
                                sourceType = .photoLibrary
                                isImagePickerPresented = true
                            }) {
                                Text("Camera Roll")
                                    .font(.footnote)
                                    .foregroundColor(Color.black)
                                    .frame(width: 150, height: 30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.mainGreen)
                                    )
                            }
                            
                        }.padding(20)
                        Spacer()
                    }.padding(20)
                    VStack(spacing: 15){
                        
                        HStack {
                            Text("First Name:")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .scaleEffect(1.2)
                                .foregroundColor(Color.mainGreen) // Custom color for the label
                                .frame(width: 80, alignment: .leading)
                            TextField("", text: $firstName)
                                .padding(6)
                                .frame(width: fieldWidth, height: 35)
                                .background(Color.mainGray)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGreen))
                        }.padding(.horizontal)
                        
                        HStack {
                            Text("Last Name:")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.mainGreen) // Custom color for the label
                                .frame(width: 80, alignment: .leading)
                                .scaleEffect(1.2)
                            TextField("", text: $lastName)
                                .padding(6)
                                .frame(width: fieldWidth, height: 35)
                                .background(Color.mainGray)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGreen))
                        }.padding(.horizontal)
                        
                        //                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text("Bio:")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .scaleEffect(1.2)
                                .foregroundColor(Color.mainGreen)
                                .frame(width: 80, alignment: .leading)
                            TextEditor(text: $bio)
                                .frame(width: 253, height: 60)
                                .padding(6)
                                .scrollContentBackground(.hidden) // <- Hide it
                                .background(Color.mainGray)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGreen))
                                .onChange(of: bio) { newValue in
                                    if newValue.count > 150 {
                                        bio = String(newValue.prefix(150))
                                    }
                                }
                            Text("\(bio.count)/150 characters")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }.padding(.horizontal)
                        
                    }
                    
                    Spacer()
                    
                    
                    VStack {
                        Text("Pick Your Preferences")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 5)
                        PickPreferences(selectedCuisines: $selectedCuisines, selectedAllergies: $selectedAllergies, selectedDietaryRestrictions: $selectedDietaryRestrictions)
                    }
                    .padding(.vertical, 20)
                    VStack {
                        Text("Why Are You Using This App?")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 7)
                        
                        VStack(spacing: 10) {
                            ForEach(reasons, id: \.self) { reason in
                                Button(action: {
                                    if selectedReasons.contains(reason) {
                                        selectedReasons.remove(reason)
                                    } else {
                                        selectedReasons.insert(reason)
                                    }
                                }) {
                                    HStack {
                                        Text(reason)
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        if selectedReasons.contains(reason) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color.mainGreen)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(Color.mainGray)
                                        }
                                    }
                                    .padding()
                                    .frame(width: 300, height: 40)
                                    .background(Color.mainGray)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGreen))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack() {
                        Button(action: {
                            //                            print("Saved: \(firstName) \(lastName), Bio: \(bio)")
                            
                            let base64Image = convertImageToBase64(image: image) ?? ""
                            
                            let preferences = selectedAllergies.map { ["preference": $0, "preference_type": "Allergy"] } +
                            selectedDietaryRestrictions.map { ["preference": $0, "preference_type": "Dietary Restriction"] }
                            
                            let profileData: [String: Any] = [
                                "name": firstName + " " + lastName,
                                "bio": bio,
                                "image": base64Image,  // Encoded Base64 image string
                                //                                    "cuisines": Array(selectedCuisines),
                                //                                    "dietaryRestrictions": Array(selectedDietaryRestrictions),
                                //                                    "allergies": Array(selectedAllergies)
                                "friend_count" : 0,
                                "review_count": 0,
                                "preferences": preferences
                            ]
                            
                            
                            
                            viewModel.sendProfileDataToBackend(profileData)
                            //                            viewModel.createdProfile = true
                            showSuccessMessage = true
                            //                            navigateToLandingPage = true
                            
                        }) {
                            Text("Save")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 100, height: 35)
                            
                                .background(Color.mainGreen)
                                .cornerRadius(10)
                            
                        }
                        .alert("Your account has been created!", isPresented: $showSuccessMessage) {
                            Button("OK") {
                                navigateToLandingPage = true
                            }
                        }
                        .navigationDestination(isPresented: $navigateToLandingPage) {
                            ContentView().navigationBarBackButtonHidden(true)
                        }
                        //                        NavigationLink(destination: ContentView(), isActive: $navigateToLandingPage) {
                        //                            EmptyView()
                        //                        }
                        
                    }
                    
                }.padding(10)
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(
                            isImagePickerPresented: $isImagePickerPresented,
                            image: $image,
                            sourceType: $sourceType // Ensures correct source type is passed
                        )
                    }
                
                
            }
        }
    }
}

#Preview {
    CreateProfileView()
        .environmentObject(CreateProfileViewModel())
}
