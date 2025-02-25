//
//  SettingsView.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/23/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var showChangePassword = false
    @State private var showDeleteAccountAlert = false
    @State private var showLogoutConfirmation = false
    @AppStorage("user") var userData : Data?
    
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
                        .alert(isPresented: $showChangePassword) {
                            Alert(title: Text("Change Password"),
                                  message: Text("You can implement the password change logic here."),
                                  dismissButton: .default(Text("OK")))
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
                    
                    
                }
                .scrollContentBackground(.hidden)
                .background(Color.mainGray)
            }
            .background(Color(UIColor.systemGray6))
            .background(Color.mainGray)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
