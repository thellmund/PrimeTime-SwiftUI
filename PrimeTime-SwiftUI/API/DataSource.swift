//
//  DataSource.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI
import Combine

enum ApiResult<T : Codable> {
	case none
	case loading
	case success(response: T)
	case error
}

class DataSource<T : Codable>: ObservableObject {
	var objectWillChange = PassthroughSubject<ApiResult<T>, Never>()
	
	var result: ApiResult<T> = .none {
		didSet {
			objectWillChange.send(result)
		}
	}
	
	private var endpoint: Endpoint?
	
	init(endpoint: Endpoint? = nil) {
		self.endpoint = endpoint
		if let endpoint = endpoint {
			query(endpoint)
		}
	}
	
	func query() {
		guard let endpoint = endpoint else {
			print("You need to provide an Endpoint that should be queried.")
			return
		}
		
		query(endpoint)
	}
	
	func query(_ endpoint: Endpoint) {
		result = .loading
		TMDBApiClient.shared.fetch(endpoint.url) { result in
			self.result = result
		}
	}
}

class CombiningDataSource<ResponseT : Codable, ResultT : Codable>: ObservableObject {
	
	typealias Combiner = ([ResponseT]) -> [ResultT]
	var combiner: Combiner
	
	var objectWillChange = PassthroughSubject<ApiResult<[ResultT]>, Never>()
	
	var result: ApiResult<[ResultT]> = .loading {
		didSet {
			objectWillChange.send(result)
		}
	}
	
	init(combiner: @escaping Combiner) {
		self.combiner = combiner
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
				let results = self.combiner(responses)
				self.result = .success(response: results)
			}
		}
	}
}
