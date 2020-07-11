//
//  HistoryView.swift
//  PrimeTime-SwiftUI
//
//  Created by Till on 04.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import SwiftUI

struct HistoryView: View {
	@Environment(\.presentationMode) private var presentationMode
	@EnvironmentObject private var store: HistoryStore
	
	@State private var editMode = EditMode.inactive
	
	@ViewBuilder
	private var content: some View {
		if store.movies.isEmpty {
			PlaceholderView(title: "No movies", subtitle: "Your history is empty.")
		} else {
			List {
				ForEach(store.movies) { movie in
					HistoryMovieCard(historyMovie: movie)
				}.onDelete(perform: onDelete)
			}
		}
	}
	
	private var leadingButton: some View {
		store.movies.isEmpty ? AnyView(EmptyView()) : AnyView(EditButton())
	}
	
	var body: some View {
		NavigationView {
			content
				.navigationBarTitle(Text("History"))
				.navigationBarItems(
					leading: leadingButton,
					trailing: Button(action: { presentationMode.wrappedValue.dismiss() }) {
						Text("Close").bold()
					}
				)
				.environment(\.editMode, $editMode)
		}.accentColor(.red)
	}
	
	private func onDelete(offsets: IndexSet) {
		for index in Array(offsets) {
			store.remove(at: index)
		}
	}
}

struct HistoryMovieCard: View {
	@EnvironmentObject private var store: HistoryStore
	@State var isShowingRatingDialog: Bool = false
	
	var historyMovie: HistoryMovie
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(historyMovie.title).bold()
				Text(historyMovie.formattedTimestamp).opacity(0.7)
			}
			Spacer()
			Image(systemName: historyMovie.rating.rawValue).padding()
		}
		.onTapGesture { isShowingRatingDialog = true }
		.actionSheet(isPresented: $isShowingRatingDialog) {
			ActionSheet(
				title: Text("Rate \"\(historyMovie.title)\""),
				buttons: [
					.default(Text("Show more like this")) {
						store.updateRating(.like, for: historyMovie)
					},
					.default(Text("Show less like this")) {
						store.updateRating(.dislike, for: historyMovie)
					},
					.cancel()
				]
			)
		}
	}
}
