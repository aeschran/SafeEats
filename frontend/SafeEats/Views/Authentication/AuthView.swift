//
//  AuthView.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/11/25.
//

import SwiftUI

enum AuthType {
    case login
    case register
}

struct AuthView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isPhoneNumberFocused: Bool
    @FocusState private var isUsernameFocused: Bool
    
    @State private var showPassword = false
    @State private var authType: AuthType = .login
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.white, .mainGreen], startPoint: UnitPoint(x: 0.5, y: 0.4), endPoint: .bottom))
                .cornerRadius(20)
                .ignoresSafeArea()
            
            VStack {
                TopView()
                SegmentedView(authType: $authType)
                
                VStack(spacing: 15) {
                    TextField(text: $email) {
                        Text(authType == .login ? "Username" : "Email")
                    }
                    .padding(.horizontal, 10)
                    .focused($isEmailFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isEmailFocused))
                    
                    if authType == .register { TextField("Username", text: $username) .padding(.horizontal, 10) .focused($isUsernameFocused) .textFieldStyle(AuthTextFieldStyle(isFocused: $isUsernameFocused)) }
                    
                    if authType == .register { TextField("Phone Number", text: $phoneNumber) .padding(.horizontal, 10) .focused($isPhoneNumberFocused) .textFieldStyle(AuthTextFieldStyle(isFocused: $isPhoneNumberFocused)) }
                    
                    ZStack {
                        TextField(text: $password) {
                            Text("Password")
                        }
                        .padding(.horizontal, 10)
                        .focused($isPasswordFocused)
                        .textFieldStyle(AuthTextFieldStyle(isFocused: $isPasswordFocused))
                        .opacity(showPassword ? 1 : 0)
                        .zIndex(showPassword ? 1 : 0)
                        .overlay(alignment: .trailing) {
                            Button {
                                withAnimation {
                                    showPassword.toggle()
                                }
                            } label: {
                                Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                    .padding(.horizontal, 25)
                                    .foregroundStyle(Color(UIColor.lightGray))
                            }
                        }
                        
                        SecureField(text: $password) {
                            Text("Password")
                        }
                        .padding(.horizontal, 10)
                        .focused($isPasswordFocused)
                        .textFieldStyle(AuthTextFieldStyle(isFocused: $isPasswordFocused))
                        .opacity(showPassword ? 0 : 1)
                        .zIndex(showPassword ? 0 : 1)
                        .overlay(alignment: .trailing) {
                            Button {
                                withAnimation {
                                    showPassword.toggle()
                                }
                            } label: {
                                Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                    .padding(.horizontal, 25)
                                    .foregroundStyle(Color(UIColor.lightGray))
                            }
                        }
                    }
                    
                }
                
                Button {
                    
                } label: {
                    Text(authType == .login ? "Login" : "Register")
                }
                .buttonStyle(AuthButtonType())
                
                BottomView(authType: $authType)
            }
            .padding(.top, -120)
            .padding()
            .gesture(TapGesture()
                .onEnded({
                    isEmailFocused = false
                    isPasswordFocused = false
                    isPhoneNumberFocused = false
                    isUsernameFocused = false
                })
            )
        }
    }
}
                             
struct AuthButtonType: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: 345)
            .padding(.vertical)
            .foregroundStyle(.white)
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .bold))
            .background(Color.mainGreen)
            .cornerRadius(15)
            .brightness(configuration.isPressed ? 0.05 : 0)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .padding(.vertical, 12)
    }
                    
}

struct AuthTextFieldStyle: TextFieldStyle {
    
    let isFocused: FocusState<Bool>.Binding
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .font(.system(size: 20, weight: .bold))
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isFocused.wrappedValue ? Color.mainGreen :
                                    Color.gray.opacity(0.5), lineWidth: 2)
                        .zIndex(1)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.white))
                        .zIndex(0)
                }
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
    }
}

struct TopView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("SafeEats-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250)
                            .padding(.top, -40)
        }
        
    }
}

struct SegmentedView: View {
    @Binding var authType: AuthType
    let lightGray = Color(white: 0.9)
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    authType = .login
                }
            } label: {
                Text("Login")
                    .fontWeight(authType == .login ? .semibold : .regular)
                    .foregroundStyle(authType == .login ? .white : .gray)
                    .padding(.vertical, 12)
                    .padding(.horizontal, authType == .login ? 60 : 30)
                    .background(
                        ZStack {
                            if authType == .login {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.mainGreen.opacity(0.3), lineWidth: 0.5)
                                    .zIndex(1)
                            }
                            RoundedRectangle(cornerRadius: 15)
                                .fill(authType == .login ? Color.mainGreen : lightGray)
                                .zIndex(1)
                        }
                    )
                    .animation(.spring(duration: 0.4), value: authType)
            }
            Button {
                withAnimation {
                    authType = .register
                }
            } label: {
                Text("Register")
                    .fontWeight(authType == .register ? .semibold : .regular)
                    .foregroundStyle(authType == .register ? .white : .gray)
                    .padding(.vertical, 12)
                    .padding(.horizontal, authType == .register ? 50 : 20)
                    .background(
                        ZStack {
                            if authType == .register {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.mainGreen.opacity(0.3), lineWidth: 0.5)
                                    .zIndex(1)
                            }
                            RoundedRectangle(cornerRadius: 15)
                                .fill(authType == .register ? Color.mainGreen : lightGray)
                                .zIndex(1)
                        }
                    )
            }
        }
        .background(
            lightGray
        )
        .cornerRadius(15)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
    }
}

struct BottomView: View {
    @Binding var authType: AuthType
    
    var body: some View {
        HStack(spacing: 3) {
            Text(authType == .login ? "Don't have an account?" : "Already have an account?")
                .font(.system(size: 15, weight: .medium))
            
            Button {
                if authType == .login {
                    withAnimation {
                        authType = .register
                    }
                }
                else {
                    withAnimation {
                        authType = .login
                    }
                }
            } label: {
                Text(authType == .login ? "Register" : "Login")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    AuthView()
}
