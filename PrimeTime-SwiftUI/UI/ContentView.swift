//
//  ContentView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 25.06.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	
	@EnvironmentObject private var historyStore: HistoryStore
	
	init() {
		if #available(iOS 14.0, *) {
			// iOS 14 doesn't have extra separators below the list by default.
		} else {
			// To remove only extra separators below the list:
			UITableView.appearance().tableFooterView = UIView()
		}
	}
	
	var body: some View {
		TabbedView(
			HomeView().tabItem(title: "Home", icon: "house.fill"),
			ExploreView().tabItem(title: "Explore", icon: "magnifyingglass"),
			WatchlistView().tabItem(title: "Watchlist", icon: "list.number")
		).accentColor(.red)
	}
}
