//
//  BusinessDetailView.swift
//  SafeEats
//
//  Created by Aditi Patel on 3/9/25.
//

import SwiftUI

struct BusinessDetailView: View {
    let business: Business
    @State private var showMapAlert = false
    @State private var showingCallConfirmation = false
    // temp variables
    //    let phonenumber: String? = "8124552066"
    let rating: Double = 4.5
    
    @State private var upvoteCount: Int = 10  // Replace with actual count
    @State private var downvoteCount: Int = 3  // Replace with actual count
    @State private var userVote: Int? = nil
    @State private var showCollectionPicker = false
    @StateObject private var viewModel = BusinessDetailViewModel()
    
    @State private var collections: [Collection] = UserDefaults.standard.object(forKey: "collections") as? [Collection] ?? []
    
    @State var bookmarked: Bool = false
    @State var collectionID: String? = nil
    
    func collectionsExcludingBusiness() -> [Collection] {
        for collection in $collections {
            if collection.name.wrappedValue == "Bookmarks" && collection.businesses.contains(where: { $0.businessId.wrappedValue == business.id }) {
                collectionID = collection.id.wrappedValue
                bookmarked = true
            }
        }
        return collections.filter { collection in
            collection.name != "Bookmarks" &&
            !collection.businesses.contains(where: { $0.businessId == business.id })
        }
    }
    //    let businessId = business.id
    @State private var selectedFilter: String = "Most Recent"
    @State private var showDropdown: Bool = false
    //    @Published var reviews: [Review] = []
    
