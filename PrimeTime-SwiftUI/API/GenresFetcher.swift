//
//  GenresFetcher.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation

class GenresFetcher {
	static func fetch(onSuccess: @escaping ([ApiGenre]) -> Void) {
		TMDBApiClient.shared.fetch(Endpoint.genres.url) { (result: ApiResult<GenresResponse>) in
			guard case let .success(response) = result else { return }
			onSuccess(response.genres)
		}
	}
}
