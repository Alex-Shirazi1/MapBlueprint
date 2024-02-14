//
//  FuelComplication.swift
//  FuelComplication
//
//  Created by Alex Shirazi on 2/14/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), fuelLevel: fetchFuelLevel())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, fuelLevel: fetchFuelLevel())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        var currentFuelLevel = fetchFuelLevel()
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, fuelLevel: fetchFuelLevel())
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Fuel level Widget")]
    }
    private func fetchFuelLevel() -> Double {
        let defaults = UserDefaults(suiteName: "group.shirazi")
        return defaults?.double(forKey: "fuelLevel") ?? 1.0
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let fuelLevel: Double
}

struct FuelComplicationEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(String(format: "%.2f", entry.fuelLevel))
            Text("G")
        }
        
    }
}

@main
struct FuelComplication: Widget {
    let kind: String = "FuelComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FuelComplicationEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .accessoryRectangular) {
    FuelComplication()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, fuelLevel: 2.0)
    SimpleEntry(date: .now, configuration: .starEyes, fuelLevel: 3.0)
}
