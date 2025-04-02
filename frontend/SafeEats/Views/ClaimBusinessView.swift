//
//  ClaimBusinessView.swift
//  SafeEats
//
//  Created by Ava Schrandt on 3/31/25.
//

import SwiftUI

struct BusinessClaimView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isCalling = false
    @State private var verificationCode = ""
    @State private var enteredCode = ""
    @State private var verificationSuccess = true

    let businessName: String
    let businessId: String

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack{
                    Text("Claim")
                        .font(.title)
                        .bold()
                    Text(businessName)
                        .font(.title)
                        .foregroundColor(Color.mainGreen)
                        .bold()
                }
                Text("Hi, NAME! To add \(businessName) to your profile, we must first verify you as the owner")
                    .font(.subheadline)
                    .bold()
                
                
                Text("\(Image(systemName:"phone.bubble.fill")) You will receive an automated call with a 6-digit verification code at the verified phone associated with \(businessName).\n\n\(Image(systemName:"number.circle.fill")) Please answer the call and then proceed to enter code given.\n\n\(Image(systemName:"checkmark.diamond.fill")) Hang up once you have successfully received and entered the code.")
                    .padding()
                
                if !isCalling {
                    Button("Ready for verification call") {
                        requestVerificationCall()
                    }
                    .frame(maxWidth: 345)
                    .padding(.vertical)
                    .foregroundStyle(.white)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
                    .background(Color.mainGreen)
                    .cornerRadius(15)
                    
                    .padding(.vertical, 12)
                } else {
                    Text("Calling... Please wait for the call.")
                        .foregroundColor(.gray)
                }
                
                if isCalling {
                    OTPVerificationView(isVerified: verificationSuccess)
                }
            }
            .blur(radius: verificationSuccess ? 9 : 0)
                
                // Full-Screen Success Popup
                if verificationSuccess {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        
                        Text("Verification Successful!")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Button(action: {
                            verificationSuccess = false
                        }) {
                            Text("Continue")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(.mainGreen)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                    .frame(width: 300, height: 300)
                    .background(Color.mainGreen)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .transition(.scale)
                }
            }
            .padding()
        
    }

    // Function to request a verification call
    func requestVerificationCall() {
        isCalling = true
        
    }

    // Function to verify the entered code
    func verifyCode() {
        
    }
}



struct OTPVerificationView: View {
    @State private var otp: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var showErrorAlert = false
    
   @State var isVerified: Bool

    var body: some View {
        ZStack {
            VStack {
                Text("Enter the 6-digit verification code")
                    .font(.headline)
                    .padding()

                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        TextField("", text: $otp[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40, height: 50)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.mainGreen, lineWidth: 1))
                            .font(.title)
                            .focused($focusedIndex, equals: index)
                            .onChange(of: otp[index]) { newValue in
                                handleInputChange(newValue, at: index)
                            }
                    }
                }
                .padding()
            }
             // Blur background when verified
        }
        .alert("Invalid Code", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The code you entered is incorrect. Please try again.")
        }
    }

    private func handleInputChange(_ newValue: String, at index: Int) {
        if newValue.count > 1 {
            otp[index] = String(newValue.prefix(1))
        }
        
        if !newValue.isEmpty && index < 5 {
            focusedIndex = index + 1
        }
        
        if otp.allSatisfy({ !$0.isEmpty }) {
            verifyCode()
        }
    }

    private func verifyCode() {
        let enteredCode = otp.joined()
        
        if enteredCode == "123456" { // Replace with real verification logic
            isVerified = true
        } else {
            showErrorAlert = true
            resetOTP()
        }
    }

    private func resetOTP() {
        otp = Array(repeating: "", count: 6)
        focusedIndex = 0
    }
}

struct OTPVerificationView2: View {
    @State private var otp: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Verification Code")
                .font(.title)
                .bold()

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $otp[index])
                        .frame(width: 50, height: 50)
                        .background(Color.mainGreen.opacity(0.2))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: index)
                        .onChange(of: otp[index]) { newValue in
                            if newValue.count > 1 {
                                otp[index] = String(newValue.prefix(1))
                            }
                            moveToNextField(from: index)
                        }
                }
            }

                    
            
        }
        .padding()
        .onAppear {
            focusedField = 0  // Auto-focus on first field
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.mainGreen)
        )
        
    }
    
    func moveToNextField(from index: Int) {
        if index < 5 && !otp[index].isEmpty {
            focusedField = index + 1
        }
        if otp.allSatisfy({ !$0.isEmpty }) {
                    verifyCode()
                }
    }
    
    func verifyCode() {
        let enteredCode = otp.joined()
        print("Verifying code: \(enteredCode)")
        // Send to backend for verification
    }
}



struct BusinessClaimView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessClaimView(businessName: "Sample Restaurant", businessId: "12345")
    }
}
