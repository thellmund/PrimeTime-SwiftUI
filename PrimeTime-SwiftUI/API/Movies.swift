//
//  Models.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation

struct MoviesResponse: Codable {
	var results: [Movie]
}

struct Movie: GridElement, Codable, Hashable {
	var id: Int
	var title: String
	var posterPath: String?
	var backdropPath: String?
	var overview: String
	var releaseDate: String?
	var genreIds: [Int]
	var runtime: Int?
	var popularity: Float
	var voteAverage: Float
	var voteCount: Int
	
	var posterURL: URL? {
		guard let path = posterPath else { return nil }
		return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
	}
}

struct MovieDetails: GridElement, Codable, Hashable {
	var id: Int
	var title: String
	var posterPath: String?
	var backdropPath: String?
	var overview: String
	var releaseDate: String?
	var genres: [ApiGenre]
	var runtime: Int?
	var popularity: Float
	var voteAverage: Float
	var voteCount: Int
	
	var backdropURL: URL? {
		guard let path = backdropPath else { return nil }
		return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
	}
	
	var posterURL: URL? {
		guard let path = posterPath else { return nil }
		return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
	}
	
	var formattedReleaseDate: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		guard let releaseDate = releaseDate, let date = formatter.date(from: releaseDate) else {
			return "–"
		}
		
		formatter.dateFormat = "MMM dd, yyyy"
		return formatter.string(from: date)
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
	
	var formattedGenres: String {
		genres.map(\.name).sorted().joined(separator: ", ")
	}
}

