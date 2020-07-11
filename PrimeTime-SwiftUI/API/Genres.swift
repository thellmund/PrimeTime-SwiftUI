//
//  Genres.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 07.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation

struct GenresResponse: Codable {
	let genres: [ApiGenre]
}

struct ApiGenre: Codable, Equatable, Hashable {
	var id: Int
	var name: String
}

extension ApiGenre {
	var asCategory: MovieCategory {
		.genre(self)
	}
}

extension Array where Element == ApiGenre {
	var asGenres: [Genre] {
		map { Genre(from: $0) }
	}
}

struct Genre: Codable, Identifiable, Hashable {
	let id: Int
	let name: String
	let preference: Preference
	
	init(id: Int, name: String, preference: Preference = .none) {
		self.id = id
		self.name = name
		self.preference = preference
	}
	
	init(from genre: ApiGenre) {
		self.id = genre.id
		self.name = genre.name
		self.preference = .none
	}
	
	func withPreference(_ preference: Preference) -> Genre {
		return Genre(id: id, name: name, preference: preference)
	}
	
	enum Preference: Int, Codable {
		case none
		case favorite
		case exclude
	}
}
