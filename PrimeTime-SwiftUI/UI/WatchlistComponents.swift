//
//  WatchlistComponents.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 07.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct WatchlistButton: View {
	@EnvironmentObject var historyStore: HistoryStore
	@EnvironmentObject var watchlistStore: WatchlistStore
	
	var movie: MovieDetails
	@ObservedObject var imageFetcher: ImageFetcher
	
	@State private var watchState: WatchState = .notOnWatchlist
	
	@ViewBuilder
	var body: some View {
		let color: Color = imageFetcher.image?.averageColor ?? .gray
		let borderColor = (watchState != .notOnWatchlist) ? color : .clear
		let foregroundColor = (watchState != .notOnWatchlist) ? color : .white
		let backgroundColor = (watchState != .onWatchlist) ? color : .clear
		
		Button(action: toggle) {
			HStack {
				Spacer()
				Image(systemName: watchState.icon)
				Text(watchState.text)
				Spacer()
			}
		}
		.foregroundColor(foregroundColor)
		.padding(.vertical, 14)
		.background(backgroundColor.cornerRadius(Radius.corner))
		.shadow(radius: watchState.shadowRadius)
		.overlay(RoundedRectangle(cornerRadius: Radius.corner).stroke(borderColor, lineWidth: 2))
		.padding(.horizontal, Spacing.large)
		.disabled(watchState == .watched)
		.onAppear {
			if historyStore.contains(movie) {
				watchState = .watched
			}
			if watchlistStore.contains(movie) {
				watchState = .onWatchlist
			}
		}
	}
	
	private func toggle() {
		switch watchState {
		case .notOnWatchlist:
			watchlistStore.add(movie)
			watchState = .onWatchlist
		case .onWatchlist:
			watchlistStore.remove(movie)
			watchState = .notOnWatchlist
		case .watched:
			preconditionFailure()
		}
	}
}

// MARK: - Previews

struct WatchlistButton_Previews: PreviewProvider {
	static var previews: some View {
		WatchlistButton(
			movie: MovieDetails(
				id: 1,
				title: "The Social Network",
				posterPath: nil,
				backdropPath: nil,
				overview: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ",
				releaseDate: "08/24/2020",
				genres: [],
				runtime: 123,
				popularity: 100.0,
				voteAverage: 9.0,
				voteCount: 1_234
			),
			imageFetcher: ImageFetcher(placeholder: .poster)
		)
			.padding(10)
			.background(Color.gray)
	}
}
