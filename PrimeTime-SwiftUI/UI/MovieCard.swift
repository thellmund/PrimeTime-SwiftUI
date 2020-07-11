//
//  MovieCard.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 07.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI
import UIKit

struct MovieCard: View {
	@State private var backdropImage = UIImage()
	
	var posterURL: URL?
	var showLoading: Bool = true
	
	var body: some View {
		ZStack(alignment: .bottom) {
			URLImage(from: posterURL, withPlaceholder: .poster, showLoading: showLoading)
				.aspectRatio(contentMode: .fit)
		}
		.cornerRadius(Radius.corner)
		.shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 0)
		.border(Color.clear, width: 1)
	}
}
