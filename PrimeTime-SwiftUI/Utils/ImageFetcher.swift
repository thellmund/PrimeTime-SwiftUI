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
		cache[url]
	}
	
	func put(_ data: Data, for url: URL) {
		cache[url] = data
	}
}

private extension UIImage {
	convenience init?(color: UIColor, size: CGSize) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
}

class ImageFetcher: ObservableObject {
	private var url: URL?
	@Published private(set) var image: UIImage!
	
	init(url: URL? = nil, placeholder: Assets.Placeholder) {
		self.url = url
		self.image = UIImage(color: .secondarySystemBackground, size: placeholder.aspectRatio)
		
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
