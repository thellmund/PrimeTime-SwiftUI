//
//  ExploreView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct ExploreView: View {
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	@EnvironmentObject private var watchlistStore: WatchlistStore
	
	@ObservedObject var genresDataSource = DataSource<GenresResponse>(endpoint: .genres)
	@State private var isSearchOpen: Bool = false
	
	private var content: some View {
		switch genresDataSource.result {
		case .none:
			return AnyView(EmptyView())
		case .loading:
			return AnyView(LoadingView())
		case .success(let response):
			return AnyView(
				CategoriesView(categories: [.nowPlaying, .upcoming] + response.genres.map(\.asCategory))
			)
		case .error:
			return AnyView(PlaceholderView(title: "Something went wrong", subtitle: "Try again later."))
		}
	}
	
	var body: some View {
		NavigationView {
			VStack {
				content
				Spacer(minLength: 0)
			}
			.navigationBarTitle("Explore")
			.navigationBarItems(
				trailing: Button(action: openSearch) {
					Image(systemName: "magnifyingglass")
				}
			)
		}.sheet(isPresented: $isSearchOpen) {
			SearchView()
				.environmentObject(self.genresStore)
				.environmentObject(self.historyStore)
				.environmentObject(self.watchlistStore)
				.onDisappear { self.isSearchOpen = false }
		}
	}
	
	private func openSearch() {
		isSearchOpen = true
	}
}

struct CategoriesView: View {
	var categories: [MovieCategory]
	var body: some View {
		List(categories, id: \.id) { category in
			NavigationLink(
				destination: MoviesView(title: category.title, filter: .category(category))
			) {
				CategoryRow(category: category)
			}
		}
	}
}

struct CategoryRow: View {
	@ObservedObject var dataSource: DataSource<MoviesResponse>
	
	private var category: MovieCategory
	
	init(category: MovieCategory) {
		self.category = category
		self.dataSource = DataSource(endpoint: category.endpoint)
	}
	
	var body: some View {
		HStack {
			CategoryPostersStack(urls: dataSource.result.posterURLs)
			Text(category.title)
				.font(.title)
				.bold()
				.padding(.leading, Spacing.standard)
			Spacer()
		}
		.padding(.vertical, Spacing.standard)
		.cornerRadius(Radius.corner)
		.frame(maxWidth: .infinity)
	}
}

private extension MovieCategory {
	var endpoint: Endpoint {
		switch self {
		case .nowPlaying:
			return .nowPlaying()
		case .upcoming:
			return .upcoming()
		case .genre(let genre):
			return .genreSamples(for: genre.id)
		}
	}
}

private extension ApiResult where T == MoviesResponse {
	var posterURLs: [URL] {
		if case let .success(moviesResponse) = self {
			let posterURLs = moviesResponse.results.compactMap { $0.posterURL }
			return Array(posterURLs.prefix(3))
		} else {
			return []
		}
	}
}

struct PosterData: Identifiable {
	var id: String { url.absoluteString }
	var url: URL
	var degrees: Angle
}

struct CategoryPostersStack: View {
	var urls: [URL]
	
	private var items: [PosterData] {
		Array(zip(urls, [-5.0, 0.0, 5.0])).map { PosterData(url: $0, degrees: .degrees($1)) }
	}
	
	var body: some View {
		ZStack {
			ForEach(items) { posterData in
				URLImage(from: posterData.url, withPlaceholder: .poster)
					.frame(width: 100, height: 150)
					.cornerRadius(4)
					.rotationEffect(posterData.degrees)
					.shadow(radius: 4)
			}
		}
		.frame(width: 120, height: 180, alignment: .center)
	}
}

// MARK: - Previews

struct ExploreView_Previews: PreviewProvider {
	static var previews: some View {
		ExploreView()
	}
}
