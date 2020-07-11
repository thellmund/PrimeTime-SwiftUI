//
//  WatchlistStore.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 03.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation
import Combine

private let STORAGE_KEY = "group.com.hellmund.PrimeTime-SwiftUI"

class WatchlistStore: ObservableObject {
	
	@Published private(set) var movies: [MovieDetails] {
		didSet {
			UserDefaults(suiteName: STORAGE_KEY)?.set(movies.encoded, forKey: "watchlist")
		}
	}
	
	init() {
		movies = UserDefaults(suiteName: STORAGE_KEY)?.decodableArray(forKey: "watchlist") ?? []
	}
	
	func contains(_ movie: MovieDetails) -> Bool {
		return movies.contains { $0.id == movie.id }
	}
	
	func add(_ movie: MovieDetails) {
		movies.append(movie)
	}
	
	func remove(_ movie: MovieDetails) {
		movies.removeAll { $0.id == movie.id }
	}
	
	func remove(at index: Int) {
		movies.remove(at: index)
	}
}
