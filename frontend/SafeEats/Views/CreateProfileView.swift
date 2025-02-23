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
    var sourceType: UIImagePickerController.SourceType  // Added sourceType to handle both camera and photo library
    
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
        picker.sourceType = sourceType // Use the sourceType passed in
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct CreateProfileView: View {

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var image: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var isCameraRoll: Bool = false
    private let fieldWidth: CGFloat = 275
    var body: some View {
        ScrollView{
            VStack{
                HStack{
                    Text("Create Profile")
                        .font(.headline)
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
                    VStack{
                        Button(action: {
                            isCameraRoll = false // Camera option
                            isImagePickerPresented = true
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
                            isCameraRoll = true // Camera roll option
                            isImagePickerPresented = true
                        }) {
                            Text("Camera Roll")
                                .font(.footnote)
                                .foregroundColor(Color.black)
                                .frame(width:150, height: 30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.mainGreen)
                                )
                        }
                    }.padding(20)
                    Spacer()
                }.padding(20)
                VStack{
                    
                    HStack {
                        Text("First Name:")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.mainGreen) // Custom color for the label
                            .frame(width: 80, alignment: .leading)
                        TextField("", text: $firstName)
                            .padding(6)
                            .frame(width: fieldWidth, height: 35)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGreen))
                    }.padding(.horizontal)
                    
                    HStack {
                        Text("Last Name:")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.mainGreen) // Custom color for the label
                            .frame(width: 80, alignment: .leading)
                        TextField("", text: $lastName)
                            .padding(6)
                            .frame(width: fieldWidth, height: 35)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGreen))
                    }.padding(.horizontal)
                    
                    //                    VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("Bio:")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.mainGreen)
                            .frame(width: 85, alignment: .leading)
                        TextEditor(text: $bio)
                            .frame(width: 260, height: 60)
                            .padding(6)
                            .scrollContentBackground(.hidden) // <- Hide it
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGreen))
                    }.padding(.horizontal)
                    
                    }
                
                Spacer()
                HStack() {

                    Button(action: {
                        print("Saved: \(firstName) \(lastName), Bio: \(bio)")
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 35)
                            
                            .background(Color.mainGreen)
                            .cornerRadius(10)
                    }
                }.padding(40)
            
            }.padding(10)
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(
                        isImagePickerPresented: $isImagePickerPresented,
                        image: $image,
                        sourceType: isCameraRoll ? .photoLibrary : .camera // Choose source type based on button clicked
                    )
                }
        }
    }
}

#Preview {
    CreateProfileView()
}
