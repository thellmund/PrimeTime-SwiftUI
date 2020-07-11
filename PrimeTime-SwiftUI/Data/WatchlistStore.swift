//
//  WatchlistStore.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 03.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation
import Combine

class WatchlistStore: ObservableObject {
	
	@Published private(set) var movies: [Movie] {
		didSet {
			UserDefaults(suiteName: STORAGE_KEY)?.set(movies.encoded, forKey: "watchlist")
		}
	}
	
	init() {
		movies = UserDefaults(suiteName: STORAGE_KEY)?.decodableArray(forKey: "watchlist") ?? []
	}
	
	func contains(_ movie: Movie) -> Bool {
		return movies.contains { $0.id == movie.id }
	}
	
	func add(_ movie: Movie) {
		movies.append(movie)
	}
	
	func remove(_ movie: Movie) {
		movies.removeAll { $0.id == movie.id }
	}
	
	func remove(at index: Int) {
		movies.remove(at: index)
	}
}
