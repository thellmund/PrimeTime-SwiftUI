//
//  HomeView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

enum HomeFilter {
	case all
	case category(MovieCategory)
	
	func createEndpoints(historyStore: HistoryStore) -> [Endpoint] {
		switch self {
		case .all:
			let movies = historyStore.liked
			return movies.map { Endpoint.recommendations(for: $0.id) }
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

struct HomeView: View {
	
	@EnvironmentObject var historyStore: HistoryStore
	
	@State var isShowingBanner: Bool = false
	
	var body: some View {
		NavigationView {
			ZStack(alignment: .bottom) {
				MoviesView(title: "Home")
				if isShowingBanner {
					GenresBanner(onDismiss: { self.isShowingBanner = false })
				}
			}.onAppear {
				self.isShowingBanner = self.historyStore.movies.isEmpty
			}
		}
	}
}

struct GenresBanner: View {
	
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	
	@State var isShowingOnboaring: Bool = false
	
	var onDismiss: () -> Void = {}
	
	var body: some View {
		Button(action: { self.isShowingOnboaring = true }) {
			HStack {
				VStack(alignment: .leading) {
					Text("Get personalized recommendations").bold().foregroundColor(.white)
					Text("Add your favorite genres to get started").foregroundColor(.white)
				}
				Spacer(minLength: Spacing.standard)
				Button(action: { self.onDismiss() }) {
					Image(systemName: "xmark").foregroundColor(.white)
				}
			}
			.padding(Spacing.large)
			.background(Color.red.cornerRadius(Radius.corner))
			.padding(.all, Spacing.standard)
			.shadow(radius: Radius.shadow)
		}.sheet(isPresented: $isShowingOnboaring) {
			OnboardingView()
				.environmentObject(self.genresStore)
				.environmentObject(self.historyStore)
				.onDisappear { self.isShowingOnboaring = false }
		}
	}
}
