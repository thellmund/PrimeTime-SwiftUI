//
//  Samples.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 07.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation

struct SamplesResponse: Equatable, Codable {
	var results: [Sample]
}

struct Sample: Codable, Identifiable, Hashable, GridElement {
	var id: Int
	var title: String
	var posterPath: String?
	var backdropPath: String?
	
	var posterURL: URL? {
		guard let posterPath = posterPath else { return nil }
		return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
	}
	
	var backdropURL: URL? {
		guard let backdropPath = backdropPath else { return nil }
		return URL(string: "https://image.tmdb.org/t/p/w1280\(backdropPath)")
	}
}
