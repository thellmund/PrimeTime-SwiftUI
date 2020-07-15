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
		SelectMoviesView(with: Array(selectedGenres))
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
							isSelected: selectedGenres.contains(genre)
						).onTapGesture {
							selectedGenres.toggle(genre)
						}
					}
				}
			}.navigationBarItems(
				leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
					Text("Cancel")
				},
				trailing: NavigationLink(destination: nextDestination) {
					Text("Next").bold()
				}.simultaneousGesture(TapGesture().onEnded {
					genresStore.storeFavorites(Array(selectedGenres))
				}).disabled(showNextButton == false)
			).navigationBarTitle("Select genres")
		}
		.accentColor(.red)
	}
}

extension Genre {
	var samplesEndpoint: Endpoint {
		.genreSamples(for: id)
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
	
	@ObservedObject private var dataSource: CombiningDataSource<SamplesResponse>
	@State private var selectedMovies = Set<Sample>()
	
	init(with genres: [Genre]) {
		self.dataSource = CombiningDataSource(genres.map(\.samplesEndpoint))
	}
	
	var body: some View {
		LoadableView(from: dataSource.result) { response in
			ScrollView {
				let columns = Array(repeatElement(GridItem(.flexible()), count: 3))
				LazyVGrid(columns: columns) {
					ForEach(response.unique.sorted(by: \.popularity)) { result in
						SampleView(
							sample: result,
							isSelected: selectedMovies.contains(result)
						).onTapGesture {
							selectedMovies.toggle(result)
						}
					}
				}.padding()
			}.onAppear {
				dataSource.query()
			}.navigationBarItems(
				trailing: Button(action: finishOnboarding) {
					Text("Finish").bold().disabled(selectedMovies.count < 4)
				}
			)
		}
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

// MARK: - Previews

struct SelectGenresView_Previews: PreviewProvider {
	static var previews: some View {
		SelectGenresView()
	}
}

struct SampleView_Previews: PreviewProvider {
	static var previews: some View {
		SampleView(
			sample: Sample(
				id: 1,
				title: "Title",
				posterPath: "https://image.tmdb.org/t/p/w342/2TeJfUZMGolfDdW6DKhfIWqvq8y.jpg",
				backdropPath: "https://image.tmdb.org/t/p/w342/2TeJfUZMGolfDdW6DKhfIWqvq8y.jpg",
				popularity: 1.234
			),
			isSelected: false
		)
	}
}
