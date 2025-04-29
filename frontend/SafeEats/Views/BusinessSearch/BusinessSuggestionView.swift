import SwiftUI

struct BusinessSuggestionView: View {
    let business: Business
    @State private var suggestionText: String = ""
    @State private var selectedSuggestionType: String = "Menu Suggestion"
    @State private var topicText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var submissionSuccess: Bool = false
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notifViewModel = NotificationsViewModel()

    let suggestionTypes = ["Menu Suggestion", "Dietary Preference Suggestion", "Experience/Service Feedback", "Other"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("\(Image(systemName: "lightbulb.max.fill")) Suggest an Improvement")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 5)
                
                Text("Business: \(business.name ?? "Unknown Business")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Suggestion Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggestion Type")
                        .font(.headline)
                    
                    Menu {
                        ForEach(suggestionTypes, id: \.self) { type in
                            Button(action: { selectedSuggestionType = type }) {
                                Text(type)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedSuggestionType)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                // Optional Topic Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Topic (Optional)")
                        .font(.headline)
                    TextField("Enter a short topic", text: $topicText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Suggestion Text Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggestion")
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        if suggestionText.isEmpty {
                            Text("Write your suggestion here...")
                                .foregroundColor(.gray)
                                .padding(12)
                        }
                        
                        TextEditor(text: $suggestionText)
                            .padding(8)
                            .frame(height: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }
                }

                
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Button(action: submitSuggestion) {
                        Text("Submit Suggestion")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.mainGreen)
                            .cornerRadius(12)
                    }
                    .disabled(suggestionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("New Suggestion")
        .alert(isPresented: $submissionSuccess) {
            Alert(
                title: Text("Thank You!"),
                message: Text("Your suggestion was sent."),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
    }
    
    private func submitSuggestion() {
        guard !suggestionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSubmitting = true
        
        let formattedContent = """
        [\(selectedSuggestionType)] \(topicText.isEmpty ? "" : "\(topicText) - ")\(suggestionText)
        """
        
        Task {
            await notifViewModel.createNotification(
                recipientId: business.id,
                type: 2,
                content: formattedContent
            )
            isSubmitting = false
            submissionSuccess = true
        }
    }
}
