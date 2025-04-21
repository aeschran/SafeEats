//
//  SettingsView.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/23/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var myProfileViewModel: MyProfileViewModel
    @State private var showChangePassword = false
    @State private var showDeleteAccountAlert = false
    @State private var showLogoutConfirmation = false
    @State private var showEditPrefSheet = false
    @AppStorage("userType") private var userType: String?
    @AppStorage("showDeleteConfirmation") private var showDeleteConfirmation = false
    @State private var tags : [Tag] = []
    
    @AppStorage("loggedIn") private var loggedIn: Bool = false
    @AppStorage("staySignedIn") private var staySignedIn: Bool = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Account Settings")){
                        if (userType == "User") {
                            Button(action: {
                                showEditPrefSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "heart.text.square.fill")
                                    Text("Edit Dietary Preferences")
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.forward")
                                        .foregroundColor(Color.mainGreen)
                                        .frame(alignment: .trailing)
                                }
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                
                            }
                            .sheet(isPresented: $showEditPrefSheet) {
                                EditDietaryPreferencesView(showSheet: $showEditPrefSheet)
                            }
                            HStack {
                                Button(action: {
                                    staySignedIn = !staySignedIn
                                }) {
                                    Image(systemName: staySignedIn ? "checkmark.square.fill" : "square")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(staySignedIn ? .mainGreen : .gray)
                                }
                                .buttonStyle(.plain)
                                
                                Text("Stay Signed In")
                                    .fontWeight(.semibold)
                                    .onTapGesture {}
                            }
                        }
                        Button(action: {
                            showChangePassword = true
                        }) {
                            Text("Change Password")
                        }
                        
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            Text("Log Out")
                        }
                        .alert(isPresented: $showLogoutConfirmation) {
                            Alert(title: Text("Log Out"),
                                  message: Text("Are you sure you want to log out?"),
                                  primaryButton: .destructive(Text("Log Out")) {
                                
                                authViewModel.logout()
                            },
                                  secondaryButton: .cancel())
                        }
                        
                        Button(action: {
                            // Add logic for deleting account
                            showDeleteAccountAlert = true
                        }) {
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showDeleteAccountAlert) {
                            Alert(title: Text("Delete Account"),
                                  message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                                  primaryButton: .destructive(Text("Delete")) {
                                Task {
                                    await authViewModel.delete_account()
                                    
                                }
                                showDeleteConfirmation = true
                                
                            },
                                  secondaryButton: .cancel())
                        }
                        
                    }
                    
                    Section {
                        
                    }
                    
                    GroupBox(label: Label("Suggest New Preferences", systemImage: "fork.knife.circle.fill")) {
                        TagField().environmentObject(settingsViewModel)
                    }
                    .fontWeight(.semibold)
                    
                    
                    
                    
                    
                }
                .scrollContentBackground(.hidden)
                .background(Color.mainGray)
                
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Account Deleted"),
                    message: Text("Your account has been successfully deleted."),
                    dismissButton: .default(Text("OK")) {
                        showDeleteConfirmation = false // Reset after dismissal
                    }
                )
            }
            Text("Have any questions? Email us at safeeats.dev@gmail.com!")
        }
        .background(Color(UIColor.systemGray6))
        .background(Color.mainGray)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        
        NavigationLink(
            destination: ChangePasswordView(viewModel: ChangePasswordViewModel()),
            isActive: $showChangePassword
        ) {
            EmptyView()
        }
        
        
    }
}




struct TagField: View {
    
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    var body : some View {
        ZStack {
            VStack {
                VStack {
                    ForEach($settingsViewModel.tags.indices, id: \.self) { index in
                        TagView(tag: $settingsViewModel.tags[index], allTags: $settingsViewModel.tags)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(.bar, in: .rect(cornerRadius: 12))
                    .onAppear {
                        if settingsViewModel.tags.isEmpty {
                            settingsViewModel.tags.append(Tag(value: "", isInitial: true))
                        }
                    }
                    Button {
                        Task {
                            await settingsViewModel.submitSuggestions()
                        }
                    } label: {
                        Text("Submit Suggestions")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.mainGreen)
                                        .zIndex(1)
                                }
                            )
                    }
                }
                
            }
            .zIndex(settingsViewModel.errorMessage == nil ? 1 : 0)
            
