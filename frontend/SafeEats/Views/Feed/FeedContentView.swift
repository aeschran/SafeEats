import SwiftUI

struct FeedContentView: View {
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.reviews, id: \.reviewId) { review in
                    FriendReviewCard(review: review)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            viewModel.fetchFriendsReviews()
        }
    }
}

struct FriendReviewCard: View {
    var review: FriendReview

    var body: some View {
//        NavigationLink(destination: DetailedReviewView(review: review)) {
//            self // Wraps the entire `FriendReviewCard`
//
        NavigationLink(destination: DetailedReviewView(reviewId: review.id)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Title: "{user} reviewed {business}"
                    HStack(spacing: 0) {
                        Text("\(review.userName) reviewed ")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(review.businessName)
                            .font(.headline)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.tail) // Ensure it doesn't wrap too soon
                        /*.frame(maxWidth: .infinity, alignment: .leading)*/ // Extend as much as possible
                            .frame(maxWidth: 200, alignment: .leading)
                    }
                    
                    // Star Rating
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < review.rating ? "star.fill" : "star")
                                .foregroundColor(index < review.rating ? .yellow : .gray)
                        }
                    }
                    
                    // Review Content (Highlighted in black)
                    Text(review.reviewContent)
                        .font(.body)
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    // Timestamp
                    Text("Reviewed on \(formattedDate(from: review.reviewTimestamp))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
     // Prevents default button styling


    // Function to format timestamp
    private func formattedDate(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
