//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Julia Martcenko on 21/03/2025.
//

import CoreLocation
import Foundation
import MapKit
import LocalAuthentication

extension ContentView {
	@Observable
	class ViewModel {
		private(set) var locations: [Location]
		var selectedPlace: Location?
		var isUnlocked = false
		var isHybrid = false
		var isAlertShown = false
		var alertMessage: String?

		let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")

		init() {
			do {
				let data = try Data(contentsOf: savePath)
				locations = try JSONDecoder().decode([Location].self, from: data)
			} catch {
				locations = []
			}
		}

		func save() {
			do {
				let data = try JSONEncoder().encode(locations)
				try data.write(to: savePath, options: [.atomic, .completeFileProtection])
			} catch {
				print("Unable to save data")
			}
		}

		func addLocation(at point: CLLocationCoordinate2D) {
			let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: point.latitude, longitude: point.longitude)
			locations.append(newLocation)
			save()
		}

		func updateLocation(_ location: Location) {
			guard let selectedPlace else { return }
			if let index = locations.firstIndex(of: selectedPlace) {
				locations[index] = location
				save()
			}
		}

		func authenticate() {
			let context = LAContext()
			var error: NSError?

			if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
				let reason = "Please authenticate yourself to unlock your places"

				context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { sucsess, authenticationError in
					if sucsess {
						self.isUnlocked = true
					} else {
						self.alertMessage = "Authentication failed because \(authenticationError?.localizedDescription ?? "")"
						self.isAlertShown = true
					}
				}
			} else {
				self.alertMessage = "\(error?.localizedDescription ?? "Authentication failed because this device doesn't support touch id")"
				self.isAlertShown = true
			}
		}
	}
}
