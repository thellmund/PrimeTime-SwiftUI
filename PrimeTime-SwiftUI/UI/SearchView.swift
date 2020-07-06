//
//  SearchView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct SearchView: View {
	@Environment(\.presentationMode) private var presentationMode
	
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@State private var text: String = ""
	@State private var isShowingDetails: Bool = false
	@State private var detailsMovie: Movie!
	
	@ObservedObject var dataSource = DataSource<MoviesResponse>()
	
	var body: some View {
		VStack {
			SearchBarView(
				text: $text,
				onEnter: { self.dataSource.query(.search(self.text)) },
				onCancel: { self.presentationMode.wrappedValue.dismiss() }
			)
			LoadableView(from: dataSource.result) { response in
				if response.results.isEmpty {
					PlaceholderView(title: "No results", subtitle: "Well, that’s embarrasing…")
				} else {
					List(response.results) { movie in
						SearchResult(movie: movie)
							.onTapGesture {
								self.detailsMovie = movie
								self.isShowingDetails = true
						}
					}.sheet(isPresented: self.$isShowingDetails) {
						MovieDetailsModalView(movie: self.detailsMovie)
							.environmentObject(self.genresStore)
							.environmentObject(self.historyStore)
							.environmentObject(self.watchlistStore)
					}
				}
			}
			Spacer(minLength: 0)
		}
	}
}

struct SearchResult: View {
	var movie: Movie
	var body: some View {
		HStack {
			URLImage(from: movie.posterURL, withPlaceholder: .poster)
				.frame(width: 60, height: 90)
				.cornerRadius(8)
			VStack(alignment: .leading) {
				Text(movie.title).bold()
				Text(movie.overview).lineLimit(3).truncationMode(.tail)
			}.padding(.leading, Spacing.standard)
			Spacer(minLength: 0)
		}
	}
}

struct SearchBarView: UIViewRepresentable {
	
	@Binding var text: String
	
	var onEnter: () -> Void = {}
	var onCancel: () -> Void = {}
	
	class Coordinator: NSObject, UISearchBarDelegate {
		
		@Binding var text: String
		
		var onEnter: () -> Void = {}
		var onCancel: () -> Void
		
		init(text: Binding<String>, onEnter: @escaping () -> Void, onCancel: @escaping () -> Void) {
			_text = text
			self.onEnter = onEnter
			self.onCancel = onCancel
		}
		
		func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
			text = searchText
		}
		
		func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
			searchBar.setShowsCancelButton(true, animated: true)
		}
		
		func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
			searchBar.setShowsCancelButton(false, animated: true)
			onEnter()
			UIApplication.shared.endEditing()
		}
		
		func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
			// Hacky, hacky, hacky.
			text.removeAll()
			searchBar.setShowsCancelButton(false, animated: true)
			onCancel()
			UIApplication.shared.endEditing()
		}
	}
	
	func makeCoordinator() -> SearchBarView.Coordinator {
		return Coordinator(text: $text, onEnter: onEnter, onCancel: onCancel)
	}
	
	func makeUIView(context: UIViewRepresentableContext<SearchBarView>) -> UISearchBar {
		let searchBar = UISearchBar(frame: .zero)
		searchBar.tintColor = .red
		searchBar.delegate = context.coordinator
		searchBar.searchBarStyle = .minimal
		searchBar.autocapitalizationType = .sentences
		searchBar.placeholder = "Search…"
		return searchBar
	}
	
	func updateUIView(_ view: UISearchBar, context: UIViewRepresentableContext<SearchBarView>) {
		view.text = text
		view.setShowsCancelButton(text.isEmpty == false, animated: true)
	}
}

private extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
