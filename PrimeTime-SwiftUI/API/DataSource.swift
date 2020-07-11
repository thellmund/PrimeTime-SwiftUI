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
		TMDBApiClient.shared.fetch(endpoint.url) { result in
			self.result = result
		}
	}
}

class CombiningDataSource<ResponseT : Unwrappable>: ObservableObject {
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
			TMDBApiClient.shared.fetch(endpoint.url) { (result: ApiResult<ResponseT>) in
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
				self.result = .success(response: responses.flatMap { $0.unwrapped })
			}
		}
	}
}

protocol Unwrappable: Codable {
	associatedtype Child: Codable
	var unwrapped: [Child] { get }
}

extension MoviesResponse: Unwrappable {
	var unwrapped: [Movie] { results }
}

extension SamplesResponse: Unwrappable {
	var unwrapped: [Sample] { results }
}
