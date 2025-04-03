//
//  OwnerBusinessDetailView.swift
//  SafeEats
//
//  Created by harshini on 4/2/25.
//

import SwiftUI

struct OwnerBusinessDetailView: View {
    let business: Business
    @State private var showMapAlert = false
    @State private var showingCallConfirmation = false
    @State private var upvoteCount: Int = 10
    @State private var downvoteCount: Int = 3
    @State private var userVote: Int? = nil
    @StateObject private var viewModel = BusinessDetailViewModel()
    @StateObject private var ownerViewModel = OwnerBusinessDetailViewModel()
    @State private var selectedFilter: String = "Most Recent"
    @State private var showDropdown: Bool = false
    @State private var showPreferencePicker: Bool = false

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
                        .padding(.vertical, 15)
                    }

                    VStack(alignment: .leading, spacing: 25) {
                        ratingsSection
                        descriptionSection
                        menuSection
                        addressSection
                    }
                    .padding([.bottom, .horizontal], 30)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    reviewsSection
                }
                .onAppear {
                    viewModel.fetchReviews(for: business.id)
                    business.dietary_restrictions?.forEach { restriction in
                        if restriction.preference_type == "Dietary Restriction" {
                            ownerViewModel.dietPref.append(restriction.preference)
                        } else {
                            ownerViewModel.allergy.append(restriction.preference)
                        }
                        ownerViewModel.enabled[restriction.preference] = 1
                    }
                }
                .task {
                    await viewModel.fetchBusinessData(businessID: business.id)
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
        @State private var userVote: Int? = nil

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(review.userName) ")
                        .font(.headline)
                        .foregroundColor(.black)
                    Text("reviewed on \(formattedDate(from: review.reviewTimestamp))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .foregroundColor(index < review.rating ? .yellow : .gray)
                    }
                }

                Text(review.reviewContent)
                    .font(.body)
                    .foregroundColor(.black)
                    .lineLimit(2)
                HStack {
                    Text("votes: \(review.upvotes - review.downvotes)")
                        .font(.subheadline)
                }
                .padding(.top, 3)
                .padding(.bottom, 5)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
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

    var ratingsSection: some View {
        HStack(alignment: .center, spacing: 5) {
            if let avg_rating = viewModel.avg_rating {
                Text("\(String(format: "%.1f", avg_rating))")
                    .bold()
                    .font(.title)
            } else {
                ProgressView()
                    .font(.title)
            }

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

            Spacer()

            Button(action: {
                showPreferencePicker = true
            }) {
                Text("Edit Preferences Supported")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.mainGreen)
            .cornerRadius(10)
            .frame(width: 160, height: 100)
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

//#Preview {
//    OwnerBusinessDetailView(
//        business: Business(
//            id: "1",
//            name: "Test Business",
//            website: "https://example.com",
//            description: "Test description",
//            cuisines: [],
//            menu: nil,
//            address: "123 Test Street",
//            dietary_restrictions: []
//        )
//    )
//}