            //            Text(settingsViewModel.errorMessage ?? "")
            //                .foregroundColor(.red)
            //                .padding()
            //                .zIndex(settingsViewModel.errorMessage == nil ? 0 : 1)
            //                .disabled(true)
            //
            .alert(isPresented: Binding<Bool>(
                get: { settingsViewModel.errorMessage != nil },
                set: { if !$0 { settingsViewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Notice"),
                    message: Text(settingsViewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")) {
                        settingsViewModel.errorMessage = nil
                    }
                )
            }
            
        }
        
        
    }
    
    fileprivate struct TagView: View {
        @Binding var tag: Tag
        @Binding var allTags: [Tag]
        @FocusState private var isFocused: Bool
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            HStack {
                TextField("New Preference", text: $tag.value)
                    .focused($isFocused)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background((colorScheme == .dark ? Color.black : Color.white).opacity(isFocused ? 0 : 1), in: .rect(cornerRadius: 5))
                    .disabled(tag.isInitial)
                    .overlay {
                        if tag.isInitial {
                            Rectangle()
                                .fill(.clear)
                                .contentShape(.rect)
                                .onTapGesture {
                                    tag.isInitial = false
                                    isFocused = true
                                }
                        }
                    }
                    .onSubmit {
                        addNewTag()
                    }
                
                Button(action: {
                    removeTag()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .padding(.leading, 8)
            }
        }
        
        private func addNewTag() {
            guard !tag.value.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            if let index = allTags.firstIndex(where: { $0.id == tag.id }) {
                allTags[index] = tag
            }
            
            if allTags.last?.value != "" {
                allTags.append(Tag(value: "", isInitial: true))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = false
            }
        }
        
        private func removeTag() {
            if let index = allTags.firstIndex(where: { $0.id == tag.id }) {
                allTags.remove(at: index)
            }
            
            // Ensure at least one empty tag remains
            if allTags.isEmpty {
                allTags.append(Tag(value: "", isInitial: true))
            }
        }
    }
}



struct EditDietaryPreferencesView: View {
    @Binding var showSheet: Bool
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var selectedDietaryRestrictions: Set<String> = []
    @State private var selectedAllergies: Set<String> = []
    @State private var selectedCuisines: Set<String> = []
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Edit Dietary Preferences")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                
                PickPreferences(
                    selectedCuisines: $selectedCuisines,
                    selectedAllergies: $selectedAllergies,
                    selectedDietaryRestrictions: $selectedDietaryRestrictions
                )
                .padding(.vertical)
                
                
                Button(action: {
                    let preferences = selectedAllergies.map { ["preference": $0, "preference_type": "Allergy"] } +
                    selectedDietaryRestrictions.map { ["preference": $0, "preference_type": "Dietary Restriction"] } + selectedCuisines.map {["preference": $0, "preference_type": "Cuisine"] }
                    
                    let updatedData: [String: Any] = [
                        "preferences": preferences
                    ]
                    Task {
                        await settingsViewModel.updateDietaryPreferences(updatedPreferences: updatedData)
                        showSuccessMessage = true
                    }
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180, height: 40)
                        .background(Color.mainGreen)
                        .cornerRadius(10)
                }
                .alert("Your preferences have been updated!", isPresented: $showSuccessMessage) {
                    Button("OK", role: .cancel) { }
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                Task {
                    await fetchUserPreferences()
                }
            }
            .navigationBarItems(trailing: Button(action: {
                showSheet = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
            })
        }
    }
    
    func fetchUserPreferences() async {
        let preferences = await settingsViewModel.fetchUserPreferences()
        
        DispatchQueue.main.async {
            // Fetch preferences from their respective categories
            self.selectedDietaryRestrictions = preferences["Dietary Restriction"] ?? []
            self.selectedAllergies = preferences["Allergy"] ?? []
            self.selectedCuisines = preferences["Cuisine"] ?? []
        }
    }
    
}




#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsViewModel())
}
