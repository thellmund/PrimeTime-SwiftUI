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
	
	var title: String {
		switch self {
		case .all:
			return "Home"
		case .category(let category):
			return category.title
		}
	}
}

struct HomeView: View {
	
	@EnvironmentObject var historyStore: HistoryStore
	
	var body: some View {
		NavigationView {
			ZStack(alignment: .bottom) {
				MoviesViewContainer()
				GenresBanner()
			}
		}
	}
}

struct GenresBanner: View {
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	
	@State var isShowingOnboarding: Bool = false
	@State var wasDismissed: Bool = false
	
	var onDismiss: () -> Void = {}
	
	var body: some View {
		if wasDismissed || historyStore.movies.isEmpty == false {
			return AnyView(EmptyView())
		} else {
			return AnyView(
				Button(action: { self.isShowingOnboarding = true }) {
					HStack {
						VStack(alignment: .leading) {
							Text("Get personalized recommendations")
								.bold()
								.foregroundColor(.white)
							Text("Add your favorite genres to get started")
								.foregroundColor(.white)
						}
						Spacer(minLength: Spacing.standard)
						Button(action: { self.wasDismissed = true }) {
							Image(systemName: "xmark").foregroundColor(.white)
						}
					}
					.padding(Spacing.large)
					.background(Color.red.cornerRadius(Radius.corner))
					.padding(.all, Spacing.standard)
					.shadow(radius: Radius.shadow)
				}.sheet(isPresented: $isShowingOnboarding) {
					SelectGenresView()
						.environmentObject(self.genresStore)
						.environmentObject(self.historyStore)
						.onDisappear { self.isShowingOnboarding = false }
				}
			)
		}
	}
}
