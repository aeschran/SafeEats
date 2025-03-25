//
//  MapView.swift
//  SafeEats
//
//  Created by Aditi Patel on 2/22/25.
//

import SwiftUI
import MapKit

struct PurdueLocation: Identifiable {
    let id = UUID()
    let coordinate = CLLocationCoordinate2D(latitude: 40.4237, longitude: -86.9212)
}

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4237, longitude: -86.9212), // Default to Purdue University
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: [PurdueLocation()]) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Text("Purdue University")
                                .font(.caption)
                                .padding(5)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(5)
                                .shadow(radius: 5)
                            
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    Text("Map Page")
                        .font(.title)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MapView()
}
