import SwiftUI

struct ForgotPasswordView: View {
    var accountType: AccountType
    @StateObject var resetPasswordViewModel: ResetPasswordViewModel
    
    @State private var email: String = ""
    @State private var code: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var step: Int = 1
    @State private var navigateToLogin = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showPassword = false
    
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isCodeFocused: Bool
    @FocusState private var isNewPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool
    
    
    
    init(accountType: AccountType) {
        self.accountType = accountType
        _resetPasswordViewModel = StateObject(wrappedValue: ResetPasswordViewModel(accountType: accountType))
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                let gradientColors: [Color] = [.white, .mainGreen]
                Rectangle()
                    .fill(LinearGradient(colors: gradientColors, startPoint: UnitPoint(x: 0.5, y: 0.4), endPoint: .bottom))
                    .cornerRadius(20)
                    .ignoresSafeArea()
                
                VStack (spacing: 20){
                    VStack(alignment: .center) {
                        Text("Reset Password")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        if accountType == .businessOwnerAccount {
                            Text("SafeEats Business")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                        }
                    }
                    
                    VStack(spacing: 15) {
                        if step == 1 {
                            enterEmailView
                        } else if step == 2 {
                            enterCodeView
                        } else {
                            enterNewPasswordView
                        }
                    }
                    .padding()
                    
                    
                    if resetPasswordViewModel.errorMessage != nil {
                        Text(resetPasswordViewModel.errorMessage!)
                            .foregroundColor(.red)
                    }
                    if resetPasswordViewModel.successMessage != nil {
                        Text(resetPasswordViewModel.successMessage!)
                            .foregroundColor(.green)
                    }
                    Button {
                        navigateToLogin = true
                    } label: {
                        Text("Return to Login")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            AuthView().navigationBarBackButtonHidden(true)
        }
        
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Success"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                navigateToLogin = true
            }))
        }
    }
    
    var enterEmailView: some View {
        VStack(spacing: 20) {
            Text("Enter your email to receive a reset code.")
                .multilineTextAlignment(.center)
            TextField("Email", text: $resetPasswordViewModel.email)
                .textFieldStyle(AuthTextFieldStyle(isFocused: $isEmailFocused))
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .focused($isEmailFocused)
            
            Button("Send Code") {
                Task {
                   await resetPasswordViewModel.sendResetCode()
                    if resetPasswordViewModel.validEmail {
                        
                            step = 2
                        
                    }
                }
                
                
            }
            .buttonStyle(AuthButtonType())
        }
    }
    
    var enterCodeView: some View {
        VStack(spacing: 20) {
            Text("Enter the reset code sent to your email.")
                .multilineTextAlignment(.center)
            TextField("Reset Code", text: $resetPasswordViewModel.verificationCode)
                .textFieldStyle(AuthTextFieldStyle(isFocused: $isCodeFocused))
                .keyboardType(.numberPad)
                .focused($isCodeFocused)
            
            Button("Verify Code") {
                Task {
                    await resetPasswordViewModel.verifyCode()
                    if resetPasswordViewModel.validCode{
                            step = 3
                    }

                }
                                
            }
            .buttonStyle(AuthButtonType())
        }
    }
    
    var enterNewPasswordView: some View {
        VStack(spacing: 20) {
            Text("Enter your new password.")
                .multilineTextAlignment(.center)
            
            ZStack {
                TextField("New Password", text: $resetPasswordViewModel.newPassword)
                    .padding(.horizontal, 10)
                    .autocapitalization(.none)
                    .focused($isNewPasswordFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isNewPasswordFocused))
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
                
                SecureField(text: $resetPasswordViewModel.newPassword) {
                    Text("New Password")
                }
                .padding(.horizontal, 10)
                .focused($isNewPasswordFocused)
                .textFieldStyle(AuthTextFieldStyle(isFocused: $isNewPasswordFocused))
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
            
            
            
            ZStack {
                TextField("Confirm Password", text: $resetPasswordViewModel.confirmPassword)
                    .padding(.horizontal, 10)
                    .autocapitalization(.none)
                    .focused($isConfirmPasswordFocused)
                    .textFieldStyle(AuthTextFieldStyle(isFocused: $isConfirmPasswordFocused))
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
                
                SecureField(text: $resetPasswordViewModel.confirmPassword) {
                    Text("Confirm Password")
                }
                .padding(.horizontal, 10)
                .focused($isConfirmPasswordFocused)
                .textFieldStyle(AuthTextFieldStyle(isFocused: $isConfirmPasswordFocused))
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
            
            Button("Reset Password") {
                Task {
                    await resetPasswordViewModel.resetPassword()
                    if resetPasswordViewModel.isReset {
                        alertMessage = "Your password has been successfully reset!"
                        showAlert = true
                    }
                }
                print("Password reset successfully")
            }
            .buttonStyle(AuthButtonType())
        }
    }
    
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(accountType: .businessOwnerAccount)
            .preferredColorScheme(.light)
    }
}

