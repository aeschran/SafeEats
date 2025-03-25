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

enum AccountType {
    case userAccount
    case businessOwnerAccount
}

struct AuthView: View {
    // declare in all views
    
    @AppStorage("userType") var userType: String?
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var createProfileViewModel: CreateProfileViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    
    @AppStorage("id") var id_: String?
    @AppStorage("email") var email_: String?
    @AppStorage("username") var username_: String?
    @AppStorage("name") var name_: String?
    @AppStorage("phone") var phone_: String?
    @AppStorage("isVerified") var isVerified_: Bool?
    
    
    
    
    
    
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isPhoneNumberFocused: Bool
    @FocusState private var isUsernameFocused: Bool
    @State private var navigateToLanding = false
    @State private var navigateToCreateProfile = false
    @State private var resetPassword = false
    
    @State private var showPassword = false
    @State private var authType: AuthType = .login
    @State private var accountType: AccountType = .userAccount
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                let gradientColors: [Color] = accountType == .userAccount ? [.white, .mainGreen] : [.white, .mainGray]
                let padding = accountType == .userAccount ? 100 : 80
                Rectangle()
                    .fill(LinearGradient(colors: gradientColors, startPoint: UnitPoint(x: 0.5, y: 0.4), endPoint: .bottom))
                    .cornerRadius(20)
                    .ignoresSafeArea()
                
                VStack {
                    TopView(accountType: accountType)
                    SegmentedView(authType: $authType)
                    
                    VStack(spacing: 15) {
                        if authType == .register  || accountType == .businessOwnerAccount {
                            TextField(text: $viewModel.email) {
                                Text("Email")
                            }
                            .padding(.horizontal, 10)
                            .focused($isEmailFocused)
                            .textFieldStyle(AuthTextFieldStyle(isFocused: $isEmailFocused))}
                        
                        if authType == .register  || accountType == .userAccount {
                            TextField("Username", text: $viewModel.username) .padding(.horizontal, 10) .focused($isUsernameFocused) .textFieldStyle(AuthTextFieldStyle(isFocused: $isUsernameFocused))
                                .autocapitalization(.none)
                        }
                        
                        if authType == .register { TextField("Phone Number", text: $viewModel.phone) .padding(.horizontal, 10) .focused($isPhoneNumberFocused) .textFieldStyle(AuthTextFieldStyle(isFocused: $isPhoneNumberFocused)) }
                        
                        ZStack {
                            TextField("Password", text: $viewModel.password)
                                .padding(.horizontal, 10)
                                .autocapitalization(.none)
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
                            
                            SecureField(text: $viewModel.password) {
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
                    
                    if viewModel.errorMessage != nil {
                        Text(viewModel.errorMessage!)
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        Task {
                            if authType == .login && accountType == .businessOwnerAccount {
                                await viewModel.busines_owner_login()
                                userType = "Business"
                                
                            } else if authType == .register && accountType == .businessOwnerAccount {
                                await viewModel.business_owner_register()
                                userType = "Business"
                                
                            } else if authType == .login && accountType == .userAccount{
                                await viewModel.user_login()
                                userType = "User"
                                
                            } else if authType == .register && accountType == .userAccount{
                                
                                await viewModel.user_register()
                                userType = "User"
                                print("hi")
                                
                            }
                            //
                        }
                    } label: {
                        Text(authType == .login ? "Login" : "Register")
                    }
                    .buttonStyle(AuthButtonType())
                    .onChange(of: viewModel.isAuthenticated) {
                        if viewModel.isAuthenticated ?? false {
                            // Setting user object (after authentication is finsihed, why it's moved to here)
                            
                            
                            if let unwrappedID = viewModel.id_ {
                                print("ID: \(unwrappedID)")
                            } else {
                                print("ID is nil")
                            }
                            
                            
                            if viewModel.createdProfile == false {
                                navigateToCreateProfile = true
                            } else {
                                navigateToLanding = true
                            }
                        }
                        
                    }
                    
                    
                    BottomView(authType: $authType)
                        .onAppear {
                            navigateToCreateProfile = false
                            navigateToLanding = false
                            
                        }
                        .navigationDestination(isPresented: $navigateToCreateProfile) {
                            if navigateToCreateProfile { // Ensure it only goes to CreateProfile if isCreated is false
                                CreateProfileView().navigationBarBackButtonHidden(true)
                            } else {
                                LandingPage().navigationBarBackButtonHidden(true)
                            }
                        }
                    /*
                     
                     .navigationDestination(isPresented: $navigateToCreateProfile) {
                     CreateProfileView().navigationBarBackButtonHidden(true)
                     }
                     .navigationDestination(isPresented: $navigateToLanding) {
                     LandingPage().navigationBarBackButtonHidden(true)
                     }
                     */
                    //
                    //                        .navigationDestination(isPresented: $navigateToLanding) {
                    //                            LandingPage().navigationBarBackButtonHidden(true)
                    //                        }
                    if (authType == .login) {
                        Button {
                            resetPassword = true
                        } label: {
                            Text("Forgot Password?")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        // NavigationLink to ResetPasswordView
                        NavigationLink(
                            destination: ForgotPasswordView(accountType: accountType).navigationBarBackButtonHidden(true),
                            isActive: $resetPassword
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    }
                    
                    
                    Spacer()
                    Button {
                        //navigateToBusinessAuth = true
                        accountType = (accountType == .userAccount) ? .businessOwnerAccount : .userAccount
                    } label: {
                        Text(accountType == .userAccount ? "I'm a Business" : "Return to User Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                    }
                    
                    //                    NavigationLink("", destination: LandingPage(), isActive: $navigateToLanding)
                    //                        .navigationBarBackButtonHidden(true)
                }
                .padding(.top, CGFloat(padding))
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
        //        .navigationBarBackButtonHidden(true)
    }
    
    /*
     * Functions to verify user input
     */
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: email)
    }
    
    
    func isValidPhoneNumber() -> Bool {
        return phoneNumber.contains(/^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$/)
    }
    
    func isValidPassword() -> Bool {
        let passwordRegex = #"^(?=.*[a-z])(?=.*[A-Z])(?:(?=.*\d)|(?=.*[\W_])).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
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
            .font(.system(size: 20))
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
    var accountType: AccountType
    
    var body: some View {
        VStack(alignment: .center) {
            Image("SafeEats-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250)
                .padding(.top, -40)
            if accountType == .businessOwnerAccount {
                Text("SafeEats Business")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
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
        .environmentObject(AuthViewModel())
        .environmentObject(CreateProfileViewModel())
}
