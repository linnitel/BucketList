//
//  EditView.swift
//  BucketList
//
//  Created by Julia Martcenko on 21/03/2025.
//

import SwiftUI

struct EditView: View {
	@Environment(\.dismiss) var dissmiss
	
	var onSave: (Location) -> Void

	@State private var viewModel: ViewModel

    var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Place name", text: $viewModel.name)
					TextField("Description", text: $viewModel.discription)
				}
				Section("Nearby...") {
					switch viewModel.loadingState {
						case .loding:
							Text("Loading...")
						case .loaded:
							ForEach(viewModel.pages, id: \.pageid) { page in
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
					var newLocation = viewModel.location
					newLocation.name = viewModel.name
					newLocation.description = viewModel.discription
					newLocation.id = UUID()
					onSave(newLocation)
					dissmiss()
				}
			}
			.task {
				await viewModel.fetchNearbyPlaces()
			}
		}
    }

	init(location: Location, onSave: @escaping (Location) -> Void) {
		viewModel = ViewModel(location: location)
		self.onSave = onSave
	}


}

#Preview {
	EditView(location: .example) { _ in }
}
