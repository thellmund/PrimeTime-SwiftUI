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

extension ApiResult {
	func ifSuccess<Content: View>(success: (T) -> Content) -> some View {
		switch self {
		case .none:
			return AnyView(EmptyView())
		case .loading:
			return AnyView(LoadingView())
		case .success(let response):
			return AnyView(success(response))
		case .error:
			return AnyView(PlaceholderView(title: "Hmm…", subtitle: "Some 1s and 0s didn’t transmit correctly."))
		}
	}
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
		var responses: [ResponseT] = []
		var outstandingQueries = endpoints
		
		for endpoint in endpoints {
			TMDBApiClient.shared.fetch(endpoint.url) { (result: ApiResult<ResponseT>) in
				outstandingQueries.removeAll { $0 == endpoint }
				
				switch result {
				case .success(let response):
					responses.append(response)
				default:
					break
				}
				
				if outstandingQueries.isEmpty && responses.isEmpty {
					self.result = .error
				} else {
					let results = self.combiner(responses)
					self.result = .success(response: results)
				}
			}
		}
	}
}
