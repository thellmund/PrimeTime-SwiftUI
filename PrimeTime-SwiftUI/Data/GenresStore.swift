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
	
	private let apiService: TMDBApiService
	
	@Published private(set) var genres: [Genre] {
		didSet {
			UserDefaults.standard.set(genres.encoded, forKey: "genres")
		}
	}
	
	init(apiService: TMDBApiService = RealTMDBApiService()) {
		self.apiService = apiService
		self.genres = UserDefaults.standard.decodableArray(forKey: "genres") ?? []
		self.fetchGenres()
	}
	
	
	var favorites: [Genre] {
		genres.filter { $0.preference == .favorite }
	}
	
	func get(by id: Int) -> Genre? {
		return genres.first { $0.id == id }
	}
	
	func store(_ apiGenres: [ApiGenre]) {
		let existingGenreIDs = Set(genres.map(\.id))
		let newApiGenres = apiGenres.filter { existingGenreIDs.contains($0.id) }
		let newGenres = newApiGenres.map { Genre(from: $0) }
		genres.append(contentsOf: newGenres)
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
	
	private func fetchGenres() {
		apiService.fetch(Endpoint.genres.url) { (result: ApiResult<GenresResponse>) in
			guard case let .success(response) = result else { return }
			self.store(response.genres)
		}
	}
}
