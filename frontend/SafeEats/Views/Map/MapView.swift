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
    
    /// Computed property that maps BusinessMapLocation to Business while retaining location data
    private var mappedBusinesses: [(BusinessMapLocation, Business)] {
        viewModel.businessesMap.compactMap { business in
            guard let id = business.id as? String else { return nil } // Ensure id exists
            let mappedBusiness = Business(
                id: id,
                name: business.name ?? "No Name",
                website: business.website ?? "No Website",
                description: business.description ?? "No description",
                cuisines: business.cuisines ?? [],
                menu: business.menu ?? "No menu",
                address: business.address ?? "No Address",
                dietary_restrictions: business.dietary_restrictions ?? []
            )
            return (business, mappedBusiness) // Tuple retains both BusinessMapLocation & Business
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map {
                    // User location radius
                    MapCircle(center: CLLocationCoordinate2D(latitude: viewModel.latitude, longitude: viewModel.longitude), radius: CLLocationDistance(viewModel.radius))
                        .foregroundStyle(.blue.opacity(0.2))
                    
                    // Specialized Markers for businesses
                    ForEach(mappedBusinesses, id: \.0.id) { (businessMapLocation: BusinessMapLocation, business: Business) in
                        let coordinate = CLLocationCoordinate2D(latitude: businessMapLocation.location.lat, longitude: businessMapLocation.location.lon)
                        
                        Annotation("", coordinate: coordinate) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.5))
                                    .frame(width: 25, height: 25)
                                    .onTapGesture {
                                        selectedBusinessId = business.id
                                    }
                                Image(systemName: "fork.knife.circle.fill")
                                    .foregroundColor(.black)
                                
                                if selectedBusinessId == business.id {
                                    ZStack(alignment: .topTrailing) { // Aligns button to the top-right
                                        CompactBusinessCard(business: business, rating: 4.5)
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
                    viewModel.searchBusinessesMap()
                }
            }

        }
    }
}

#Preview {
    MapView(viewModel: BusinessSearchViewModel())
}
