//
//  Config.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

enum Assets {
	enum Placeholder: String {
		case poster = "MoviePosterPlaceholder"
		case backdrop = "MovieBackdropPlaceholder"
	}
}

class Spacing {
	static let small: CGFloat = 4
	static let standard: CGFloat = 10
	static let large: CGFloat = 20
}

class Radius {
	static let shadow: CGFloat = 10
	static let corner: CGFloat = 12
	static let littleCorner: CGFloat = 6
}

var TMDB_API_KEY: String? {
	get {
		guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else {
			return nil
		}
		
		guard let values = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> else {
			return nil
		}
		
		return values["TMDB_API_KEY"] as? String
	}
}

var STORAGE_KEY = "group.com.hellmund.PrimeTime-SwiftUI"
