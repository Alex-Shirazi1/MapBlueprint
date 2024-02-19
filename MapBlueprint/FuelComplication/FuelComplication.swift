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
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), fuelLevel: fetchFuelLevel(), maxFuelLevel: fetchMaxFuelLevel())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, fuelLevel: fetchFuelLevel(), maxFuelLevel: fetchMaxFuelLevel())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        var currentFuelLevel = fetchFuelLevel()
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, fuelLevel: fetchFuelLevel(), maxFuelLevel: fetchMaxFuelLevel())
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Fuel level")]
    }
    private func fetchFuelLevel() -> Double {
        let defaults = UserDefaults(suiteName: "group.shirazi")
        let fuelLevel = defaults?.double(forKey: "fuelLevel") ?? -1.0
        if fuelLevel < 0 {
            let lastKnownGoodFuelLevel = defaults?.double(forKey: "lastKnownGoodFuelLevel") ?? 999
            return lastKnownGoodFuelLevel
        } else {
            defaults?.set(fuelLevel, forKey: "lastKnownGoodFuelLevel")
            return fuelLevel
        }
    }
    private func fetchMaxFuelLevel() -> Double {
        let defaults = UserDefaults(suiteName: "group.shirazi")
        let max =  defaults?.double(forKey: "maxFuelLevel") ?? 13.7
        if max < 5 {
            return 13.7
        }
        return max
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let fuelLevel: Double
    let maxFuelLevel: Double
}

struct FuelComplicationEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        Group {
            if widgetFamily == .accessoryCircular {
                CircularView(entry: entry)
            } else {
                CornerView(entry: entry)
            }
        }
    }
}
struct CircularView: View {
    var entry: Provider.Entry


    var body: some View {

        Gauge(value: entry.fuelLevel,
              in: 0...entry.maxFuelLevel) {
            if entry.fuelLevel > 2.5 {
                Image(systemName: "fuelpump.fill")
            } else {
                Image(systemName: "fuelpump.exclamationmark.fill")
            }
        } currentValueLabel: {
            Text(String(format: "%.2f", entry.fuelLevel))
        }
        .gaugeStyle(.circular)

    }
}
struct CornerView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.2f", entry.fuelLevel))
            Image(systemName: "fuelpump.fill")
                .font(.title)
        }
        .widgetLabel {
            Gauge(value: entry.fuelLevel) {
                Text("Fuel Tank")
            } currentValueLabel: {
                Text("\(entry.fuelLevel)")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text(String(format: "%.1f", entry.maxFuelLevel))
            }
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
    SimpleEntry(date: .now, configuration: .smiley, fuelLevel: 2.0, maxFuelLevel: 13.7)
    SimpleEntry(date: .now, configuration: .starEyes, fuelLevel: 3.0, maxFuelLevel: 13.7)
}
