//
//  ImageFetcher.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI
import Combine

private class ImageCache {
	static var shared = ImageCache()
	
	private var cache: [URL: Data] = [:]
	
	func get(for url: URL) -> Data? {
		// TODO Thread safety
		print("Getting image: \(url.absoluteString)")
		return cache[url]
	}
	
	func put(_ data: Data, for url: URL) {
		cache[url] = data
	}
}

class ImageFetcher: ObservableObject {
	var objectWillChange = PassthroughSubject<UIImage?, Never>()
	
	var image: UIImage? = nil {
		didSet {
			objectWillChange.send(image)
		}
	}
	
	private var url: URL?
	
	init(url: URL? = nil) {
		self.url = url
		if let url = url {
			fetch(url)
		}
	}
	
	func fetch() {
		guard let url = url else {
			print("You need to provide a URL that should be fetched.")
			return
		}
		
		fetch(url)
	}
	
	func fetch(_ url: URL) {
		// This is an ugly hack. Fix this sometime.
		if let existing = ImageCache.shared.get(for: url) {
			self.image = UIImage(data: existing)
			return
		}
		
		URLSession.shared.dataTask(with: url) { (data, _, _) in
			guard let data = data else { return }
			ImageCache.shared.put(data, for: url)
			DispatchQueue.main.async { [weak self] in
				self?.image = UIImage(data: data)
			}
		}.resume()
	}
}

class DelayedImageFetcher: ObservableObject {
	var objectWillChange = PassthroughSubject<UIImage?, Never>()
	
	var image: UIImage? = nil {
		didSet {
			objectWillChange.send(image)
		}
	}
	
	func fetch(url: URL?) {
		guard let url = url else { return }
		
		// This is an ugly hack. Fix this sometime.
		if let existing = ImageCache.shared.get(for: url) {
			self.image = UIImage(data: existing)
			return
		}
		
		URLSession.shared.dataTask(with: url) { (data, _, _) in
			guard let data = data else { return }
			ImageCache.shared.put(data, for: url)
			DispatchQueue.main.async { [weak self] in
				self?.image = UIImage(data: data)
			}
		}.resume()
	}
}
