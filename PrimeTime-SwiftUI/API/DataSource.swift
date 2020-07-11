//
//  DataSource.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI
import Combine

class DataSource<T : Codable>: ObservableObject {
	@Published private(set) var result: ApiResult<T> = .none
	
	private var endpoint: Endpoint?
	
	init(endpoint: Endpoint? = nil) {
		self.endpoint = endpoint
		if let endpoint = endpoint {
			query(endpoint)
		}
	}
	
	func query(_ endpoint: Endpoint) {
		result = .loading
		TMDBApiClient.fetch(endpoint.url) { result in
			self.result = result
		}
	}
}

class CombiningDataSource<ResponseT : Flattenable>: ObservableObject {
	@Published private(set) var result: ApiResult<[ResponseT.Child]> = .loading
	
	private var endpoints: [Endpoint]?
	
	init(_ endpoints: [Endpoint]? = nil) {
		self.endpoints = endpoints
		self.query()
	}
	
	func query() {
		if let endpoints = endpoints {
			self.query(endpoints)
		}
	}
	
	func query(_ endpoints: [Endpoint]) {
		let dispatchGroup = DispatchGroup()
		var responses: [ResponseT] = []
		
		for endpoint in endpoints {
			dispatchGroup.enter()
			TMDBApiClient.fetch(endpoint.url) { (result: ApiResult<ResponseT>) in
				if case let .success(response) = result {
					responses.append(response)
				}
				dispatchGroup.leave()
			}
		}
		
		dispatchGroup.notify(queue: .main) {
			if responses.isEmpty {
				self.result = .error
			} else {
				self.result = .success(response: responses.flatMap { $0.flattened })
			}
		}
	}
}

protocol Flattenable: Codable {
	associatedtype Child: Codable
	var flattened: [Child] { get }
}

extension MoviesResponse: Flattenable {
	var flattened: [Movie] { results }
}

extension SamplesResponse: Flattenable {
	var flattened: [Sample] { results }
}
