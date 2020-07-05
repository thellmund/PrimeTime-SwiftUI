//
//  Endpoint.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 05.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation

struct Endpoint: Equatable {
	var path: String
	var queryItems: [URLQueryItem] = []
}

extension Endpoint {
	var url: URL {
		let generalQueryItems = [
			URLQueryItem(name: "api_key", value: TMDB_API_KEY),
			URLQueryItem(name: "language", value: "en-US")
		]
		
		var components = URLComponents()
		components.scheme = "https"
		components.host = "api.themoviedb.org"
		components.path = "/3/\(path)"
		components.queryItems = generalQueryItems + queryItems
		
		guard let url = components.url else {
			preconditionFailure("Invalid URL components: \(components)")
		}
		
		return url
	}
}

extension Endpoint {
	static var genres: Self {
		Endpoint(path: "genre/movie/list")
	}
	
	static func movieDetails(for id: Int) -> Self {
		Endpoint(path: "movie/\(id)")
	}
	
	static func nowPlaying(page: Int = 1) -> Self {
		Endpoint(
			path: "movie/now_playing",
			queryItems: [
				URLQueryItem(name: "page", value: String(page))
			]
		)
	}
	
	static func upcoming(page: Int = 1) -> Self {
		Endpoint(
			path: "movie/upcoming",
			queryItems: [
				URLQueryItem(name: "page", value: String(page))
			]
		)
	}
	
	static func topRated(page: Int = 1) -> Self {
		Endpoint(
			path: "movie/top_rated",
			queryItems: [
				URLQueryItem(name: "page", value: String(page))
			]
		)
	}
	
	static func genreSamples(for genreID: Int, page: Int = 1) -> Self {
		Endpoint(
			path: "discover/movie",
			queryItems: [
				URLQueryItem(name: "with_genres", value: String(genreID)),
				URLQueryItem(name: "sort_by", value: "popularity.desc"),
				URLQueryItem(name: "page", value: String(page))
			]
		)
	}
	
	static func search(_ query: String) -> Self {
		Endpoint(
			path: "search/movie",
			queryItems: [URLQueryItem(name: "query", value: query)]
		)
	}
	
	static func recommendations(for movieID: Int) -> Self {
		Endpoint(path: "movie/\(movieID)/recommendations")
	}
}
