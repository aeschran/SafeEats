//
//  OwnerBusinessDetailView.swift
//  SafeEats
//
//  Created by harshini on 4/2/25.
//

import SwiftUI

struct OwnerBusinessDetailView: View {
//    let business: Business
    @State var business: Business
    @State private var showMapAlert = false
    @State private var showingCallConfirmation = false
    @State private var upvoteCount: Int = 10
    @State private var downvoteCount: Int = 3
    @State private var userVote: Int? = nil
    @StateObject private var viewModel = BusinessDetailViewModel()
    @StateObject private var ownerViewModel = OwnerBusinessDetailViewModel()
    @StateObject private var ocrViewModel = OCRViewModel()
    @State private var selectedFilter: String = "Most Recent"
    @State private var showDropdown: Bool = false
    @State private var showPreferencePicker: Bool = false
    @State private var showEditListingSheet = false
    @State private var hasMenu = false


    let filterOptions: [String] = ["Most Recent", "Least Recent", "Highest Rating", "Lowest Rating", "Most Popular", "Least Popular"]
    let dietaryPreferences: [String] = ["Halal", "Kosher", "Vegetarian", "Vegan"]
    let allergies: [String] = ["Dairy", "Gluten", "Peanuts", "Shellfish"]
    
    @State var submitDietPref: [String] = []
    @State var submitAllergy: [String] = []

    @State private var enabled: [String: Int] = [
        "Halal": 0,
        "Kosher": 0,
        "Vegetarian": 0,
        "Vegan": 0,
        "Dairy": 0,
        "Gluten": 0,
        "Peanuts": 0,
        "Shellfish": 0
    ]
    
