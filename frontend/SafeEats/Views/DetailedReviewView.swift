//
//  DetailedReviewView.swift
//  SafeEats
//
//  Created by harshini on 4/3/25.
//

import SwiftUI

struct DetailedReviewView: View {
    var reviewId: String
    @State private var commentText: String = ""
    @StateObject private var viewModel = DetailedReviewViewModel()

    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let review = viewModel.review {
                    // Username + Date
                    HStack {
                        Text("\(review.userName)")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("Reviewed on \(formattedDate(from: review.reviewTimestamp))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if (review.trustedReview) {
                        Text("Trusted Reviewer")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .italic(true)
                            .foregroundColor(.mainGreen)
                    }
                    
                    // Star Rating
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < review.rating ? "star.fill" : "star")
                                .foregroundColor(index < review.rating ? .yellow : .gray)
                        }
                    }
                    
                    // Review Content
                    Text(review.reviewContent)
                        .font(.body)
                        .foregroundColor(.black)
                    
                    // Review Image (if available)
                    if let image = review.decodedImage() {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // Adjust width and height to make it smaller
                            .cornerRadius(10)
                    }
                    
                    // Upvote / Downvote
                    HStack(spacing: 0) {
//                        Image(systemName: "number.circle")
//                            .foregroundColor(.gray)
//                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray, lineWidth: 1) // Outline with gray color
                                .frame(width: 25, height: 25)// Adjust the size of the circle
                            
                            Text("\(review.upvotes - review.downvotes)") // Display vote count
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .minimumScaleFactor(0.5) // Allow the text to shrink if needed
                                .lineLimit(1) // Ensures the text is on a single line
                                .frame(maxWidth: 30, maxHeight: 30) // Ensures the text doesn't exceed the circle size
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 3)
                    .padding(.bottom, 5)
                    
                    Divider()
                    
                    // Comment Section
                    Text("Comments")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    // Comment Input
                    HStack {
                        TextField("Add a comment...", text: $commentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            // Handle comment submission
                            print("Submitting comment: \(commentText)")
                            commentText = "" // Clear text field after submitting
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.mainGreen)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Placeholder for Comments List (Replace with real data)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack {
                                Text("User123:")
                                    .font(.subheadline)
                                    .bold()
                                Text("This is a great review!")
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Spacer()
                } else {
                    ProgressView("Loading review...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .navigationTitle("\(viewModel.review?.businessName ?? "Loading...")")
        .onAppear {
            Task {
                await viewModel.fetchDetailedReview(reviewID: reviewId)
            }
        }
    }
    
    // Helper function for date formatting
    private func formattedDate(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
