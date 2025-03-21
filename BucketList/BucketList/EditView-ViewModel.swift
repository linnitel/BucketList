//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Julia Martcenko on 21/03/2025.
//

import Foundation

extension EditView {

	@Observable
	class ViewModel {
		enum LoadingState {
			case loding, loaded, failed
		}

		var location: Location

		var name: String
		var discription: String

		private(set) var loadingState: LoadingState = .loding
		private(set) var pages = [Page]()

		init(location: Location) {
			self.location = location
			self.name = location.name
			self.discription = location.description
		}

		func fetchNearbyPlaces() async {
			let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
			guard let url = URL(string: urlString) else {
				print("Bad URL: \(urlString)")
				return
			}
			do {
				let (data, _) = try await URLSession.shared.data(from: url)
				let items = try JSONDecoder().decode(Result.self, from: data)
				pages = items.query.pages.values.sorted()
				loadingState = .loaded
			} catch {
				loadingState = .failed
			}
		}
	}
}
