//
//  WatchlistComponents.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 07.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct WatchlistButton: View {
	
	var watchState: WatchState
	@ObservedObject var imageFetcher: ImageFetcher
	var action: () -> Void
	
	@ViewBuilder
	var body: some View {
		let color: Color = imageFetcher.image?.averageColor ?? .gray
		let borderColor = (watchState != .notOnWatchlist) ? color : .clear
		let foregroundColor = (watchState != .notOnWatchlist) ? color : .white
		let backgroundColor = (watchState != .onWatchlist) ? color : .clear
		
		Button(action: action) {
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
	}
}

// MARK: - Previews

struct WatchlistButton_Previews: PreviewProvider {
	static var previews: some View {
		WatchlistButton(
			watchState: .notOnWatchlist,
			imageFetcher: ImageFetcher(placeholder: .poster),
			action: {}
		)
		.padding(10)
		.background(Color.gray)
	}
}
