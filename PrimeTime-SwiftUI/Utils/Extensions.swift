//
//  Extensions.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 25.06.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI
import UIKit

protocol GridElement: Identifiable {
	var id: Int { get }
}

struct Row<T: GridElement> : Identifiable {
	var id: Int { elements.first!.id }
	let elements: [T]
}

extension Array where Element: GridElement {
	func chunked(into size: Int) -> [Row<Element>] {
		return stride(from: 0, to: count, by: size).map {
			Row(elements: Array(self[$0 ..< Swift.min($0 + size, count)]))
		}
	}
}

extension UserDefaults {
	func decodableArray<T : Decodable>(forKey key: String) -> [T]? {
		guard let raw = UserDefaults.standard.stringArray(forKey: key) else { return nil }
		let decoder = JSONDecoder()
		let data = raw.map { $0.data(using: .utf8)! }
		return data.map { try! decoder.decode(T.self, from: $0) }
	}
	
	func set<T : Encodable>(encodables: [T], forKey key: String) {
		let encoder = JSONEncoder()
		let encoded = encodables.map { String(decoding: try! encoder.encode($0), as: UTF8.self) }
		UserDefaults.standard.set(encoded, forKey: key)
	}
}

extension Sequence {
	func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
		return map { $0[keyPath: keyPath] }
	}
	
	func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
		return sorted { a, b in a[keyPath: keyPath] < b[keyPath: keyPath] }
	}
}

extension UIImage {
	var averageColor: Color? {
		guard let inputImage = CIImage(image: self) else { return nil }
		let extentVector = CIVector(
			x: inputImage.extent.origin.x,
			y: inputImage.extent.origin.y,
			z: inputImage.extent.size.width,
			w: inputImage.extent.size.height
		)
		
		guard let filter = CIFilter(
			name: "CIAreaAverage",
			parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]
			) else { return nil }
		
		guard let outputImage = filter.outputImage else { return nil }
		
		var bitmap = [UInt8](repeating: 0, count: 4)
		let context = CIContext(options: [.workingColorSpace: kCFNull!])
		context.render(
			outputImage,
			toBitmap: &bitmap,
			rowBytes: 4,
			bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
			format: .RGBA8,
			colorSpace: nil
		)
		
		return Color(
			UIColor(
				red: CGFloat(bitmap[0]) / 255,
				green: CGFloat(bitmap[1]) / 255,
				blue: CGFloat(bitmap[2]) / 255,
				alpha: CGFloat(bitmap[3]) / 255
			)
		)
	}
}
