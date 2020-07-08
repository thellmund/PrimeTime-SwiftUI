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
	
	let userDefaults = UserDefaults(suiteName: "group.com.hellmund.PrimeTime-SwiftUI")
	
	var objectWillChange = PassthroughSubject<[Movie], Never>()
	
	// TODO App Group for UserDefaults?
	// TODO Make UserDefaults wrapper as ObservableObject
	
	var movies: [Movie] = UserDefaults(suiteName: "group.com.hellmund.PrimeTime-SwiftUI")?.decodableArray(forKey: "watchlist") ?? [] {
		didSet {
			if let storage = UserDefaults(suiteName: "group.com.hellmund.PrimeTime-SwiftUI") {
				storage.set(100, forKey: "test123")
				storage.set(encodables: movies, forKey: "watchlist")
				print("*** in WatchlistStore: \(storage.dictionaryRepresentation().keys)")
				objectWillChange.send(movies)
			}
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
