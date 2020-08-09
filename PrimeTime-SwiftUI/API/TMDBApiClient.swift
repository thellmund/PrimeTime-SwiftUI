//
//  TMDBApiClient.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation

struct CacheEntry {
	let data: Data
	let timestamp: Date = Date()
	
	var isValid: Bool {
		timestamp.distance(to: Date()) < 30 // seconds
	}
}

class ApiCache {
	private static var cache: [String: CacheEntry] = [:]
	
	static func get(_ url: URL) -> Data? {
		guard let candidate = cache[url.absoluteString], candidate.isValid else {
			cache.removeValue(forKey: url.absoluteString)
			return nil
		}
		return candidate.data
	}
	
	static func put(_ data: Data, forURL url: URL) {
		cache[url.absoluteString] = CacheEntry(data: data)
	}
}

protocol TMDBApiService {
	func fetch<T : Decodable>(_ url: URL, resultHandler: @escaping (ApiResult<T>) -> Void)
}

class RealTMDBApiService: TMDBApiService {
	
	private let decoder = JSONDecoder()
	
	init() {
		decoder.keyDecodingStrategy = .convertFromSnakeCase
	}
	
	func fetch<T : Decodable>(
		_ url: URL,
		resultHandler: @escaping (ApiResult<T>) -> Void
	) {
		func decode(_ data: Data) -> T? {
			do {
				return try decoder.decode(T.self, from: data)
			} catch {
				print(error)
				return nil
			}
		}
		
		print("Fetching URL: \(url)")
		
		if let cached = ApiCache.get(url), let payload = decode(cached) {
			print("Found cached value for \(url)")
			resultHandler(.success(response: payload))
			return
		}
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			guard let data = data else {
				DispatchQueue.main.async {
					resultHandler(.error)
				}
				return
			}
			
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			
			guard let payload = decode(data) else {
				DispatchQueue.main.async {
					resultHandler(.error)
				}
				return
			}
			
			ApiCache.put(data, forURL: url)
			
			DispatchQueue.main.async {
				resultHandler(.success(response: payload))
			}
		}.resume()
	}
}

enum TMDBApiClient {
	
	static func fetch<T : Decodable>(
		_ url: URL,
		resultHandler: @escaping (ApiResult<T>) -> Void
	) {
		func decode(_ data: Data) -> T? {
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			
			do {
				return try decoder.decode(T.self, from: data)
			} catch {
				print(error)
				return nil
			}
		}
		
		print("Fetching URL: \(url)")
		
		if let cached = ApiCache.get(url), let payload = decode(cached) {
			print("Found cached value for \(url)")
			resultHandler(.success(response: payload))
			return
		}
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			guard let data = data else {
				DispatchQueue.main.async {
					resultHandler(.error)
				}
				return
			}
			
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			
			guard let payload = decode(data) else {
				DispatchQueue.main.async {
					resultHandler(.error)
				}
				return
			}
			
			ApiCache.put(data, forURL: url)
			
			DispatchQueue.main.async {
				resultHandler(.success(response: payload))
			}
		}.resume()
	}
}
