//
//  Models.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation

// MARK: - Genres

struct GenresResponse: Codable {
	let genres: [ApiGenre]
}

struct ApiGenre: Codable {
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

// MARK: - Movies

struct MoviesResponse: Codable {
	var results: [Movie]
}

struct Movie: GridElement, Codable, Hashable {
	var id: Int
	var title: String
	var posterPath: String?
	var backdropPath: String?
	var overview: String
	var releaseDate: String
	var genreIds: [Int]
	var runtime: Int?
	var popularity: Float
	var voteAverage: Float
	var voteCount: Int
	
	var backdropURL: URL? {
		guard let path = backdropPath else { return nil }
		return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
	}
	
	var posterURL: URL? {
		guard let path = posterPath else { return nil }
		return URL(string: "https://image.tmdb.org/t/p/w1280\(path)")
	}
	
	func genres(_ store: GenresStore) -> [ApiGenre] {
		return genreIds.map {
			ApiGenre(
				id: $0,
				name: store.get(by: $0)?.name ?? "Unknown genre"
			)
		}.sorted(by: \.name)
	}
	
	var releaseYear: String {
		String(releaseDate.split(separator: "-").first!)
	}
	
	var formattedRuntime: String {
		guard let runtime = runtime else { return "🤷‍♂️" }
		let hours = runtime / 60
		let minutes = runtime % 60
		return "\(hours):\(String(format: "%02d", minutes))"
	}
	
	var formattedVoteAverage: String {
		"\(voteAverage) / 10"
	}
	
	var formattedVoteCount: String {
		(voteCount < 1_000) ? String(voteCount) : "\(voteCount / 1_000)K votes"
	}
	
	func formattedGenres(_ store: GenresStore) -> String {
		genres(store).map(\.name).joined(separator: ", ")
	}
}

enum MovieCategory: Identifiable {
	case nowPlaying
	case upcoming
	case genre(ApiGenre)
	
	var id: Int {
		switch self {
		case .nowPlaying:
			return 1
		case .upcoming:
			return 2
		case .genre(let genre):
			return genre.id
		}
	}
	
	var title: String {
		switch self {
		case .nowPlaying:
			return "Now playing"
		case .upcoming:
			return "Upcoming"
		case .genre(let genre):
			return genre.name
		}
	}
}

// MARK: - Samples

struct Sample: Codable, Identifiable, Hashable, GridElement {
	var id: Int
	var title: String
	var posterPath: String
	var backdropPath: String
	
	var posterURL: URL? {
		URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
	}
	
	var backdropURL: URL? {
		URL(string: "https://image.tmdb.org/t/p/w1280\(backdropPath)")
	}
}

struct SamplesResponse: Equatable, Codable {
	var results: [Sample]
}
