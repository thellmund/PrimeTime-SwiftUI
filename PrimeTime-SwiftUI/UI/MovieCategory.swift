//
//  Models.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 07.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import Foundation

enum MovieCategory: Identifiable {
	case nowPlaying
	case upcoming
	case genre(ApiGenre)
	
	var id: Int {
		switch self {
		case .nowPlaying:
			return 1
		case .upcoming:
			return 2
		case .genre(let genre):
			return genre.id
		}
	}
	
	var title: String {
		switch self {
		case .nowPlaying:
			return "Now playing"
		case .upcoming:
			return "Upcoming"
		case .genre(let genre):
			return genre.name
		}
	}
}
