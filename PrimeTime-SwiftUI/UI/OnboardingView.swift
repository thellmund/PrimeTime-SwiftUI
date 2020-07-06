//
//  OnboardingView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct SelectGenresView: View {
	@Environment(\.presentationMode) private var presentationMode
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	
	@ObservedObject var genresDataSource = DataSource<GenresResponse>(endpoint: .genres)
	@State var selectedGenres = Set<Genre>()
	
	private var showNextButton: Bool {
		selectedGenres.count > 0
	}
	
	private var nextDestination: some View {
		SelectMoviesView()
			.environmentObject(historyStore)
			.navigationBarTitle("Select movies")
	}
	
	var body: some View {
		NavigationView {
			VStack {
				LoadableView(from: genresDataSource.result) { response in
					List(response.genres.asGenres) { genre in
						GenresRow(
							genre: genre,
							isSelected: self.selectedGenres.contains(genre)
						).onTapGesture {
							if self.selectedGenres.contains(genre) {
								self.selectedGenres.remove(genre)
							} else {
								self.selectedGenres.insert(genre)
							}
						}
					}
				}
			}.navigationBarItems(
				leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
					Text("Cancel")
				},
				trailing: NavigationLink(destination: nextDestination) {
					Text("Next").bold()
				}.simultaneousGesture(TapGesture().onEnded {
					self.genresStore.storeFavorites(Array(self.selectedGenres))
				}).disabled(showNextButton == false)
			).navigationBarTitle("Select genres")
		}
		.accentColor(.red)
	}
}

struct GenresRow: View {
	var genre: Genre
	var isSelected: Bool
	
	var body: some View {
		HStack {
			Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
				.foregroundColor(.red)
				.padding(.leading, Spacing.standard)
			Text(genre.name)
				.padding(.leading)
			Spacer()
		}.opacity(isSelected ? 1.0 : 0.4)
	}
}

struct SelectMoviesView: View {
	@Environment(\.presentationMode) private var presentationMode
	
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	
	@ObservedObject var samplesDataSource = CombiningDataSource { (responses: [SamplesResponse]) -> [Sample] in
		Array(Set(responses.flatMap { $0.results })).shuffled()
	}
	@State var selectedMovies = Set<Sample>()
	
	var body: some View {
		LoadableView(from: samplesDataSource.result) { response in
			Grid(data: response, columns: 3) { result in
				SampleView(
					sample: result,
					isSelected: self.selectedMovies.contains(result)
				).onTapGesture {
					if self.selectedMovies.contains(result) {
						self.selectedMovies.remove(result)
					} else {
						self.selectedMovies.insert(result)
					}
				}
			}
		}.onAppear {
			let genreIDs = self.genresStore.favorites.map(\.id)
			let endpoints = genreIDs.map { Endpoint.genreSamples(for: $0) }
			self.samplesDataSource.query(endpoints)
		}.navigationBarItems(trailing: Button(action: finishOnboarding) {
			Text("Finish")
				.bold()
				.disabled(selectedMovies.count < 4)
		})
	}
	
	private func finishOnboarding() {
		historyStore.add(Array(selectedMovies))
		presentationMode.wrappedValue.dismiss()
	}
}

struct SampleView: View {
	var sample: Sample
	var isSelected: Bool
	
	var body: some View {
		VStack {
			URLImage(from: sample.posterURL, withPlaceholder: .poster)
				.aspectRatio(contentMode: .fit)
				.cornerRadius(Radius.corner)
				.opacity(isSelected ? 1.0 : 0.4)
			
			Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
				.font(.system(size: 24))
				.foregroundColor(.red)
				.padding(.top, Spacing.standard)
				.padding(.bottom, Spacing.large)
		}
	}
}

struct SampleRow: View {
	var sample: Sample
	var isSelected: Bool
	
	var body: some View {
		HStack {
			Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
				.foregroundColor(.red)
			URLImage(from: sample.posterURL, withPlaceholder: .poster)
				.frame(width: 32, height: 48)
				.cornerRadius(4)
			Text(sample.title)
			Spacer()
		}.opacity(isSelected ? 1.0 : 0.4)
	}
}

// MARK: - Previews

struct SelectGenresView_Previews: PreviewProvider {
	static var previews: some View {
		SelectGenresView()
	}
}

struct SampleView_Previews: PreviewProvider {
	static var previews: some View {
		SampleView(
			sample: Sample(id: 1, title: "Title", posterPath: "https://image.tmdb.org/t/p/w1280/2TeJfUZMGolfDdW6DKhfIWqvq8y.jpg", backdropPath: "https://image.tmdb.org/t/p/w1280/2TeJfUZMGolfDdW6DKhfIWqvq8y.jpg"),
			isSelected: false
		)
	}
}