    func handleEnable(for preference: String) {
        ownerViewModel.enabled[preference] = ownerViewModel.enabled[preference] == 1 ? 0 : 1
        
        if dietaryPreferences.contains(preference) {
            if ownerViewModel.enabled[preference] == 1 {
                ownerViewModel.dietPref.append(preference)
            } else {
                let index = ownerViewModel.dietPref.firstIndex(of: preference)!
                ownerViewModel.dietPref.remove(at: index)
            }
        } else {
            if ownerViewModel.enabled[preference] == 1 {
                ownerViewModel.allergy.append(preference)
            } else {
                let index = ownerViewModel.allergy.firstIndex(of: preference)!
                ownerViewModel.allergy.remove(at: index)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 27)
                            .fill(Color.mainGreen)
                            .frame(maxWidth: .infinity)
                            .padding([.leading, .trailing], 16)
                            .padding(.vertical, 8)

                        VStack {
                            Text(business.name ?? "No Name")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.bottom, 15)
                                .fixedSize(horizontal: false, vertical: true)

                            if let website = business.website, let url = URL(string: website),
                               let phonenumber = business.tel, !phonenumber.isEmpty {
                                HStack(spacing: 10) {
                                    Link(destination: url) {
                                        HStack {
                                            Image(systemName: "globe")
                                            Text("Visit Website")
                                        }
                                    }
                                    Text("|")
                                    Button(action: {
                                        showingCallConfirmation = true
                                    }) {
                                        HStack {
                                            Image(systemName: "phone")
                                            Text(phonenumber)
                                        }
                                    }
                                }
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                                .confirmationDialog("Confirm Call", isPresented: $showingCallConfirmation, actions: {
                                    Button("Call \(phonenumber)") {
                                        callPhoneNumber(phonenumber: phonenumber)
                                    }
                                    Button("Cancel", role: .cancel) {}
                                })
                            } else if let website = business.website, let url = URL(string: website) {
                                HStack {
                                    Link(destination: url) {
                                        HStack {
                                            Image(systemName: "globe")
                                            Text("Visit Website")
                                        }
                                    }
                                    Text("|")
                                    Text("No contact info.")
                                }
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                            } else if let phonenumber = business.tel, !phonenumber.isEmpty {
                                HStack(spacing: 10) {
                                    Text("No website.")
                                    Text("|")
                                    Button(action: {
                                        showingCallConfirmation = true
                                    }) {
                                        HStack {
                                            Image(systemName: "phone")
                                            Text(phonenumber)
                                        }
                                    }
                                }
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                                .confirmationDialog("Confirm Call", isPresented: $showingCallConfirmation, actions: {
                                    Button("Call \(phonenumber)") {
                                        callPhoneNumber(phonenumber: phonenumber)
                                    }
                                    Button("Cancel", role: .cancel) {}
                                })
                            } else {
                                Text("No website or contact info available.")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .medium))
                            }
                        }
                        .padding(.vertical, 30)
                    }

                    VStack(alignment: .leading, spacing: 25) {
                        buttonSection
                        ratingsSection
                        descriptionSection
                        menuSection
                        businessHoursSection
                        addressSection
                        socialMediaSection
                    }
                    .padding([.bottom, .horizontal], 30)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    reviewsSection
                }
                .onAppear {
                    
                    business.dietary_restrictions?.forEach { restriction in
                        if restriction.preference_type == "Dietary Restriction" {
                            ownerViewModel.dietPref.append(restriction.preference)
                        } else {
                            ownerViewModel.allergy.append(restriction.preference)
                        }
                        ownerViewModel.enabled[restriction.preference] = 1
                    }
                    viewModel.updateAverageRating(businessId: business.id)
                    ocrViewModel.loadOfficialData(businessId: business.id) { success in
                        if success {
                            hasMenu = true
                        }
                    }
                }
                .task {
                    await viewModel.fetchBusinessData(businessID: business.id)
                    await viewModel.fetchReviews(for: business.id)
                }
                .padding(.top, 5)
                
            }
        }
    }

    var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Reviews")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Menu {
                    ForEach(filterOptions, id: \.self) { option in
                        Button(action: {
                            selectedFilter = option
                            viewModel.sortReviews(by: option)
                        }) {
                            Text(option)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedFilter)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(6)
                    .shadow(radius: 1)
                    .frame(width: 180)
                }
            }
            .padding(.bottom, 20)

            ForEach(viewModel.reviews, id: \.id) { review in
                ReviewCardView(review: review, viewModel: viewModel)
            }
        }
        .padding(.horizontal, 30)
    }

    struct ReviewCardView: View {
        let review: Review
        @ObservedObject var viewModel: BusinessDetailViewModel
        @AppStorage("id") var businessOwnerId: String?  // Your owner ID
        @State private var newReply: String = ""
        
        // --- Report Sheet State ---
        @State private var showReportSheet = false
        @State private var selectedReasons: Set<String> = []
        @State private var otherReason: String = ""
        @AppStorage("username") private var currentUsername: String = ""

        @State private var commentContent: String = ""

        
        var body: some View {
            NavigationLink(destination: DetailedReviewView(reviewId: review.id)) {
                VStack(alignment: .leading, spacing: 8) {
                    // Username + Date
                    HStack {
                        Text("\(review.userName) ")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("reviewed on \(formattedDate(from: review.reviewTimestamp))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Star Rating
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < review.rating ? "star.fill" : "star")
                                .foregroundColor(index < review.rating ? .yellow : .gray)
                        }
                        
                        if (currentUsername != review.userName) {
                            Button(action: { showReportSheet = true }) {
                                Image(systemName: "exclamationmark.bubble.fill")
                                    .foregroundColor(Color.customLightRed)
                                    .font(.headline)
                            }
                            .sheet(isPresented: $showReportSheet) {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Report Review")
                                        .font(.title2)
                                        .bold()
                                    Text("Select reasons for reporting:")
                                    
                                    ForEach(["Inappropriate", "Spam", "Off-topic", "Harassment"], id: \.self) { reason in
                                        Button(action: {
                                            if selectedReasons.contains(reason) {
                                                selectedReasons.remove(reason)
                                            } else {
                                                selectedReasons.insert(reason)
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: selectedReasons.contains(reason) ? "checkmark.square.fill" : "square")
                                                Text(reason)
                                            }
                                        }
                                        .foregroundColor(.primary)
                                    }
                                    
                                    TextField("Other (optional)", text: $otherReason)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    HStack {
                                        Button("Cancel") {
                                            showReportSheet = false
                                        }
                                        Spacer()
                                        Button("Submit") {
                                            var message = selectedReasons.joined(separator: ", ")
                                            if !otherReason.isEmpty {
                                                message += (message.isEmpty ? "" : ", ") + otherReason
                                            }
                                            
                                            Task {
                                                let userName = UserDefaults.standard.string(forKey: "username") ?? "Anonymous"
                                                await viewModel.reportReview(userName: userName, reviewId: review.id, message: message)
                                            }
                                            showReportSheet = false
                                        }
                                    }
                                    .padding(.top, 10)
                                }
                                .padding()
                            }
                        }
                    }
                    if let meal = review.meal, !meal.isEmpty || (review.accommodations != nil && !review.accommodations!.isEmpty) {
                        if let meal = review.meal, !meal.isEmpty || (review.accommodations != nil && !(review.accommodations ?? []).isEmpty) {
                            Text(formattedMealAndAccommodations(meal: review.meal, accommodations: review.accommodations))
                                .font(.footnote)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                                .fontWeight(.light)
                        }
                        
                    }
                    
                    
                    // Review Content
                    Text(review.reviewContent)
                        .font(.body)
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    // Upvote / Downvote
                    HStack {
//                        Button(action: { viewModel.upvoteReview(review.id) }) {
//                            Image(systemName: review.userVote == 1 ? "arrow.up.circle.fill" : "arrow.up.circle")
//                                .foregroundColor(review.userVote == 1 ? .mainGreen : .gray)
//                                .font(.headline)
//                        }
                        
                        Text("votes: \(review.upvotes - review.downvotes)")
                            .font(.subheadline)
                        
//                        Button(action: { viewModel.downvoteReview(review.id) }) {
//                            Image(systemName: review.userVote == -1 ? "arrow.down.circle.fill" : "arrow.down.circle")
//                                .foregroundColor(review.userVote == -1 ? .mainGreen : .gray)
//                                .font(.headline)
//                        }
                    }
                    .padding(.top, 3)
                    .padding(.bottom, 5)
                    if let reviewComments = viewModel.comments[review.id] {
                        // Filter only business comments
                        
                        let businessComments = reviewComments.filter { $0.isBusiness }
                        
                        if !businessComments.isEmpty {
                            Divider()
                            
                            ForEach(businessComments) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Business Owner")
                                        .font(.caption)
                                        .foregroundColor(.mainGreen.darker())
                                        .bold()
                                    
                                    Text(comment.commentContent)
                                        .font(.body)
                                        .foregroundColor(.black)
                                }
                                .padding(10)
                                .background(Color.mainGreen.opacity(0.15))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    if let ownerId = businessOwnerId {
                        HStack {
                            TextField("Reply to this review...", text: $newReply)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                viewModel.postBusinessReply(to: review.id, content: newReply, ownerId: ownerId)
                                newReply = ""
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.mainGreen)
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .onAppear {
                    viewModel.fetchComments(for: review.id)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
            
            // Helper function for date formatting
            private func formattedDate(from timestamp: Double) -> String {
                let date = Date(timeIntervalSince1970: timestamp)
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                return formatter.string(from: date)
            }
            private func formattedMealAndAccommodations(meal: String?, accommodations: [Accommodation]?) -> String {
                var parts: [String] = []
                
                if let meal = meal, !meal.isEmpty {
                    parts.append(meal)
                }
                
                if let accommodations = accommodations, !accommodations.isEmpty {
                    let formattedAccommodations = accommodations.map { accom in
                        accom.preferenceType == "Allergy" ? "\(accom.preference) Free" : accom.preference
                    }.joined(separator: ", ")
                    parts.append(formattedAccommodations)
                }
                
                return parts.joined(separator: " | ")
            }
        
    }

    
    var buttonSection: some View {
        HStack(spacing: 10) {
            Button(action: {
                showPreferencePicker = true
            }) {
                Text("Edit Preferences")
            }
            .font(.headline)
            .foregroundColor(.black)
            .padding()
            .background(Color.mainGray)
            .cornerRadius(10)
            .sheet(isPresented: $showPreferencePicker) {
                VStack {
                    Text("Select Preferences")
                        .font(.title2)
                        .padding()
                    
                    Text("Dietary Preferences")
                        .font(.body)
                    Divider()
                        .frame(width:200)
                    ForEach(dietaryPreferences, id: \.self) { preference in
                        HStack {
                            Image(systemName: ownerViewModel.enabled[preference] == 1 ? "checkmark.square" : "square")
                                .foregroundColor(.gray)
                                .opacity(1)
                                .frame(width: 24, height: 24)
                            Text(preference)
                                .font(.body)
                        }
                        .onTapGesture {
                            handleEnable(for: preference)
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("")
                        .padding()
                    
                    Text("Allergies")
                    Divider()
                        .frame(width:200)
                    ForEach(allergies, id: \.self) { preference in
                        HStack {
                            Image(systemName: ownerViewModel.enabled[preference] == 1 ? "checkmark.square" : "square")
                                .foregroundColor(.gray)
                                .opacity(1)
                                .frame(width: 24, height: 24)
                            Text(preference)
                                .font(.body)
                        }
                        .onTapGesture {
                            handleEnable(for: preference)
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("")
                        .padding()
                    
                    Button(action: {
                        Task {
                            await ownerViewModel.addPreferencesToBusiness(businessID: business.id)
                            showPreferencePicker = false
                        }
                    }) {
                        Text("Save")
                    }
                    
                    Button("Cancel") {
                        submitDietPref.removeAll()
                        submitAllergy.removeAll()
                        for (key, _) in enabled {
                            enabled[key] = 0
                        }
                        showPreferencePicker = false
                    }
                    .padding()
                }
            }
            
            // edit business details
            Button(action: {
                showEditListingSheet = true
            }) {
                Text("Edit Business")
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mainGray)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showEditListingSheet) {
                EditListingView(
                    businessId: business.id,
                    viewModel: ownerViewModel,
                    onSave: {
                        Task {
                            await ownerViewModel.getBusinessInformation(businessId: business.id)
                            if let updated = ownerViewModel.business {
                                business = updated
                            }
                        }
                    }
                )
            }
        }
    }

    var ratingsSection: some View {
        HStack(alignment: .center, spacing: 5) {
            if let avg_rating = viewModel.avg_rating {
                if avg_rating == 0.0 {
                    Text("No reviews")
                        .bold()
                        .font(.title2)
                } else {
                    Text("\(String(format: "%.1f", avg_rating))")
                        .bold()
                        .font(.title)
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 24))
                    if let totalReviews = viewModel.total_reviews {
                        Text("(\(totalReviews))")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .font(.system(size: 24))
                    }
                }
            } else {
                ProgressView()
                    .font(.title)
            }
            let business_price = priceToDollarSigns(business.price)
            if business_price != "No price" {
                Text("•")
                Text(business_price)
                    .font(.system(size: 24))
            }
            Spacer()
        }
    }

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.title2)
                .fontWeight(.semibold)
            Text(business.description ?? "No description available.")
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var menuSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Menu")
                .font(.title2)
                .fontWeight(.semibold)
            HStack {
                if let menu = business.menu, let url = URL(string: menu) {
                    if menu.contains("safeeatsbucket1.s3.amazonaws.com/menus/") {
                        NavigationLink(destination: AnnotatedMenu(official: true, businessId: business.id)) {
                            Label("View Uploaded Menu", systemImage: "menucard")
                        }
                        .foregroundColor(Color.mainGreen.darker())
                    } else {
                        Link(destination: url) {
                            Label("Visit Menu", systemImage: "menucard.fill")
                        }
                        .foregroundColor(Color.mainGreen.darker())
                    }
                } else if hasMenu {
                    NavigationLink(destination: AnnotatedMenu(official: true, businessId: business.id)) {
                        Label("View Uploaded Menu", systemImage: "menucard")
                    }
                    .foregroundColor(Color.mainGreen.darker())
                } else {
                    Text("No menu available.")
                }
                NavigationLink(destination: OfficialMenuUploadView(isOfficial: true, businessId: business.id)) {
                    Text("Upload Menu")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.mainGreen)
                        .cornerRadius(10)
                }
            }
        }
    }

    var addressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Address")
                .font(.title2)
                .fontWeight(.semibold)
            if let address = business.address {
                Button(action: { showMapAlert = true }) {
                    Label(address, systemImage: "map")
                        .foregroundColor(Color.mainGreen.darker())
                }
                .buttonStyle(.plain)
                .confirmationDialog("Open in Maps", isPresented: $showMapAlert) {
                    Button("Open in Maps") { openInAppleMaps(address: address) }
                    Button("Cancel", role: .cancel) {}
                }
            } else {
                Text("No address available.")
                    .foregroundColor(Color.mainGreen)
            }
        }
    }
    
    var businessHoursSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Business Hours")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let hours = business.hours {
                HStack(alignment: .top) { // <- align top because now it might be multiple lines
                    if let display = hours.display {
                        let lines = display.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(lines, id: \.self) { line in
                                Text(line)
                                    .font(.body)
                                    .foregroundColor(.mainGreen.darker())
                            }
                        }
                    } else {
                        Text("No business hours available.")
                            
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    if let isOpen = hours.open_now {
                        Text(isOpen ? "Open now" : "Closed")
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
//                            .background(isOpen ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .foregroundColor(isOpen ? .green : .red)
                            .cornerRadius(8)
                    }
                }

                   } else {
                       Text("No business hours available")
                           .foregroundColor(.black)
                   }
        }
    }
    
    var socialMediaSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Social Media")
                .font(.title2)
                .fontWeight(.semibold)
            HStack(spacing: 20) {
                if let social = business.social_media,
                   social.instagram != nil || social.twitter != nil || social.facebook_id != nil {
                    if let ig = social.instagram, let url = URL(string: "https://instagram.com/\(ig)") {
                        HStack {
                            Link(destination: url) {
                                Image("Instagram")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    
                                    .foregroundColor(Color.mainGreen)
                            }
                        }
                    }
                    if let tw = social.twitter, let url = URL(string: "https://twitter.com/\(tw)") {
                        HStack {
                            Link(destination: url) {
                                Image("Twitter")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundColor(Color.mainGreen)
                                    
                                    .frame(width: 26, height: 26)
                            }
                        }
                    }
                    if let fb = social.facebook_id, let url = URL(string: "https://facebook.com/\(fb)") {
                        HStack {
                            
                            Link(destination: url) {
                                Image("Facebook")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundColor(Color.mainGreen)
                                    
                                    .frame(width: 25, height: 25)
                            }
                        }
                    }
                } else {
                    Text("No social media available.")
                }
            }
        }
    }
    
    func openInAppleMaps(address: String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }

    func callPhoneNumber(phonenumber: String?) {
        if let phonenumber = phonenumber {
            let sanitizedPhoneNumber = phonenumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(sanitizedPhoneNumber)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Invalid phone number: \(phonenumber)")
            }
        }
    }
}

#Preview {
    OwnerBusinessDetailView(
        business: Business(
            id: "67efeeecadf19975370af524",
            name: "Test Business",
            website: "https://example.com",
            description: "Test description",
            cuisines: [],
            menu: nil,
            address: "123 Test Street",
            dietary_restrictions: [],
            tel: "1234567890",
            avg_rating: 4.5,
            social_media: SocialMedia(
                facebook_id: "test_fb",
                instagram: "test_ig",
                twitter: "test_tw"
            ),
            price: 1,
            hours: BusinessHours(  // << Add this
                display: "Mon-Sun 10AM–9PM",
                is_local_holiday: false,
                open_now: true,
                regular: []  // optional to fill out for now
            )
        )
    )
}
