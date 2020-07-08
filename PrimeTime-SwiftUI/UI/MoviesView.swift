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
			let movies = historyStore.liked
			return [.topRated()] + movies.map { Endpoint.recommendations(for: $0.id) }
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
	
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@ObservedObject var dataSource: RecommendationsDataSource
	@State var movie: Movie?
	
	init(dataSource: RecommendationsDataSource) {
		self.dataSource = dataSource
	}
	
	var body: some View {
		LoadableView(from: dataSource.result) { movies in
			ScrollView {
				LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
					ForEach(movies.sorted(by: \.popularity)) { movie in
						MovieCard(movie: movie)
							.onTapGesture { self.movie = movie }
					}
				}.padding()
			}.sheet(item: $movie) { movie in
				MovieDetailsModalView(movie: movie)
					.environmentObject(self.historyStore)
					.environmentObject(self.genresStore)
					.environmentObject(self.watchlistStore)
			}
		}
	}
}

struct MovieDetailsModalView: View {
	@EnvironmentObject var genresStore: GenresStore
	@EnvironmentObject var historyStore: HistoryStore
	
	var movie: Movie
	
	var body: some View {
		ScrollView {
			VStack(alignment: .center) {
				ModalHeader()
				MovieDetailsView(movie: movie)
			}
		}
	}
}

struct MovieDetailsView: View {
	@Environment(\.presentationMode) private var presentationMode
	
	@EnvironmentObject var genresStore: GenresStore
	@EnvironmentObject var historyStore: HistoryStore
	@EnvironmentObject var watchlistStore: WatchlistStore
	
	@ObservedObject var similarMoviesDataSource = DataSource<MoviesResponse>()
	@ObservedObject var imageFetcher = ImageFetcher(placeholder: .backdrop)
	
	@State private var similarMovie: Movie?
	
	var movie: Movie
	
	var body: some View {
		VStack(alignment: .leading) {
			ZStack {
				LoadableImage(image: imageFetcher.image, placeholder: .backdrop)
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
			
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text(movie.title)
						.font(.headline)
					Text(movie.formattedGenres(genresStore))
						.font(.callout)
						.opacity(0.7)
						.padding(.bottom, 4)
				}
				Spacer()
			}
			.frame(maxWidth: .infinity)
			.padding(.horizontal, Spacing.large)
			.padding(.vertical, Spacing.standard)
			
			WatchlistButton(movie: movie, backdropColor: imageFetcher.image?.averageColor)
			
			Text(movie.overview)
				.font(.body)
				.opacity(0.7)
				.padding(.horizontal, Spacing.large)
				.padding(.vertical, Spacing.standard)
			
			Divider()
			
			HStack(alignment: .center) {
				VStack(alignment: .center) {
					Text(movie.releaseYear).font(.body)
					Text("Release").font(.callout).opacity(0.7)
				}.frame(maxWidth: .infinity)
				
				VStack(alignment: .center) {
					Text(movie.formattedRuntime).font(.body)
					Text("Duration").font(.callout).opacity(0.7)
				}.frame(maxWidth: .infinity)
				
				VStack(alignment: .center) {
					Text(movie.formattedVoteAverage).font(.body)
					Text(movie.formattedVoteCount).font(.callout).opacity(0.7)
				}.frame(maxWidth: .infinity)
			}
			.padding(.horizontal, Spacing.large)
			.padding(.vertical, Spacing.standard)
			
			Divider()
			
			Text("Similar movies")
				.font(.headline)
				.bold()
				.padding(.horizontal, Spacing.large)
			
			LoadableView(from: similarMoviesDataSource.result) { response in
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: Spacing.standard) {
						ForEach(response.results, id: \.id) { movie in
							URLImage(from: movie.posterURL, withPlaceholder: .poster)
								.frame(width: 100, height: 150)
								.cornerRadius(Radius.corner)
								.onTapGesture { self.similarMovie = movie }
						}
					}
					.padding(.horizontal, Spacing.large)
				}
			}.frame(maxHeight: .some(150))
		}.onAppear {
			if let backdropURL = self.movie.backdropURL {
				self.imageFetcher.fetch(backdropURL)
			}
			self.similarMoviesDataSource.query(.recommendations(for: self.movie.id))
		}.sheet(item: $similarMovie) { movie in
			MovieDetailsView(movie: movie)
				.environmentObject(self.historyStore)
				.environmentObject(self.genresStore)
				.environmentObject(self.watchlistStore)
		}
	}
	
	private func openTrailer() {
		if let url = URL(string: "https://www.youtube.com/watch?v=oHg5SJYRHA0") {
			UIApplication.shared.open(url)
		}
	}
}

// MARK: - Previews

struct MovieCard_Previews: PreviewProvider {
	static var previews: some View {
		MovieCard(
			movie: Movie(
				id: 1,
				title: "The Social Network",
				posterPath: nil,
				backdropPath: nil,
				overview: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
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

struct MovieDetailsView_Previews: PreviewProvider {
	static var previews: some View {
		MovieDetailsView(
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
