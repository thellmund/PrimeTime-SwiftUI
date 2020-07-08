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
	
	@State private var watchState: WatchState = .notOnWatchlist
	
	var movie: Movie
	var backdropColor: Color?
	
	private var borderColor: Color {
		var color: Color
		
		if let backdropColor = backdropColor, watchState != .notOnWatchlist {
			color = backdropColor
		} else {
			color = .clear
		}
		
		return color
	}
	
	private var foregroundColor: Color {
		var color: Color
		
		if let backdropColor = backdropColor, watchState != .notOnWatchlist {
			color = backdropColor
		} else {
			color = .white
		}
		
		return color
	}
	
	private var backgroundColor: Color {
		var color: Color
		
		if let backdropColor = backdropColor, watchState == .notOnWatchlist {
			color = backdropColor
		} else {
			color = .clear
		}
		
		return color
	}
	
	var body: some View {
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
			if self.historyStore.contains(self.movie) {
				self.watchState = .watched
			}
			if self.watchlistStore.contains(self.movie) {
				self.watchState = .onWatchlist
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

struct WatchlistIconButton: View {
	@EnvironmentObject var historyStore: HistoryStore
	@EnvironmentObject var watchlistStore: WatchlistStore
	
	@State private var watchState: WatchState = .notOnWatchlist
	
	var movie: Movie
	
	var body: some View {
		Button(action: toggle) {
			HStack {
				Image(systemName: watchState.smallIcon)
				Text(watchState.shortText).bold().font(.caption)
			}
			.foregroundColor(.white)
			.padding(.all, 6)
			.overlay(RoundedRectangle(cornerRadius: 100).stroke(Color.white, lineWidth: 2))
		}
		.onAppear {
			if self.historyStore.contains(self.movie) {
				self.watchState = .watched
			}
			if self.watchlistStore.contains(self.movie) {
				self.watchState = .onWatchlist
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

struct WatchlistIconButton_Previews: PreviewProvider {
	static var previews: some View {
		WatchlistIconButton(movie:
			Movie(
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
			.padding(10)
			.background(Color.gray)
	}
}
