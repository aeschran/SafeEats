//
//  SettingsView.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/23/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("user") var userData : Data?
    @State private var showChangePassword = false
    @State private var showDeleteAccountAlert = false
    @State private var showLogoutConfirmation = false
    
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
                    
                    
                }
                .scrollContentBackground(.hidden)
                .background(Color.mainGray)
                
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
    
    
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
