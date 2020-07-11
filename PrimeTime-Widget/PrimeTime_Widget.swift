//
//  PrimeTime_Widget.swift
//  PrimeTime-Widget
//
//  Created by Till on 07.07.20.
//  Copyright © 2020 Till Hellmund. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
	public typealias Entry = SimpleEntry
	
	public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
		let entry = SimpleEntry(date: Date())
		completion(entry)
	}
	
	public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
		let entries: [SimpleEntry] = [SimpleEntry(date: Date())]
		
		// Generate a timeline consisting of five entries an hour apart, starting from the current date.
//		let currentDate = Date()
//		for hourOffset in 0 ..< 5 {
//			let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//			let entry = SimpleEntry(date: entryDate)
//			entries.append(entry)
//		}
		
		let timeline = Timeline(entries: entries, policy: .atEnd)
		completion(timeline)
	}
}

struct SimpleEntry: TimelineEntry {
	public let date: Date
}

struct WidgetPlaceholderView : View {
	var body: some View {
		Text("Placeholder View")
	}
}

struct WidgetMovieCard {
	let movie: Movie?
}

struct PrimeTime_WidgetEntryView : View {
	
	private let store = WatchlistStore()
	
	var entry: Provider.Entry
	
	@ViewBuilder
	var body: some View {
		if store.movies.isEmpty {
			Text("Nothing on your watchlist")
		} else {
			VStack(alignment: .leading) {
				Text("Watchlist").font(.subheadline).bold()
				HStack {
					ForEach(store.movies.prefix(3)) { movie in
						MovieCard(posterURL: movie.posterURL, showLoading: false)
					}
					Spacer(minLength: 0)
				}
			}.padding()
		}
	}
}

@main
struct PrimeTime_Widget: Widget {
	private let kind: String = "PrimeTime_Widget"
	
	public var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Provider(), placeholder: WidgetPlaceholderView()) { entry in
			PrimeTime_WidgetEntryView(entry: entry)
		}
		.configurationDisplayName("My Widget")
		.description("This is an example widget.")
		.supportedFamilies([.systemMedium])
	}
}

struct PrimeTime_Widget_Previews: PreviewProvider {
	static var previews: some View {
		PrimeTime_WidgetEntryView(entry: SimpleEntry(date: Date()))
			.previewContext(WidgetPreviewContext(family: .systemMedium))
			.previewDisplayName("Medium widget")
			.environment(\.colorScheme, .light)
	}
}
