//
//  ChangePasswordView.swift
//  SafeEats
//
//  Created by Jack Rookstool on 2/23/25.
//

import SwiftUI


struct ChangePasswordView: View {
    @StateObject var viewModel : ChangePasswordViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State var oldPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    
    @State var showOldPassword = false
    @State var showNewPassword = false
    @State var showConfirmPassword = false
    
    @FocusState var isOldPasswordFocused: Bool
    @FocusState var isNewPasswordFocused: Bool
    @FocusState var isConfirmPasswordFocused: Bool
    
    @State var navigateToSettings = false
    
    
    
    
    var body: some View {
        VStack {
            Text("Change Password")
                .font(.largeTitle)
            ZStack {
                TextField("Old Password", text: $viewModel.oldPassword)
                    .padding()
                    .autocapitalization(.none)
                    .focused($isOldPasswordFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isOldPasswordFocused))
                    .opacity(showOldPassword ? 1 : 0)
                    .zIndex(showOldPassword ? 1 : 0)
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                showOldPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showOldPassword ? "eye.fill" : "eye.slash.fill")
                                .padding(.horizontal, 25)
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }
                SecureField("Old Password", text: $viewModel.oldPassword)
                    .padding()
                    .autocapitalization(.none)
                    .focused($isOldPasswordFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isOldPasswordFocused))
                    .opacity(showOldPassword ? 0 : 1)
                    .zIndex(showOldPassword ? 0 : 1)
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                showOldPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showOldPassword ? "eye.fill" : "eye.slash.fill")
                                .padding(.horizontal, 25)
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }
            }
            
            ZStack {
                TextField("New Password", text: $viewModel.newPassword)
                    .padding()
                    .autocapitalization(.none)
                    .focused($isNewPasswordFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isNewPasswordFocused))
                    .opacity(showNewPassword ? 1 : 0)
                    .zIndex(showNewPassword ? 1 : 0)
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                showNewPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showNewPassword ? "eye.fill" : "eye.slash.fill")
                                .padding(.horizontal, 25)
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }
                SecureField("New Password", text: $viewModel.newPassword)
                    .padding()
                    .autocapitalization(.none)
                    .focused($isNewPasswordFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isNewPasswordFocused))
                    .opacity(showNewPassword ? 0 : 1)
                    .zIndex(showNewPassword ? 0 : 1)
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                showNewPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showNewPassword ? "eye.fill" : "eye.slash.fill")
                                .padding(.horizontal, 25)
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }
            }
            ZStack {
                TextField("Confirm New Password", text: $viewModel.confirmNewPassword)
                    .padding()
                    .autocapitalization(.none)
                    .focused($isConfirmPasswordFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isConfirmPasswordFocused))
                    .opacity(showConfirmPassword ? 1 : 0)
                    .zIndex(showConfirmPassword ? 1 : 0)
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                showConfirmPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showConfirmPassword ? "eye.fill" : "eye.slash.fill")
                                .padding(.horizontal, 25)
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }
                SecureField("Confirm New Password", text: $viewModel.confirmNewPassword)
                    .padding()
                    .autocapitalization(.none)
                    .focused($isConfirmPasswordFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isConfirmPasswordFocused))
                    .opacity(showConfirmPassword ? 0 : 1)
                    .zIndex(showConfirmPassword ? 0 : 1)
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                showConfirmPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showConfirmPassword ? "eye.fill" : "eye.slash.fill")
                                .padding(.horizontal, 25)
                                .foregroundStyle(Color(UIColor.lightGray))
                        }
                    }
            }
            Button {
                Task {
                    await viewModel.change_password()
                }
            } label: {
                Text("Change Password")
            }
            .buttonStyle(AuthButtonType())
            .onChange(of: viewModel.isAuthenticated) {
                if viewModel.isAuthenticated {
                    dismiss()
                }
                
            }
        }
        
        
        
    }
}

#Preview {
    ChangePasswordView(viewModel: ChangePasswordViewModel())
}
