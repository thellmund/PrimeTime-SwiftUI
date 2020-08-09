//
//  PrimeTimeApp.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 01.08.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

@main
struct PrimeTimeApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(GenresStore())
				.environmentObject(HistoryStore())
				.environmentObject(WatchlistStore())
		}
	}
}
