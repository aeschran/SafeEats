import SwiftUI

struct EditProfileView: View {
    let existingProfileViewModel: MyProfileViewModel

    @State private var navigateToLandingPage = false
    @State private var username: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var image: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    private let fieldWidth: CGFloat = 265
    @AppStorage("id") var id: String?
    @State private var showSuccessMessage = false

    func convertImageToBase64(image: UIImage?) -> String? {
        guard let imageData = image?.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Edit Profile")
                        .font(.title)
                        .foregroundColor(Color.mainGreen)
                        .bold()

                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            if let selectedImage = image {
                                Image(uiImage: selectedImage)
                                    .resizable()
                            } else {
                                Image("blank-profile")
                                    .resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())

                        Button(action: {
                            sourceType = .photoLibrary
                            isImagePickerPresented = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.mainGreen).frame(width: 28, height: 28))
                        }
                        .offset(x: -5, y: -5)
                    }
                    

                    VStack(spacing: 12) {
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
                        profileField(title: "First Name:", text: $firstName)
                        profileField(title: "Last Name:", text: $lastName)

                        VStack(alignment: .leading) {
                            Text("Bio:")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.mainGreen)
                            TextEditor(text: $bio)
                                .frame(height: 80)
                                .padding(8)
                                .scrollContentBackground(.hidden)
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
                        }
                    }.padding(.horizontal)

                    HStack(spacing: 16) {
                        Button("Save") {
                            let base64Image = convertImageToBase64(image: image) ?? ""
                            let profileData: [String: Any] = [
                                "name": firstName + " " + lastName,
                                "bio": bio,
                                "image": base64Image
                            ]
                            existingProfileViewModel.sendProfileEdits(profileData)
                            showSuccessMessage = true
                        }
                        .frame(width: 100, height: 35)
                        .foregroundColor(.white)
                        .background(Color.mainGreen)
                        .cornerRadius(10)

                        Button("Cancel") {
                            navigateToLandingPage = true
                        }
                        .frame(width: 100, height: 35)
                        .foregroundColor(Color.mainGreen)
                        .background(Color.mainGray)
                        .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    .alert("Your profile has been updated!", isPresented: $showSuccessMessage) {
                        Button("OK") { navigateToLandingPage = true }
                    }
                    .navigationDestination(isPresented: $navigateToLandingPage) {
                        MyProfileView().navigationBarBackButtonHidden(true)
                    }
                }
                .padding()
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(
                        isImagePickerPresented: $isImagePickerPresented,
                        image: $image,
                        sourceType: $sourceType
                    )
                }
                .onAppear {
                    let nameParts = existingProfileViewModel.name.split(separator: " ", maxSplits: 1)
                    self.firstName = nameParts.first.map(String.init) ?? ""
                    self.lastName = nameParts.dropFirst().first.map(String.init) ?? ""
                    self.username = existingProfileViewModel.username
                    self.bio = existingProfileViewModel.bio
                    self.image = existingProfileViewModel.imageBase64
                }
                .navigationTitle(existingProfileViewModel.username)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func profileField(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(Color.mainGreen)
                .frame(width: 90, alignment: .leading)
            TextField("", text: text)
                .padding(8)
                .frame(height: 35)
                .background(Color.mainGray)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.mainGreen))
        }
    }
}
