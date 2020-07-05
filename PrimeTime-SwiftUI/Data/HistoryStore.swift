//
//  HistoryStore.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 03.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation
import Combine

enum Rating: String, Codable {
	case like = "hand.thumbsup.fill"
	case dislike = "hand.thumbsdown.fill"
}

struct HistoryMovie: Codable, Identifiable {
	var id: Int
	let title: String
	let rating: Rating
	let timestamp: Date = Date()
	
	var formattedTimestamp: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter.string(from: timestamp)
	}
}

class HistoryStore: ObservableObject {
	
	var objectWillChange = PassthroughSubject<[HistoryMovie], Never>()
	
	var movies: [HistoryMovie] = UserDefaults.standard.decodableArray(forKey: "history_movies") ?? [] {
		didSet {
			UserDefaults.standard.set(encodables: movies, forKey: "history_movies")
			objectWillChange.send(movies)
		}
	}
	
	var liked: [HistoryMovie] {
		movies.filter { $0.rating == .like }
	}
	
	func contains(_ movie: Movie) -> Bool {
		movies.contains { $0.id == movie.id }
	}
	
	func add(_ movie: Movie, withRating rating: Rating) {
		movies.append(HistoryMovie(id: movie.id, title: movie.title, rating: rating))
	}
	
	func add(_ samples: [Sample]) {
		let historyMovies = samples.map { HistoryMovie(id: $0.id, title: $0.title, rating: .like) }
		movies.append(contentsOf: historyMovies)
	}
	
	func updateRating(_ rating: Rating, for movie: HistoryMovie) {
		guard let index = movies.firstIndex(where: { $0.id == movie.id }) else { return }
		movies.remove(at: index)
		
		let newMovie = HistoryMovie(id: movie.id, title: movie.title, rating: rating)
		movies.insert(newMovie, at: index)
	}
	
	func remove(at index: Int) {
		movies.remove(at: index)
	}
}
