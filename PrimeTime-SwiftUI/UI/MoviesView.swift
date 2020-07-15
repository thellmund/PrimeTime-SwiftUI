//
//  MoviesView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct MoviesViewContainer: View {
	@EnvironmentObject private var historyStore: HistoryStore
	
	var filter: HomeFilter = .all
	
	var body: some View {
		MoviesView(dataSource: CombiningDataSource(createEndpoints()))
			.navigationBarTitle(filter.title)
	}
	
	private func createEndpoints() -> [Endpoint] {
		switch filter {
		case .all:
			return [.topRated()] + historyStore.liked.map { .recommendations(for: $0.id) }
		case .category(let category):
			var endpoint: Endpoint!
			switch category {
			case .nowPlaying:
				endpoint = .nowPlaying()
			case .upcoming:
				endpoint = .upcoming()
			case .genre(let genre):
				endpoint = .genreSamples(for: genre.id)
			}
			return [endpoint]
		}
	}
}

struct MoviesView: View {
	typealias RecommendationsDataSource = CombiningDataSource<MoviesResponse>
	
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@ObservedObject var dataSource: RecommendationsDataSource
	@State var detailsMovie: Movie?
	
	init(dataSource: RecommendationsDataSource) {
		self.dataSource = dataSource
	}
	
	var body: some View {
		LoadableView(from: dataSource.result) { movies in
			ScrollView {
				let columns = Array(repeatElement(GridItem(.flexible()), count: 2))
				LazyVGrid(columns: columns) {
					ForEach(movies.unique.sorted(by: \.popularity)) { movie in
						MovieCard(posterURL: movie.posterURL)
							.onTapGesture { detailsMovie = movie }
					}
				}.padding()
			}.sheet(item: $detailsMovie) { movie in
				MovieDetailsModalView(movie: movie)
					.environmentObject(historyStore)
					.environmentObject(watchlistStore)
			}
		}
	}
}

struct MovieDetailsModalView: View {
	var movie: Movie
	
	var body: some View {
		ScrollView {
			VStack(alignment: .center) {
				ModalHeader()
				MovieDetailsView(detailsDataSource: DataSource(endpoint: .movieDetails(for: movie.id)))
			}
		}
	}
}

struct MovieDetailsView: View {
	@Environment(\.presentationMode) private var presentationMode
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@ObservedObject private var imageFetcher = ImageFetcher(placeholder: .backdrop)
	@ObservedObject var detailsDataSource: DataSource<MovieDetails>
	
	@State private var watchState: WatchState = .notOnWatchlist
	
	var body: some View {
		LoadableView(from: detailsDataSource.result) { movie in
			VStack(alignment: .leading) {
				MovieDetailsHeader(url: movie.backdropURL)
				MovieDetailsTitle(movie: movie)
				
				WatchlistButton(
					watchState: watchState,
					imageFetcher: imageFetcher,
					action: { toggleWatchState(for: movie) }
				)
				
				MovieInformation(movie: movie)
				Divider()
				SimilarMovies(dataSource: DataSource(endpoint: .recommendations(for: movie.id)))
			}.onAppear {
				fetchBackdrop(for: movie)
				calculateWatchState(for: movie)
			}
		}
	}
	
	private func fetchBackdrop(for movie: MovieDetails) {
		guard let url = movie.backdropURL else { return }
		imageFetcher.fetch(url)
	}
	
	private func calculateWatchState(for movie: MovieDetails) {
		if historyStore.contains(movie) {
			watchState = .watched
		} else if watchlistStore.contains(movie) {
			watchState = .onWatchlist
		} else {
			watchState = .notOnWatchlist
		}
	}
	
	private func toggleWatchState(for movie: MovieDetails) {
		if watchlistStore.contains(movie) {
			watchlistStore.remove(movie)
			watchState = .notOnWatchlist
		} else {
			watchlistStore.add(movie)
			watchState = .onWatchlist
		}
	}
}

struct MovieDetailsTitle: View {
	var movie: MovieDetails
	
	@ViewBuilder
	var body: some View {
		let subtitle = [
			movie.formattedGenres,
			movie.formattedReleaseDate,
			movie.formattedRuntime
		].joined(separator: " ∙ ")
		
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				Text(movie.title)
					.font(.headline)
				Text(subtitle)
					.font(.callout)
					.opacity(0.7)
					.padding(.bottom, 4)
			}
			Spacer()
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal, Spacing.large)
		.padding(.vertical, Spacing.standard)
	}
}

struct MovieDetailsHeader: View {
	var url: URL?
	var body: some View {
		ZStack {
			URLImage(from: url, withPlaceholder: .backdrop)
				.aspectRatio(contentMode: .fit)
				.cornerRadius(Radius.corner)
				.overlay(RoundedRectangle(cornerRadius: Radius.corner).stroke(lineWidth: 0))
				.shadow(radius: Radius.shadow)
				.padding(.horizontal)
			
			Button(action: openTrailer) {
				Image(systemName: "play.fill")
					.resizable()
					.padding(Spacing.large)
					.foregroundColor(.white)
					.frame(width: 64, height: 64)
					.background(Color.black.opacity(0.5))
					.cornerRadius(100)
			}
		}
	}
	
	private func openTrailer() {
		if let url = URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0") {
			UIApplication.shared.open(url)
		}
	}
}

struct MovieInformation: View {
	var movie: MovieDetails
	var body: some View {
		VStack(alignment: .leading) {
			Text(movie.overview)
				.font(.body)
				.opacity(0.7)
				.padding(.horizontal, Spacing.large)
				.padding(.vertical, Spacing.standard)
		}
	}
}

struct SimilarMovies: View {
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@ObservedObject var dataSource: DataSource<MoviesResponse>
	@State private var similarMovie: Movie?
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("Similar movies")
				.font(.headline)
				.bold()
				.padding(.horizontal, Spacing.large)
				.padding(.top)
			
			LoadableView(from: dataSource.result) { response in
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: Spacing.standard) {
						ForEach(response.results, id: \.id) { movie in
							URLImage(from: movie.posterURL, withPlaceholder: .poster)
								.frame(width: 100, height: 150)
								.cornerRadius(Radius.corner)
								.onTapGesture { similarMovie = movie }
						}
					}.padding(Spacing.large)
				}
			}.frame(maxHeight: 150)
		}.sheet(item: $similarMovie) { movie in
			MovieDetailsModalView(movie: movie)
				.environmentObject(historyStore)
				.environmentObject(watchlistStore)
		}
	}
}

// MARK: - Previews

struct MovieDetailsView_Previews: PreviewProvider {
	static var previews: some View {
		MovieDetailsView(
			detailsDataSource: DataSource(endpoint: .movieDetails(for: 1))
		)
	}
}
