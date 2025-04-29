//
//  ReportUserView.swift
//  SafeEats
//
//  Created by Aditi Patel on 4/29/25.
//

import SwiftUI

struct ReportUserView: View {
    let friendId: String
    let username: String
    
    @State private var selectedReason: String = ""
    @State private var descriptionText: String = ""
    @State private var showConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @State private var reportContent: String = ""
    
    
    let reasons = [
        "Inappropriate behavior",
        "Spam or scam",
        "Harassment",
        "Fake account",
        "Other"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .center, spacing: 8) {
                    Text(username)
                        .font(.title2)
                        .padding(8)
                        .fontWeight(.semibold)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8) // You can use Rectangle() if you want sharp corners
                                .stroke(Color.mainGreen, lineWidth: 1)
                        )
                    
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
//                .padding(.bottom)
                
                Text("Please select a reason:")
                    .font(.headline)
                    .foregroundColor(Color.mainGreen.darker())
                
                
                ForEach(reasons, id: \.self) { reason in
                    HStack {
                        Image(systemName: selectedReason == reason ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(Color.mainGreen.darker())
                            .onTapGesture {
                                selectedReason = reason
                            }
                        Text(reason)
                            .onTapGesture {
                                selectedReason = reason
                            }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                
                Text("Additional Details (Optional)")
                    .font(.headline)
                    .foregroundColor(Color.mainGreen.darker())
                
                TextEditor(text: $descriptionText)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.mainGreen.darker().opacity(0.5), lineWidth: 1)
                    )
                
                Spacer()
                
                // TODO: - implement report user
                Button(action: {
                    reportContent = "\(selectedReason): \(descriptionText)"
                    showConfirmation = true
                }) {
                    Text("Submit Report")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainGreen)
                        .cornerRadius(8)
                }
                .padding(.bottom)
                .disabled(selectedReason.isEmpty)
                //            .opacity(selectedReason.isEmpty ? 0.5 : 1)
            }
            .padding()
            .navigationTitle("Report User")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text("Report Submitted"),
                    message: Text("Thank you for helping keep our community safe."),
                    dismissButton: .default(Text("OK")) {
                        dismiss() // <<< this will pop back to ProfileView
                    }
                )
            }
        }
    }
}


#Preview {
    ReportUserView(friendId: "34534536", username: "aditi2")
}
