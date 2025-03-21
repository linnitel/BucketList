//
//  ContentView.swift
//  BucketList
//
//  Created by Julia Martcenko on 21/03/2025.
//

import MapKit
import SwiftUI

struct ContentView: View {
	let startPosition = MapCameraPosition.region(
		MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
			span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
		)
	)

	@State private var viewModel = ViewModel()

	var body: some View {
		if viewModel.isUnlocked {
			MapReader { proxy in
				Map(initialPosition: startPosition) {
					ForEach(viewModel.locations) { location in
						Annotation(location.name, coordinate: location.coordinate) {
							Image(systemName: "star.circle")
								.resizable()
								.foregroundStyle(.red)
								.frame(width: 44, height: 44)
								.background(.white)
								.clipShape(.circle)
								.simultaneousGesture(LongPressGesture(minimumDuration: 1).onEnded {_ in
									viewModel.selectedPlace = location
								})
						}
					}
				}
				.mapStyle(viewModel.isHybrid ? .hybrid : .standard)
				.onTapGesture { position in
					if let coordinate = proxy.convert(position, from: .local) {
						viewModel.addLocation(at: coordinate)
					}
				}
				.sheet(item: $viewModel.selectedPlace) { place in
					EditView(location: place) {
						viewModel.updateLocation($0)
					}
				}
			}
			Button(viewModel.isHybrid ? "Standard" : "Hybrid") {
				viewModel.isHybrid.toggle()
			}
			.padding()
			.background(.blue)
			.foregroundStyle(.white)
			.clipShape(.capsule)
		} else {
			Button("Unlock places", action: viewModel.authenticate)
				.padding()
				.background(.blue)
				.foregroundStyle(.white)
				.clipShape(.capsule)
		}
	}
}

#Preview {
    ContentView()
}
