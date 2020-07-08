//
//  WatchlistView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct WatchlistView: View {
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@State private var editMode = EditMode.inactive
	
	@State var isShowingHistory: Bool = false
	@State var isShowingDialog: Bool = false
	@State var dialogMovie: Movie? = nil
	
	@ViewBuilder
	private var content: some View {
		if watchlistStore.movies.isEmpty {
			PlaceholderView(title: "No movies", subtitle: "Your watchlist is empty.")
		} else {
			ScrollView {
				LazyVStack {
					ForEach(watchlistStore.movies) { movie in
						WatchlistMovieRow(movie: movie)
					}.onDelete(perform: removeMovie)
				}.padding(Spacing.large)
			}
//			List {
//				ForEach(watchlistStore.movies) { movie in
//					WatchlistMovieRow(movie: movie)
//				}.onDelete(perform: removeMovie)
//			}
		}
	}
	
	@ViewBuilder
	private var trailingButton: some View {
		if watchlistStore.movies.isEmpty {
			EmptyView()
		} else {
			EditButton()
		}
	}
	
	var body: some View {
		NavigationView {
			content
				.navigationBarTitle(Text("Watchlist"))
				.navigationBarItems(
					leading: Button(action: openHistory) {
						Image(systemName: "list.bullet")
					},
					trailing: trailingButton
				)
				.environment(\.editMode, $editMode)
				.sheet(isPresented: $isShowingHistory) {
					HistoryView().environmentObject(self.historyStore).onDisappear {
						self.isShowingHistory = false
					}
				}
		}
	}
	
	private func removeMovie(offsets: IndexSet) {
		for index in Array(offsets) {
			watchlistStore.remove(at: index)
		}
	}
	
	private func openHistory() {
		isShowingHistory = true
	}
}

struct WatchlistMovieRow: View {
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@State var isShowingDialog: Bool = false
	
	var movie: Movie
	
	var body: some View {
		VStack {
			HStack {
				URLImage(from: movie.posterURL, withPlaceholder: .poster)
					.frame(width: 60, height: 90)
					.aspectRatio(contentMode: .fit)
					.cornerRadius(Radius.littleCorner)
					.shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 0)
					.border(Color.clear, width: 1)
					.padding(.vertical, Spacing.small)
					.padding(.trailing, Spacing.standard)
				
				VStack(alignment: .leading) {
					Text(movie.title).font(.headline)
					Text(movie.formattedGenres(genresStore)).lineLimit(2)
				}
				
				Spacer(minLength: Spacing.standard)
				
				Button(action: { self.isShowingDialog = true }) {
					HStack {
						Image(systemName: "checkmark")
						Text("Watched").bold()
					}.foregroundColor(.red)
				}
			}.actionSheet(isPresented: $isShowingDialog) {
				ActionSheet(
					title: Text("Rate \"\(movie.title)\""),
					buttons: [
						.default(Text("Show more like this")) {
							self.markWatched(withRating: .like)
						},
						.default(Text("Show less like this")) {
							self.markWatched(withRating: .dislike)
						},
						.cancel()
					]
				)
			}
			Divider()
		}
	}
	
	private func markWatched(withRating rating: Rating) {
		self.watchlistStore.remove(movie)
		self.historyStore.add(movie, withRating: rating)
	}
}

// MARK: - Previews

struct WatchlistView_Previews: PreviewProvider {
	static var previews: some View {
		WatchlistView()
	}
}

struct WatchlistMovieRow_Previews: PreviewProvider {
	static var previews: some View {
		WatchlistMovieRow(
			movie: Movie(
				id: 1,
				title: "The Social Network",
				posterPath: nil,
				backdropPath: nil,
				overview: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ",
				releaseDate: "08/24/2020",
				genreIds: [18],
				runtime: 123,
				popularity: 100.0,
				voteAverage: 9.0,
				voteCount: 1_234
			)
		)
	}
}
