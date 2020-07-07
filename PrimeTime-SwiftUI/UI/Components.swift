//
//  Components.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI
import UIKit

enum WatchState {
	case watched
	case onWatchlist
	case notOnWatchlist
	
	var icon: String {
		switch self {
		case .notOnWatchlist:
			return "plus"
		case .onWatchlist:
			return "trash"
		case .watched:
			return "list"
		}
	}
	
	var smallIcon: String {
		switch self {
		case .notOnWatchlist:
			return "plus"
		case .onWatchlist, .watched:
			return "checkmark"
		}
	}
	
	var text: String {
		switch self {
		case .notOnWatchlist:
			return "Add to watchlist"
		case .onWatchlist:
			return "Remove from watchlist"
		case .watched:
			return "Already watched"
		}
	}
	
	var shortText: String {
		switch self {
		case .notOnWatchlist:
			return "Add"
		case .onWatchlist, .watched:
			return "Added"
		}
	}
	
	var opacity: Double {
		(self != .watched) ? 1.0 : 0.5
	}
	
	var shadowRadius: CGFloat {
		(self != .watched) ? Radius.shadow : 0
	}
}

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

struct Grid<Content: View, Element: GridElement>: View {
	var data: [Element]
	var columns: Int = 2
	var rowContent: (Element) -> Content
	
	var body: some View {
		let rows = data.chunked(into: columns)
		return List(rows) { row in
			HStack(spacing: Spacing.standard) {
				ForEach(row.elements) { movie in
					self.rowContent(movie)
				}
			}
		}
	}
}

struct MoviesGrid<Content: View>: View {
	var data: [Movie]
	var columns: Int = 2
	var rowContent: (Movie) -> Content
	
	var body: some View {
		let rows = data.chunked(into: columns)
		return List(rows) { row in
			HStack(spacing: Spacing.standard) {
				ForEach(row.elements) { movie in
					self.rowContent(movie)
				}
			}
		}
	}
}

struct WatchlistCardButton: View {
	var icon: String
	var text: String
	var onTapGesture: () -> Void
	
	var body: some View {
		HStack {
			Image(systemName: icon)
			Text(text)
		}
		.foregroundColor(.white)
		.frame(maxWidth: .infinity)
		.padding(Spacing.standard)
		.background(Color.red.cornerRadius(Radius.corner))
		.onTapGesture { self.onTapGesture() }
	}
}

struct PlaceholderView: View {
	var title: String
	var subtitle: String
	
	var body: some View {
		VStack {
			Spacer()
			VStack {
				Text(title)
					.font(.title)
					.bold()
					.foregroundColor(.gray)
					.opacity(0.9)
				Text(subtitle)
					.font(.body)
					.foregroundColor(.gray)
					.opacity(0.8)
			}
			Spacer()
		}
	}
}

struct LoadingView: View {
	var body: some View {
		VStack {
			Spacer()
			ActivityIndicator(style: .medium)
			Spacer()
		}
	}
}

struct ActivityIndicator: UIViewRepresentable {
	let style: UIActivityIndicatorView.Style
	
	func makeUIView(
		context: UIViewRepresentableContext<ActivityIndicator>
	) -> UIActivityIndicatorView {
		return UIActivityIndicatorView(style: style)
	}
	
	func updateUIView(
		_ uiView: UIActivityIndicatorView,
		context: UIViewRepresentableContext<ActivityIndicator>
	) {
		uiView.startAnimating()
	}
}

struct LoadableImage: View {
	var image: UIImage?
	var placeholder: Assets.Placeholder
	
	var body: some View {
		if let image = image {
			return AnyView(Image(uiImage: image).resizable())
		} else {
			return AnyView(
				ZStack(alignment: .center) {
					Image(placeholder.rawValue).resizable()
					ActivityIndicator(style: .medium)
				}
			)
		}
	}
}

struct LoadableView<Content: View, T: Codable>: View {
	
	private let apiResult: ApiResult<T>
	private let errorTitle: String
	private let errorSubtitle: String
	private let content: (T) -> Content
	
	init(
		from apiResult: ApiResult<T>,
		errorTitle: String = "Oh no",
		errorSubtitle: String = "Something went wrong",
		@ViewBuilder content: @escaping (T) -> Content
	) {
		self.apiResult = apiResult
		self.errorTitle = errorTitle
		self.errorSubtitle = errorSubtitle
		self.content = content
	}
	
	var body: some View {
		switch apiResult {
		case .none:
			return AnyView(EmptyView())
		case .loading:
			return AnyView(LoadingView())
		case .success(let data):
			return AnyView(content(data))
		case .error:
			return AnyView(PlaceholderView(title: errorTitle, subtitle: errorSubtitle))
		}
	}
}

struct URLImage: View {
	@ObservedObject var imageFetcher: ImageFetcher
	
	var placeholder: Assets.Placeholder
	
	init(from url: URL?, withPlaceholder placeholder: Assets.Placeholder) {
		self.imageFetcher = ImageFetcher(url: url)
		self.placeholder = placeholder
	}
	
	var body: some View {
		if let image = imageFetcher.image {
			return AnyView(Image(uiImage: image).resizable())
		} else {
			return AnyView(
				ZStack(alignment: .center) {
					Image(placeholder.rawValue).resizable()
					ActivityIndicator(style: .medium)
				}
			)
		}
	}
}

struct TabbedView: View {
	private var viewControllers: [UIHostingController<AnyView>]
	
	init(_ tabs: Tab...) {
		viewControllers = tabs.map { tab in
			let host = UIHostingController(rootView: tab.view)
			host.tabBarItem = tab.barItem
			return host
		}
	}
	
	var body: some View {
		TabBarController(controllers: viewControllers).edgesIgnoringSafeArea(.all)
	}
	
	struct Tab {
		var view: AnyView
		var barItem: UITabBarItem
		
		init<V: View>(view: V, barItem: UITabBarItem) {
			self.view = AnyView(view)
			self.barItem = barItem
		}
	}
}

extension View {
	func tabItem(title: String, icon: String) -> TabbedView.Tab {
		return TabbedView.Tab(
			view: self,
			barItem: UITabBarItem(
				title: title,
				image: UIImage(systemName: icon),
				selectedImage: nil
			)
		)
	}
}

struct TabBarController: UIViewControllerRepresentable {
	var controllers: [UIViewController]
	
	func makeUIViewController(context: Context) -> UITabBarController {
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = controllers
		return tabBarController
	}
	
	func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
		// Free ad space
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
