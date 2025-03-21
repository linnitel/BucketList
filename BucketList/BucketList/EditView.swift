//
//  EditView.swift
//  BucketList
//
//  Created by Julia Martcenko on 21/03/2025.
//

import SwiftUI

struct EditView: View {
	enum LoadingState {
		case loding, loaded, failed
	}

	@Environment(\.dismiss) var dissmiss
	var location: Location

	@State private var name: String
	@State private var discription: String
	var onSave: (Location) -> Void

	@State private var loadingState: LoadingState = .loding
	@State private var pages = [Page]()

    var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Place name", text: $name)
					TextField("Description", text: $discription)
				}
				Section("Nearby...") {
					switch loadingState {
						case .loding:
							Text("Loading...")
						case .loaded:
							ForEach(pages, id: \.pageid) { page in
								Text(page.title)
									.font(.headline)
								+ Text(": ") +
								Text(page.description)
									.italic()
							}
						case .failed:
							Text("Please try again later")
					}
				}
			}
			.navigationTitle("Place details")
			.toolbar {
				Button("Save") {
					var newLocation = location
					newLocation.name = name
					newLocation.description = discription
					newLocation.id = UUID()
					onSave(newLocation)
					dissmiss()
				}
			}
			.task {
				await fetchNearbyPlaces()
			}
		}
    }

	init(location: Location, onSave: @escaping (Location) -> Void) {
		self.location = location
		self.onSave = onSave

		_name = State(initialValue: location.name)
		_discription = State(initialValue: location.description)
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

#Preview {
	EditView(location: .example) { _ in }
}
