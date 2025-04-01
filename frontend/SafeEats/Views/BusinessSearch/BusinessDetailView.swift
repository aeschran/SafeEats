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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // header section
                ZStack {
                    RoundedRectangle(cornerRadius: 27)
                        .fill(Color.mainGreen)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .padding()
                    
                    VStack {
                        Text(business.name ?? "No Name")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 15)
                        
                        // contact info section
                        // TODO: add actual phone number of business
                        if let website = business.website, let url = URL(string: website),
//                           let phonenumber = phonenumber, !phonenumber.isEmpty
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
                        } else if let phonenumber = business.tel, !phonenumber.isEmpty /*phonenumber = phonenumber,  !phonenumber.isEmpty*/ {
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
                }
                
                VStack(alignment: .leading, spacing: 25) {
                    ratingsSection
                    descriptionSection
                    menuSection
                    addressSection
                }
                .padding([.bottom, .horizontal], 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.top, 5)
        }
    }
    
    
    private var ratingsSection: some View {
        HStack(alignment: .center, spacing: 5) {
            Text("\(String(format: "%.1f", rating))")
                .bold()
                .font(.title)
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 24))
            Text("(200+)")
                .font(.system(size: 24))
                .foregroundColor(.gray)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.title2)
                .fontWeight(.semibold)
            Text(business.description ?? "No description available.")
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var menuSection: some View {
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
    
    private var addressSection: some View {
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
    
    private func openInAppleMaps(address: String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }


    private func callPhoneNumber(phonenumber: String?) {
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
//    BusinessDetailView(business: Business.sampleBusiness)
}
