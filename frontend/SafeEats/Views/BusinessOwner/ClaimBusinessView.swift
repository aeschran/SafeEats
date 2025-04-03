//
//  ClaimBusinessView.swift
//  SafeEats
//
//  Created by Aditi Patel on 3/31/25.
//

import SwiftUI

struct ClaimBusinessView: View {
    @StateObject private var viewModel = ClaimBusinessViewModel()
    @State private var isCreatingListing = false
    @State private var navigateToClaim = false
    @State private var selectedBusiness: Business?
        
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ClaimBusinessSearchBar(viewModel: viewModel)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if viewModel.businesses.isEmpty {
                    VStack {
                        Text("Didn't find your business?")
                            .font(.headline)
                            .padding()
                        
                        NavigationLink(destination: CreateListingView(), isActive: $isCreatingListing) {
                            Button("Create a New Listing") {
                                isCreatingListing = true
                            }
                            .padding()
                            .background(Color.mainGreen)
                            .cornerRadius(17)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        
                    }
                } else {
                    List(viewModel.businesses, id: \.name) { business in
                        VStack(spacing: 10) {
                            HStack {
                                NavigationLink(destination: BusinessDetailView(business: business)) {
                                    BusinessCard(
                                        business: business,
                                        rating: 4.5,
                                        imageName: "self.crop.circle.fill"
                                    )
                                }
                                Spacer()
                            }

                            Button("Claim") {
                                navigateToClaim = true
                                selectedBusiness = business
                                
                            }
                            .buttonStyle(AuthButtonType())
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listStyle(.inset)
                }
                                    
            }
            
        }
        .navigationTitle("Claim a Business")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $navigateToClaim) {
                        if let business = selectedBusiness {
                            VerifyClaimView(business: business, isPresented: $navigateToClaim)
                        } else {
                            Text("Loading...")
                        }
                    }
        .onAppear {
            viewModel.fetchSearchResults()
        }
    }
}

//struct ClaimBusinessSearchBar: View {
//    @ObservedObject var viewModel: ClaimBusinessViewModel
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//            TextField("Search for business...", text: $viewModel.query)
//                .onSubmit {
//                    viewModel.fetchSearchResults()
//                }
//        }
//        .padding(10)
//        .background(RoundedRectangle(cornerRadius: 10).fill(Color.mainGreen.opacity(0.1)))
//        .padding(.horizontal)
//    }
//}

// Helper function to truncate description
func truncatedDescription(for text: String, limit: Int = 100) -> String {
    if text.count > limit {
        let index = text.index(text.startIndex, offsetBy: limit)
        return text[..<index] + "..."
    }
    return text
}

struct VerifyClaimView: View {
    @StateObject private var viewModel = ClaimBusinessViewModel()
    @State private var isCalling = false
    @State private var verificationCode = ""
    @State private var enteredCode = ""
    @State private var verificationSuccess = false
    @State private var showErrorAlert = false
    

    @AppStorage("username") var username_: String?

    let business: Business
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    
                    Text("\(Image(systemName: "checkmark")) Claim")
                        .font(.title)
                        .bold()
                    Text(business.name ?? "")
                        .font(.title)
                        .foregroundColor(Color.mainGreen)
                        .lineLimit(nil)
                        .bold()
                }
                
                Text("Hi, \(username_ ?? "")! To add \(business.name ?? "") to your profile, we must first verify you as the owner.")
                    .font(.subheadline)
                    .bold()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)       // Ensures it uses the full width

                
                Text("\(Image(systemName: "phone.bubble.fill")) You will receive an automated call with a 6-digit verification code at the verified phone associated with \(business.name ?? "").\n\n\(Image(systemName: "number.circle.fill")) Please answer the call and then proceed to enter code given.\n\n\(Image(systemName: "checkmark.diamond.fill")) Hang up once you have successfully received and entered the code.")
                    
                    .padding()
                
                    
                
                if !isCalling {
                    Button("Ready for verification call") {
                        requestVerificationCall()
                    }
                    .frame(maxWidth: 345)
                    .padding(.vertical)
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .bold))
                    .background(Color.mainGreen)
                    .cornerRadius(15)
                    .padding(.vertical, 12)
                } else {
                    Text("Calling... Please wait for the call.")
                        .foregroundColor(.gray)
                }
                
                if isCalling {
                    OTPVerificationView(isVerified: $verificationSuccess, ownerId: viewModel.id_ ?? "", businessId: business.id)
                }
            }
            .blur(radius: verificationSuccess ? 9 : 0)
            
                VStack {
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        Spacer()
                    }
             
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            
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
                        isPresented = false // Dismiss the sheet
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
        .alert("Verifcation Not Available at This Time", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {
                isPresented = false
            }
        } message: {
            Text("Sorry, verification phone not provided for this business!")
        }
    }

    func requestVerificationCall() {
        isCalling = true
        viewModel.verifyBusinessOwner(businessPhone: business.tel ?? "") { success, error in
            if !success {
                showErrorAlert = true
            }
         }
    }
}



struct OTPVerificationView: View {
    @StateObject private var viewModel = ClaimBusinessViewModel()
    @State private var otp: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @State private var showErrorAlert = false
    
    @Binding var isVerified: Bool
    let ownerId: String
    let businessId: String

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
            viewModel.verifyPhoneCode(businessId: businessId, code: enteredCode) { success, error in
                if success {
                    isVerified = true
                } else {
                    showErrorAlert = true
                    resetOTP()
                }
            }
        }


    private func resetOTP() {
        otp = Array(repeating: "", count: 6)
        focusedIndex = 0
    }
}



#Preview {
    ClaimBusinessView()
}
