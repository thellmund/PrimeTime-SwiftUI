//
//  Components.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI
import UIKit

enum ApiResult<T : Codable> {
	case none
	case loading
	case success(response: T)
	case error
}

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
	
	@ViewBuilder
	var body: some View {
		switch apiResult {
		case .none:
			EmptyView()
		case .loading:
			LoadingView().frame(maxWidth: .infinity)
		case .success(let data):
			content(data)
		case .error:
			PlaceholderView(title: errorTitle, subtitle: errorSubtitle)
		}
	}
}

struct ModalHeader: View {
	@Environment(\.presentationMode) private var presentationMode
	var body: some View {
		Image(systemName: "chevron.compact.down")
			.resizable()
			.foregroundColor(.gray)
			.frame(width: 32.0, height: 10.0)
			.padding(.top, Spacing.large)
			.padding(.bottom,Spacing.standard)
			.onTapGesture { self.presentationMode.wrappedValue.dismiss() }
	}
}

struct URLImage: View {
	@ObservedObject var imageFetcher: ImageFetcher
	
	private var placeholder: Assets.Placeholder
	private var showLoadingIndicator: Bool
	
	init(from url: URL?, withPlaceholder placeholder: Assets.Placeholder, showLoading: Bool = true) {
		self.imageFetcher = ImageFetcher(url: url, placeholder: placeholder)
		self.placeholder = placeholder
		self.showLoadingIndicator = showLoading
	}
	
	@ViewBuilder
	var body: some View {
		Image(uiImage: imageFetcher.image).resizable()
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
