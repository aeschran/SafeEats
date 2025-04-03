import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: BusinessSearchViewModel
    @State private var showFilters: Bool = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4237, longitude: -86.9212), // Default to Purdue University
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedBusinessId: String? = nil
    
    let cuisineRanges: [(range: ClosedRange<Int>, icon: String)] = [
        (13072...13072, "Asian"),      // Asian
        (13099...13132, "Asian"),    // Asian
        (13225...13233, "Asian"),     // Asian
        (13263...13285, "Asian"),   // Asian
        (13289...13295, "Asian"), // Asian
        (13236...13262, "Italian"),  // Italian
        (13303...13308, "Mexican"), // Mexican
        (13198...13224, "Indian") // Indian
    ]
    
    private func getBusiness(businessMap: BusinessMapLocation) -> Business {
        return Business(id: businessMap.id, name: businessMap.name, website: businessMap.website, description: businessMap.description, cuisines: businessMap.cuisines, menu: businessMap.menu, address: businessMap.address, dietary_restrictions: businessMap.dietary_restrictions, tel: businessMap.tel, avg_rating: businessMap.avg_rating)
    }
    
    func getCuisineIcon(for business: BusinessMapLocation) -> String {
        for cuisineNumber in business.cuisines {
            if let matchedCuisine = cuisineRanges.first(where: { $0.range.contains(cuisineNumber) }) {
                    return matchedCuisine.icon
            }
        }
        
        return "Food" // Fallback icon
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map {
                    // User location radius
                    MapCircle(center: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude), radius: CLLocationDistance(viewModel.radius * 1609))
                        .foregroundStyle(.blue.opacity(0.2))
                    
                    Annotation("Your Location", coordinate: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude))
                    { ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 15, height: 15)
                    }
                    }
                    
                    // Specialized Markers for businesses
                    ForEach(viewModel.businessesMap, id: \.id) { businessMapLocation in
                        let coordinate = CLLocationCoordinate2D(latitude: businessMapLocation.location.lat, longitude: businessMapLocation.location.lon)
                        let business = getBusiness(businessMap: businessMapLocation)
                        Annotation("", coordinate: coordinate) {
                            ZStack {
                                Circle()
                                    .fill(Color.mainGray.opacity(0.3))
                                    .frame(width: 25, height: 25)
                                    .onTapGesture {
                                        selectedBusinessId = business.id
                                    }
                                Image(getCuisineIcon(for: businessMapLocation))
                                    .foregroundColor(Color.black)
                                
                                if selectedBusinessId == business.id {
                                    ZStack(alignment: .topTrailing) { // Aligns button to the top-right
                                        CompactBusinessCard(business: business)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)

                                        Button(action: {
                                            selectedBusinessId = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title2) // Adjust size if needed
                                                .padding(4)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                        }
                    }
                }
                .mapControlVisibility(.hidden)
                .ignoresSafeArea()
                .onAppear {
                    viewModel.searchBusinessesMap() // Start fetching data
                }
                .onReceive(viewModel.$businessesMap) { _ in
                    DispatchQueue.main.async {
                        region = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showFilters.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3.decrease.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.mainGreen)
                                .padding(10)
                                .background(Color.mainGreen.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                }
                .sheet(isPresented: $showFilters) {
                    FilterMapView(selectedCuisines: $viewModel.selectedCuisines, selectedAllergies: $viewModel.selectedAllergies, selectedDietaryRestrictions: $viewModel.selectedDietaryRestrictions, radius: $viewModel.radius)
                        .presentationDetents([.medium, .large])
                        .padding(.top, 40)
                }
                .onChange(of: showFilters) { _, _ in
                    if showFilters == false {
                        viewModel.searchBusinessesMap()
                    }
                }
            }

        }
    }
}

#Preview {
    MapView(viewModel: BusinessSearchViewModel())
}
