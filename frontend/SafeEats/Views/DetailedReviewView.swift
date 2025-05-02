import SwiftUI

struct DetailedReviewView: View {
    var reviewId: String
    @State private var commentText: String = ""
    @StateObject private var viewModel = DetailedReviewViewModel()
    @AppStorage("userType") var userType: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let review = viewModel.review {
                    reviewHeader(review)
                    Divider()
                    commentSection(for: reviewId)
                } else {
                    ProgressView("Loading review...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.review?.businessName ?? "Loading...")
        .onAppear {
            Task {
                await viewModel.fetchDetailedReview(reviewID: reviewId)
                await viewModel.fetchComments(for: reviewId)
            }
        }
    }

    private func reviewHeader(_ review: DetailedReview) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(review.userName)
                    .font(.headline)
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

            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < review.rating ? "star.fill" : "star")
                        .foregroundColor(index < review.rating ? .yellow : .gray)
                }
            }

            if let meal = review.meal, !meal.isEmpty || (review.accommodations?.isEmpty == false) {
                VStack(alignment: .leading, spacing: 4) {
                    if !meal.isEmpty {
                        Text("Meal: \(meal)")
                            .font(.footnote)
                            .foregroundColor(.black)
                    }
                    if let accommodations = review.accommodations {
                        let formatted = accommodations.map {
                            $0.preferenceType == "Allergy" ? "\($0.preference) Free" : $0.preference
                        }.joined(separator: ", ")
                        Text("Accommodations: \(formatted)")
                            .font(.footnote)
                            .foregroundColor(.black)
                    }
                }
            }

            Text(review.reviewContent)
                .font(.body)

            if let image = review.decodedImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .cornerRadius(8)
            }

            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 28, height: 28)
                    Text("\(review.upvotes - review.downvotes)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
            .padding(.top, 3)
        }
    }

    private func commentSection(for reviewId: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comments")
                .font(.title3)
                .fontWeight(.semibold)

            if userType == "User" {
                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button {
                        Task {
                            await viewModel.postComment(reviewID: reviewId, commentContent: commentText, isBusiness: false)
                            commentText = ""
                            await viewModel.fetchComments(for: reviewId)
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.mainGreen)
                            .padding(.leading, 4)
                    }
                }
            }

            if viewModel.comments.isEmpty {
                Text("No comments yet.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                let businessComments = viewModel.comments.filter { $0.isBusiness }
                let userComments = viewModel.comments.filter { !$0.isBusiness }

                ForEach(businessComments, id: \.id) { comment in
                    commentCard(comment, isBusiness: true)
                }

                ForEach(userComments, id: \.id) { comment in
                    commentCard(comment, isBusiness: false)
                }
            }
        }
        .padding(.top, 12)
    }

    private func commentCard(_ comment: Comment, isBusiness: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(isBusiness ? "Business Owner" : comment.commenterUsername)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isBusiness ? .mainGreen.darker() : .primary)
                Spacer()
                if (comment.isTrusted) {
                    Text("Trusted Reviewer")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .italic(true)
                        .foregroundColor(.mainGreen)
                }


                if comment.commenterID == viewModel.id_ && (
                    (isBusiness && userType == "Business") ||
                    (!isBusiness && userType == "User")
                ) {
                    Button {
                        Task {
                            await viewModel.deleteComment(commentID: comment.id, isBusiness: isBusiness)
                            await viewModel.fetchComments(for: reviewId)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            HStack {
                
                Text(comment.commentContent)
                    .font(.body)
                    .foregroundColor(.black)
                Spacer()
                
                Text(formattedDate(from: comment.commentTimestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(isBusiness ? Color.mainGreen.opacity(0.15) : Color.gray.opacity(0.08))
        .cornerRadius(10)
    }

    private func formattedDate(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
