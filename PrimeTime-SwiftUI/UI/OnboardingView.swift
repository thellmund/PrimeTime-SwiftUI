//
//  OnboardingView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
	@Environment(\.presentationMode) private var presentationMode
	
	var body: some View {
		NavigationView {
			SelectGenresView(onFinish: close)
				.navigationBarTitle("Select genres")
				.navigationBarItems(
					trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
						Text("Cancel").bold()
					}
			)
		}.accentColor(.red)
	}
	
	private func close() {
		presentationMode.wrappedValue.dismiss()
	}
}

struct SelectGenresView: View {
	@ObservedObject var genresDataSource = DataSource<GenresResponse>(endpoint: .genres)
	@State var selectedGenres = Set<Genre>()
	
	@EnvironmentObject private var genresStore: GenresStore
	@EnvironmentObject private var historyStore: HistoryStore
	
	var onFinish: () -> Void
	
	private var showNextButton: Bool {
		selectedGenres.count > 0
	}
	
	private var content: some View {
		switch genresDataSource.result {
		case .none:
			return AnyView(EmptyView())
		case .loading:
			return AnyView(LoadingView())
		case .success(let response):
			return AnyView(
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
			)
		case .error:
			return AnyView(PlaceholderView(title: "Oh no", subtitle: "Something went wrong"))
		}
	}
	
	var body: some View {
		VStack {
			content
			Spacer(minLength: 0)
			NavigationLink(destination:
				SelectMoviesView(onFinish: onFinish)
					.environmentObject(historyStore)
					.navigationBarTitle("Select movies")
			) {
				HStack {
					Spacer()
					Text("Next").foregroundColor(.white)
					Spacer()
				}
				.padding(.vertical, 14)
				.background(Color.red.opacity(showNextButton ? 1.0 : 0.4)).cornerRadius(Radius.corner)
				.overlay(RoundedRectangle(cornerRadius: Radius.corner).stroke(lineWidth: 0))
				.padding(.horizontal, Spacing.large)
				.shadow(radius: showNextButton ? Radius.shadow : 0)
			}.simultaneousGesture(
				TapGesture().onEnded {
					self.genresStore.storeFavorites(Array(self.selectedGenres))
				}
			).disabled(showNextButton == false)
		}
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
	
	var onFinish: () -> Void
	
	private var content: some View {
		switch samplesDataSource.result {
		case .none:
			return AnyView(EmptyView())
		case .loading:
			return AnyView(LoadingView())
		case .success(let response):
			return AnyView(
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
			)
		case .error:
			return AnyView(PlaceholderView(title: "Hmm…", subtitle: "Some 1s and 0s didn’t transmit correctly."))
		}
	}
	
	var body: some View {
		content.onAppear {
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
		onFinish()
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

struct OnboardingView_Previews: PreviewProvider {
	static var previews: some View {
		OnboardingView()
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
