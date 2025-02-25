//
//  SettingsView.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/23/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("user") var userData : Data?
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showChangePassword = false
    @State private var showDeleteAccountAlert = false
    @State private var showLogoutConfirmation = false
    @State private var tags : [Tag] = []
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    
                    Section(header: Text("Account Settings")) {
                        Button(action: {
                            // Add logic to change password
                            showChangePassword = true
                        }) {
                            Text("Change Password")
                        }
                        
                        Button(action: {
                            // Add logic for logging out
                            showLogoutConfirmation = true
                        }) {
                            Text("Log Out")
                        }
                        .alert(isPresented: $showLogoutConfirmation) {
                            Alert(title: Text("Log Out"),
                                  message: Text("Are you sure you want to log out?"),
                                  primaryButton: .destructive(Text("Log Out")) {
                                userData = nil
                                authViewModel.logout()
                                userData = nil
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
                                // Handle account deletion logic here
                                print("Account deleted")
                            },
                                  secondaryButton: .cancel())
                        }
                    }
                    
                    GroupBox(label: Label("Suggest New Preferences", systemImage: "fork.knife.circle.fill")) {
                        TagField().environmentObject(settingsViewModel)
                        }
                    
                    
                }
                .scrollContentBackground(.hidden)
                .background(Color.mainGray)

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
                    title: Text("Error"),
                    message: Text(settingsViewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK")) {
                        settingsViewModel.errorMessage = nil  // ✅ Clears the error after dismissal.
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
            
        }
        
        private func addNewTag() {
            guard !tag.value.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            // Modify the parent array through the ViewModel instead of local binding
            if let index = allTags.firstIndex(where: { $0.id == tag.id }) {
                allTags[index] = tag // Update existing tag if needed
            }
            
            if allTags.last?.value != "" {
                allTags.append(Tag(value: "", isInitial: true)) // Add a new blank tag
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = false
            }
        }
    }
}
    
#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsViewModel())
}
