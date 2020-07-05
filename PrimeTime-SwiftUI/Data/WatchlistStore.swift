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
	
	var objectWillChange = PassthroughSubject<[Movie], Never>()
	
	var movies: [Movie] = UserDefaults.standard.decodableArray(forKey: "watchlist") ?? [] {
		didSet {
			UserDefaults.standard.set(encodables: movies, forKey: "watchlist")
			objectWillChange.send(movies)
		}
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
