//
//  GenresStore.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation
import Combine

class GenresStore: ObservableObject {
	
	var objectWillChange = PassthroughSubject<[Genre], Never>()
	
	var genres: [Genre] = UserDefaults.standard.decodableArray(forKey: "genres") ?? [] {
		didSet {
			UserDefaults.standard.set(encodables: genres, forKey: "genres")
			objectWillChange.send(genres)
		}
	}
	
	var favorites: [Genre] {
		genres.filter { $0.preference == .favorite }
	}
	
	func get(by id: Int) -> Genre? {
		return genres.first { $0.id == id }
	}
	
	func store(_ apiGenres: [ApiGenre]) {
		genres = apiGenres.map { Genre(from: $0) }
	}
	
	func storeFavorites(_ favorites: [Genre]) {
		for favorite in favorites {
			if let index = genres.firstIndex(where: { $0.id == favorite.id }) {
				genres.remove(at: index)
				genres.insert(favorite.withPreference(.favorite), at: index)
			} else {
				genres.append(favorite.withPreference(.favorite))
			}
		}
	}
	
	func update(_ genreID: Int, withPreference preference: Genre.Preference) {
		guard let index = genres.firstIndex(where: { $0.id == genreID }) else { return }
		let genre = genres.remove(at: index)
		
		let newGenre = genre.withPreference(preference)
		genres.insert(newGenre, at: index)
	}
}