    let filterOptions: [String] = ["Most Recent", "Least Recent", "Highest Rating", "Lowest Rating", "Most Popular", "Least Popular"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // header section
                    ZStack {
                        RoundedRectangle(cornerRadius: 27)
                            .fill(Color.mainGreen)
                            .frame(maxWidth: .infinity)
                            .padding([.leading, .trailing], 16)
                            .padding(.vertical, 8)
                        
                        // contact info section
                        VStack {
                            HStack {
                                Text(business.name ?? "No Name")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 15)
                                    .padding(.horizontal, 30)
                                    .fixedSize(horizontal: false, vertical: true)
                                Button(action: {
                                    Task {
                                        if bookmarked {
                                            bookmarked = false
                                            await viewModel.removeBookmark(collectionId: collectionID ?? "", businessId: business.id)
                                        } else {
                                            bookmarked = true
                                            await viewModel.bookmarkBusiness(businessID: business.id)
                                        }
                                    }
                                }) {
                                    Image(systemName: bookmarked ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                        .padding()
                                }
                            }
                            
                            
                            
                            // contact info section
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
                        ratingsSection
                        descriptionSection
                        menuSection
                        businessHoursSection
                        addressSection
                        socialMediaSection
                        
            
                    NavigationLink(
                                destination: BusinessSuggestionView(business: business))
                    {
                            Text("Make a Suggestion")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.mainGreen)
                                .cornerRadius(10)
                                .padding(.top, 10)
                        }
                        
                    }
                    .padding([.bottom, .horizontal], 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    reviewsSection
                    
                    //                Spacer()
                }
                .onAppear {
                    viewModel.fetchReviews(for: business.id)
                    if let data = UserDefaults.standard.data(forKey: "collections") {
                        let decoder = JSONDecoder()
                        if let loadedCollections = try? decoder.decode([Collection].self, from: data) {
                            print(loadedCollections)
                            collections = loadedCollections
                            // filter to only collections that don't have this id in their businesses field
                            collections = collectionsExcludingBusiness()
                        }
                    }
                    viewModel.updateAverageRating(businessId: business.id)
                }
                .task {
                    await viewModel.fetchBusinessData(businessID: business.id)
                }
                .padding(.top, 5)
            }
        }
    }
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Reviews")
                        .font(.title2)
                        .fontWeight(.semibold)
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
                Spacer()
                NavigationLink(destination: CreateReviewView(onReviewSubmitted: {
                    viewModel.updateAverageRating(businessId: business.id)
                    viewModel.fetchReviews(for: business.id)// Reload reviews after submission
                    
                }, businessId: business.id)) {
                    Text("Write a Review")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.mainGreen)
                        .cornerRadius(10)
                }
            }.padding(.bottom, 20)
            ForEach(viewModel.reviews, id: \.id) { review in
                ReviewCardView(review: review, viewModel: viewModel)
            }
        }
        .padding(.horizontal, 30)
    }
    
    
    
    // Extracted Review Card to simplify `reviewsSection`
    struct ReviewCardView: View {
        let review: Review
        @ObservedObject var viewModel: BusinessDetailViewModel
        @State private var userVote: Int? = nil
        // --- Report Sheet State ---
        @State private var showReportSheet = false
        @State private var selectedReasons: Set<String> = []
        @State private var otherReason: String = ""
        @AppStorage("username") private var currentUsername: String = ""
        
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
                    
                    // Review Content
                    Text(review.reviewContent)
                        .font(.body)
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    // Upvote / Downvote
                    HStack {
                        Button(action: { viewModel.upvoteReview(review.id) }) {
                            Image(systemName: review.userVote == 1 ? "arrow.up.circle.fill" : "arrow.up.circle")
                                .foregroundColor(review.userVote == 1 ? .mainGreen : .gray)
                                .font(.headline)
                        }
                        
                        Text("\(review.upvotes - review.downvotes)")
                            .font(.subheadline)
                        
                        Button(action: { viewModel.downvoteReview(review.id) }) {
                            Image(systemName: review.userVote == -1 ? "arrow.down.circle.fill" : "arrow.down.circle")
                                .foregroundColor(review.userVote == -1 ? .mainGreen : .gray)
                                .font(.headline)
                        }
                    }
                    .padding(.top, 3)
                    .padding(.bottom, 5)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
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
    }
    
    //        private func handleUpvote() {
    //            if userVote == 1 {
    //                upvoteCount -= 1
    //                userVote = nil
    //            } else if userVote == -1 {
    //                downvoteCount -= 1
    //                upvoteCount += 1
    //                userVote = 1
    //            } else {
    //                upvoteCount += 1
    //                userVote = 1
    //            }
    //        }
    //
    //        private func handleDownvote() {
    //            if userVote == -1 {
    //                downvoteCount -= 1
    //                userVote = nil
    //            } else if userVote == 1 {
    //                upvoteCount -= 1
    //                downvoteCount += 1
    //                userVote = -1
    //            } else {
    //                downvoteCount += 1
    //                userVote = -1
    //            }
    //        }
    
    //    private func formattedDate(from timestamp: Double) -> String {
    //        let date = Date(timeIntervalSince1970: timestamp)
    //        let formatter = DateFormatter()
    //        formatter.dateStyle = .medium
    //        return formatter.string(from: date)
    //    }
    var ratingsSection: some View {
        return HStack(alignment: .center, spacing: 5) {
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
            Button(action: {
                showCollectionPicker = true
                collections = collectionsExcludingBusiness()
            }) {
                Text("Add to Collection")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.mainGreen)
            .cornerRadius(10)
            .frame(width: 160, height: 80)
            .sheet(isPresented: $showCollectionPicker) {
                // Dummy UI for now; replace with your real collection picker view
                VStack {
                    Text("Choose a Collection")
                        .font(.title2)
                        .padding()
                    
                    //                    List {
                    //                        Text("Favorites")
                    //                        Text("Try Soon")
                    //                        Text("Top Vegan")
                    //                    }
                    
                    ForEach(collections, id: \.id) { collection in Button(action: {
                        Task {
                            await viewModel.addBusinessToCollection(collectionName: collection.name, businessID: business.id)
                            showCollectionPicker = false
                        }
                    }) {
                        Text(collection.name)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .frame(width: 380, height: 68)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                    }
                    
                    Button("Cancel") {
                        showCollectionPicker = false
                    }
                    .padding()
                }
                
            }
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
                if let menu = business.menu, let url = URL(string: menu) {
                    Link(destination: url) {
                        Label("Visit Menu", systemImage: "menucard.fill")
                    }
                    .foregroundColor(Color.mainGreen.darker())
                } else {
                    Text("No menu available.")
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
                                    .foregroundColor(.mainGreen)
                            }
                        }
                    } else {
                        Text("No business hours available.")
                            .font(.subheadline)
                            .foregroundColor(.mainGreen)
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
                           .foregroundColor(.mainGreen)
                   }
        }
    }
        var socialMediaSection: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Social Media")
                    .font(.title2)
                    .fontWeight(.semibold)
                if let social = business.social_media,
                   social.instagram != nil || social.twitter != nil || social.facebook_id != nil {
                    if let ig = social.instagram, let url = URL(string: "https://instagram.com/\(ig)") {
                        HStack {
                            Image("Instagram")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Link(destination: url) {
                                Text("@\(ig)")
                                    .foregroundColor(.mainGreen.darker())
                            }
                        }
                    }
                    if let tw = social.twitter, let url = URL(string: "https://twitter.com/\(tw)") {
                        HStack {
                            Image("Twitter")
                                .resizable()
                                .frame(width: 25, height: 25)
                            Link(destination: url) {
                                Text("@\(tw)")
                                    .foregroundColor(.mainGreen.darker())
                            }
                        }
                    }
                } else {
                    Text("No social media available.")
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
    
    //extension Business {
    //    static var sampleBusiness: Business {
    //        let jsonData = """
    //        {
    //            "name": "Tasty Bites",
    //            "website": "https://tastybites.com",
    //            "description": "Enjoy a warm, inviting atmosphere and delicious homemade meals at our cozy restaurant. We pride ourselves on quality ingredients and comforting flavors.",
    //            "cuisines": [1, 2],
    //            "menu": "https://tastybites.com/menu",
    //            "address": "123 Main St, New York, NY",
    //            "dietary_restrictions": [
    //                {"preference": "Vegan", "preference_type": "Diet"}
    //            ]
    //        }
    //        """.data(using: .utf8)!
    //
    //        let decoder = JSONDecoder()
    //        return try! decoder.decode(Business.self, from: jsonData)
    //    }
    //}
    
    
#Preview {
    BusinessDetailView(
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
            price: 0,
            hours: BusinessHours(  // << Add this
                            display: "Mon-Sun 10AM–9PM",
                            is_local_holiday: false,
                            open_now: true,
                            regular: []  // optional to fill out for now
                        )

        )
    )
}
