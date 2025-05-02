//
//  BusinessDetailView.swift
//  SafeEats
//
//  Created by Aditi Patel on 3/9/25.
//

import SwiftUI
import Foundation

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
    @State private var isOpen = false
    @StateObject private var viewModel = BusinessDetailViewModel()
    @StateObject private var ocrViewModel = OCRViewModel()
    
    @State private var collections: [Collection] = UserDefaults.standard.object(forKey: "collections") as? [Collection] ?? []
    
    @State var bookmarked: Bool = false
    @State var collectionID: String? = nil
    @State var selectedFilters: [Accommodation: Bool] = [:]
    @State var presentedReviews: [Review] = []
    @State var hasMenu: Bool = false
    
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
    @State private var selectedPrefs: Set<String> = []
    //    @Published var reviews: [Review] = []
    
    let filterOptions: [String] = ["Most Recent", "Least Recent", "Highest Rating", "Lowest Rating", "Most Popular", "Least Popular"]
    
    let dietPrefs: [String] = ["Peanut", "Dairy", "Gluten", "Shellfish", "Vegan", "Vegetarian", "Halal", "Kosher"]
    
    func getPreferenceName(accommodation: Accommodation) -> String {
        return accommodation.preference
    }
    
    func updatePrefsAndFilter(prefs: Set<String>) {
        if (prefs.isEmpty) {
            print(viewModel.reviews)
            presentedReviews = viewModel.reviews
            return
        }
        presentedReviews = viewModel.reviews.filter { review in
            Set(prefs).isSubset(of: Set(review.accommodations?.map { accommodation in getPreferenceName(accommodation: accommodation)} ?? []))
        }
    }
    
    //    func updatePrefsAndFilterAcc(prefs: [Accommodation]) {
    //        var newPrefs: [String] = []
    //        print("before for loop: ", prefs)
    //        for (_, accommodation) in prefs.enumerated() {
    //            newPrefs.append(accommodation.preference)
    //        }
    //        selectedPrefs = newPrefs
    //        print(selectedPrefs)
    //        presentedReviews = viewModel.reviews.filter { review in
    //            Set(prefs.map(\.self)).isSubset(of: Set(review.accommodations?.map(\.self) ?? []))
    //        }
    //    }
    
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
                    .padding([.bottom, .horizontal], 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    //                    Divider()
                    reviewsSection
                    
                    //                Spacer()
                }
                .onAppear {
                    isOpen = isBusinessOpen(display: business.hours?.display ?? "Open Daily 9:00 AM-5:00 PM")
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
                    ocrViewModel.loadData(businessId: business.id) { success in
                        if success {
                            hasMenu = true
                        }
                    }
                }
                .task {
                    await viewModel.fetchBusinessData(businessID: business.id)
                    await viewModel.getUserPreferences()
                    await viewModel.fetchReviews(for: business.id)
                    print(viewModel.selectedPrefs)
                    selectedPrefs = viewModel.selectedPrefs
                    updatePrefsAndFilter(prefs: selectedPrefs)
                    
                }
                .padding(.top, 5)
            }
        }
    }
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ReviewsHeaderView(
                dietPrefs: dietPrefs,
                selectedPrefs: $viewModel.selectedPrefs,
                filterOptions: filterOptions,
                selectedFilter: $selectedFilter,
                viewModel: viewModel,
                updatePrefsAndFilter: { prefs in updatePrefsAndFilter(prefs: prefs) }
            )
            
            WriteReviewButtonView(
                businessId: business.id,
                viewModel: viewModel
            )
            
            if (presentedReviews.isEmpty) {
                Text("No reviews are available.")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(presentedReviews, id: \.id) { review in
                    ReviewCardView(review: review, viewModel: viewModel)
                }
                
            }
        }
        .padding(.horizontal, 30)
    }
    
    struct ReviewsHeaderView: View {
        let dietPrefs: [String]
        @Binding var selectedPrefs: Set<String>
        let filterOptions: [String]
        @Binding var selectedFilter: String
        let viewModel: BusinessDetailViewModel
        @State var showFilterPopover: Bool = false
        let updatePrefsAndFilter: (Set<String>) -> Void
        
        var body: some View {
            VStack(alignment: .center) {
                Text("Reviews")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer(minLength: 20)
                
                HStack {
                    FilterBySection(
                        selectedPrefs: $selectedPrefs,
                        showFilterPopover: $showFilterPopover,
                        dietPrefs: dietPrefs,
                        updatePrefsAndFilter: { prefs in
                            updatePrefsAndFilter(prefs)
                        }
                    )
                    
                    Spacer(minLength: 20)
                    
                    SortBySection(
                        selectedFilter: $selectedFilter,
                        filterOptions: filterOptions,
                        viewModel: viewModel
                    )
                }
            }
        }
    }
    
    struct FilterBySection: View {
        @Binding var selectedPrefs: Set<String>
        @Binding var showFilterPopover: Bool
        let dietPrefs: [String]
        let updatePrefsAndFilter: (Set<String>) -> Void
        
        var body: some View {
            VStack {
                Text("Filter By:")
                
                Button {
                    showFilterPopover = true
                } label: {
                    HStack {
                        Text(displayedFilterText)
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(6)
                    .shadow(radius: 1)
                }
                .popover(isPresented: $showFilterPopover) {
                    FilterPopover(
                        options: dietPrefs,
                        selected: $selectedPrefs,
                        isPresented: $showFilterPopover
                    )
                }
                .onChange(of: selectedPrefs) { _, _ in
                    updatePrefsAndFilter(selectedPrefs)
                }
            }
            .padding(.leading)
        }
        
        private var displayedFilterText: String {
            if selectedPrefs.isEmpty {
                return "Nothing"
            } else if selectedPrefs.count > 3 {
                return selectedPrefs.prefix(3).joined(separator: ", ") + "..."
            } else {
                return selectedPrefs.joined(separator: ", ")
            }
        }
    }
    
    struct SortBySection: View {
        @Binding var selectedFilter: String
        let filterOptions: [String]
        let viewModel: BusinessDetailViewModel
        
        var body: some View {
            VStack {
                Text("Sort By:")
                Menu {
                    ForEach(filterOptions, id: \.self) { option in
                        Button(option) {
                            selectedFilter = option
                            viewModel.sortReviews(by: option)
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
                    .frame(width: 130)
                }
            }
            .padding(.leading)
        }
    }
    
    struct WriteReviewButtonView: View {
        let businessId: String
        let viewModel: BusinessDetailViewModel
        
        var body: some View {
            NavigationLink(destination: CreateReviewView(
                onReviewSubmitted: {
                    Task {
                        viewModel.updateAverageRating(businessId: businessId)
                        await viewModel.fetchReviews(for: businessId)
                    }
                    
                },
                businessId: businessId
            )) {
                Text("Write a Review")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.mainGreen)
                    .cornerRadius(10)
                    .padding(.top, 10)
            }
        }
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
        
        @State private var commentContent: String = ""
        
        
        var body: some View {
            NavigationLink(destination: DetailedReviewView(reviewId: review.id)) {
                HStack {
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
                            } else {
                                //                            Text("No comments yet.")
                                //                                .font(.caption)
                                //                                .foregroundColor(.gray)
                                //                                .padding(.top, 5)
                            }
                            
                        }
                        
                        
                        
                    }
                    .frame(alignment: .leading)
                    Spacer()
                    
                    
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 2)
                .onAppear {
                    viewModel.fetchComments(for: review.id)
                }
                .frame(maxWidth: .infinity)
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
        
        var menuSection: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Official Menu")
                    .font(.title2)
                    .fontWeight(.semibold)
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
                } else {
                    Text("No official menu available.")
                }
                Spacer()
                Text("Uploaded Menu")
                    .font(.title3)
                    .fontWeight(.semibold)
                HStack {
                    if hasMenu {
                        NavigationLink(destination: AnnotatedMenu(official: false, businessId: business.id)) {
                            Label("View Annotated Menu", systemImage: "doc.text.magnifyingglass")
                        }
                        .foregroundColor(Color.mainGreen.darker())
                    } else {
                        Text("No uploaded menu available.")
                    }
                    NavigationLink(destination: MenuUploadView(isOfficial: false, businessId: business.id)) {
                        Text("Upload Menu")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.mainGreen)
                            .cornerRadius(10)
                    }
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
                                    .foregroundColor(.mainGreen.darker())
                            }
                        }
                        Spacer()
                        Text(isOpen ? "Open now" : "Closed")
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        //                            .background(isOpen ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .foregroundColor(isOpen ? .green : .red)
                            .cornerRadius(8)
                    } else {
                        Text("No business hours available.")
                        
                            .foregroundColor(.black)
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
                                    .foregroundColor(Color.mainGreen)
                                
                                    .frame(width: 30, height: 30)
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
    
    func isBusinessOpen(display: String) -> Bool {
        var now = Date()
        now = Calendar.current.date(byAdding: .hour, value: -4, to: now)! // Adjust to local timezone if needed

        let calendar = Calendar.current
        var today = calendar.startOfDay(for: Date())
//        today = calendar.date(byAdding: .hour, value: -4, to: today)!
        var nowComponents = calendar.dateComponents([.hour, .minute], from: now)
        var nowTime = calendar.date(bySettingHour: nowComponents.hour ?? 0, minute: nowComponents.minute ?? 0, second: 0, of: today)!
        // subtract a day
        nowTime = calendar.date(byAdding: .day, value: -1, to: nowTime)!

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = TimeZone.current

        if display.starts(with: "Open Daily") {
            let rangeString = display.replacingOccurrences(of: "Open Daily", with: "").trimmingCharacters(in: .whitespaces)
            let ranges = rangeString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

            for range in ranges {
                var newRange = range.replacingOccurrences(of: " - ", with: "-")
                let parts = newRange.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
                guard parts.count == 2,
                      let start = formatter.date(from: parts[0]),
                      let end = formatter.date(from: parts[1]) else { continue }

                let startComponents = calendar.dateComponents([.hour, .minute], from: start)
                let endComponents = calendar.dateComponents([.hour, .minute], from: end)

                var startTime = calendar.date(bySettingHour: calendar.component(.hour, from: start),
                                              minute: calendar.component(.minute, from: start),
                                              second: 0,
                                              of: today)!
                startTime = calendar.date(byAdding: .hour, value: -4, to: startTime)!
                var endTime = calendar.date(bySettingHour: calendar.component(.hour, from: end),
                                          minute: calendar.component(.minute, from: end),
                                          second: 0,
                                          of: today)!
                endTime = calendar.date(byAdding: .hour, value: -4, to: endTime)!


                if startTime <= endTime {
                    // Normal same-day range
                    if nowTime >= startTime && nowTime <= endTime {
                        return true
                    }
                } else {
                    // Wraparound (e.g., 11 PM - 2 AM)
                    if nowTime >= startTime || nowTime <= endTime {
                        return true
                    }
                }
            }

            return false
        }
        else {
            var nowComponents = calendar.dateComponents([.weekday, .hour, .minute], from: now)
            guard let weekday = nowComponents.weekday else { return false }

            let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

            // Normalize display string
            var newDisplay = display
                .replacingOccurrences(of: "Thurs", with: "Thu")
                .replacingOccurrences(of: "Thur", with: "Thu")
                .replacingOccurrences(of: "Weds", with: "Wed")
                .replacingOccurrences(of: "Tues", with: "Tue")
                .replacingOccurrences(of: " - ", with: "-")

            let rules = newDisplay.components(separatedBy: ";")

            for rule in rules {
                let trimmedRule = rule.trimmingCharacters(in: .whitespaces)
                let parts = trimmedRule.components(separatedBy: " ")
                guard parts.count >= 2 else { continue }

                let dayRangeStr = parts[0]
                let timesStr = parts[1...].joined(separator: " ")
                let individualTimeRanges = timesStr.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

                // --- Expand active days ---
                let dayParts = dayRangeStr.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                var activeDays: Set<String> = []

                for part in dayParts {
                    if part.contains("-") {
                        let bounds = part.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
                        if bounds.count == 2,
                           let startIndex = days.firstIndex(of: bounds[0]),
                           let endIndex = days.firstIndex(of: bounds[1]) {
                            let range = startIndex <= endIndex
                                ? Array(startIndex...endIndex)
                                : Array(startIndex..<7) + Array(0...endIndex)
                            activeDays.formUnion(range.map { days[$0] })
                        }
                    } else if days.contains(part) {
                        activeDays.insert(part)
                    }
                }

                let today = days[weekday % days.count]
                if activeDays.contains(today) {
                    for timeRange in individualTimeRanges {
                        let times = timeRange.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
                        if times.count != 2 { continue }

                        guard var start = formatter.date(from: times[0]),
                              var end = formatter.date(from: times[1]) else { continue }
                        
                        start = Calendar.current.date(byAdding: .hour, value: -4, to: start)!
                        end = Calendar.current.date(byAdding: .hour, value: -4, to: end)!

                        var startComponents = calendar.dateComponents([.hour, .minute], from: start)
                        var endComponents = calendar.dateComponents([.hour, .minute], from: end)
                        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
                        
                        var startTime = calendar.startOfDay(for: now)
                        startTime = calendar.date(byAdding: startComponents, to: startTime)!
                        var endTime = calendar.startOfDay(for: now)
                        endTime = calendar.date(byAdding: endComponents, to: endTime)!

                        if startTime <= endTime {
                            if nowTime >= startTime && nowTime <= endTime {
                                return true
                            }
                        } else {
                            // Overnight wrap
                            if nowTime >= startTime || nowTime <= endTime {
                                return true
                            }
                        }
                    }
                }
            }

            return false
        }
        
    }
}

struct FilterPopover: View {
    let options: [String]
    @Binding var selected: Set<String>
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Filters")
                .font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Toggle(isOn: Binding(
                            get: { selected.contains(option) },
                            set: { isOn in
                                if isOn {
                                    selected.insert(option)
                                } else {
                                    selected.remove(option)
                                }
                            }
                        )) {
                            Text(option)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                    }
                }
            }

            Spacer(minLength: 10)

            Button("Done") {
                isPresented = false
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.mainGreen)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(configuration.isOn ? .blue : .gray)
                configuration.label
            }
        }
        .buttonStyle(.plain)
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
