//
//  MoviesView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct MoviesView: View {
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@ObservedObject var dataSource = CombiningDataSource { (responses: [MoviesResponse]) -> [Movie] in
		let results = responses.flatMap { $0.results }
		return Array(Set(results.sorted(by: \.popularity)))
	}
	
	@State var isShowingDetail = false
	@State var selectedMovie: Movie? = nil
	@State var isShowingDialog = false
	@State var dialogMovie: Movie? = nil
	
	private var title: String
	private var filter: HomeFilter
	
	init(title: String, filter: HomeFilter = .all) {
		self.title = title
		self.filter = filter
	}
	
	var content: some View {
		switch dataSource.result {
		case .none, .loading:
			return AnyView(LoadingView())
		case .success(let movies):
			return AnyView(
				Grid(data: movies) { movie in
					MovieCard(movie: movie)
						.onTapGesture { self.open(movie) }
						.onLongPressGesture { self.showRatingDialog(for: movie) }
				}.sheet(isPresented: $isShowingDetail) {
					MovieDetailsModalView(movie: self.selectedMovie!)
						.environmentObject(self.historyStore)
						.environmentObject(self.genresStore)
						.environmentObject(self.watchlistStore)
						.onDisappear {
							self.isShowingDetail = false
							self.selectedMovie = nil
						}
				}.actionSheet(isPresented: $isShowingDialog) {
					ActionSheet(
						title: Text("Rate \"\(dialogMovie!.title)\""),
						buttons: [
							.default(Text("Show more like this")),
							.default(Text("Show less like this")),
							.cancel()
						]
					)
				}
			)
		case .error:
			return AnyView(PlaceholderView(title: "Oh boy…", subtitle: "Someone is going to be fired over this."))
		}
	}
	
	var body: some View {
		content.navigationBarTitle(title).onAppear {
			self.fetchMovies()
		}
	}
	
	private func fetchMovies() {
		let endpoints = createEndpoints()
		dataSource.query(endpoints)
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
	
	private func open(_ movie: Movie) {
		isShowingDetail = true
		selectedMovie = movie
	}
	
	private func showRatingDialog(for movie: Movie) {
		isShowingDialog = true
		dialogMovie = movie
	}
}

struct MovieCard: View {
	@State var backdropImage = UIImage()
	var movie: Movie
	
	var body: some View {
		ZStack(alignment: .bottom) {
			URLImage(from: movie.posterURL, withPlaceholder: .poster)
				.aspectRatio(contentMode: .fit)
		}
		.cornerRadius(Radius.corner)
		.padding(.bottom, 4)
		.shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 0)
		.border(Color.clear, width: 1)
	}
}

struct MovieDetailsModalView: View {
	@Environment(\.presentationMode) private var presentationMode
	@EnvironmentObject var genresStore: GenresStore
	@EnvironmentObject var historyStore: HistoryStore
	
	var movie: Movie
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				HStack {
					Spacer()
					Image(systemName: "chevron.compact.down")
						.resizable()
						.foregroundColor(.gray)
						.frame(width: 32.0, height: 10.0)
						.padding(.top, Spacing.large)
						.padding(.bottom,Spacing.standard)
						.onTapGesture { self.presentationMode.wrappedValue.dismiss() }
					Spacer()
				}
				MovieDetailsView(movie: movie)
			}
		}
	}
}

struct MovieDetailsView: View {
	@Environment(\.presentationMode) private var presentationMode
	@EnvironmentObject var genresStore: GenresStore
	@EnvironmentObject var watchlistStore: WatchlistStore
	
	@ObservedObject var similarMoviesDataSource = DataSource<MoviesResponse>()
	@ObservedObject var imageFetcher = ImageFetcher()
	
	var movie: Movie
	
	private var similarMovies: some View {
		switch similarMoviesDataSource.result {
		case .none, .loading:
			return AnyView(LoadingView())
		case .success(let response):
			return AnyView(
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: Spacing.standard) {
						ForEach(response.results, id: \.id) { movie in
							URLImage(from: movie.posterURL, withPlaceholder: .poster)
								.frame(width: 100, height: 150)
								.cornerRadius(Radius.corner)
						}
					}
					.padding(.horizontal, Spacing.large)
				}
			)
		case .error:
			return AnyView(
				VStack {
					Spacer()
					Text("No similar movies found.")
					Spacer()
				}
			)
		}
	}
	
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
			
			similarMovies.frame(maxHeight: .some(150))
		}.onAppear {
			if let backdropURL = self.movie.backdropURL {
				self.imageFetcher.fetch(backdropURL)
			}
			self.similarMoviesDataSource.query(.recommendations(for: self.movie.id))
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
