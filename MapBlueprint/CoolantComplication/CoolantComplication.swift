//
//  CoolantComplication.swift
//  CoolantComplication
//
//  Created by Alex Shirazi on 2/15/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), coolantTemperature: 169, units: "°F")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, coolantTemperature: fetchcoolantTemperature(), units: fetchUnits())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let currentcoolantTemperature = fetchcoolantTemperature()
        let currentUnits = fetchUnits()
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, coolantTemperature: currentcoolantTemperature, units: currentUnits)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Coolant Temperature")]
    }
    private func fetchcoolantTemperature() -> Double {
        let defaults = UserDefaults(suiteName: "group.shirazi")
        let coolantTemperature = defaults?.double(forKey: "coolantTemperature") ?? -1.0
        if coolantTemperature < 0 || coolantTemperature > 500 {
            let lastKnownGoodCoolantTemperature = defaults?.double(forKey: "lastKnownGoodcoolantTemperature") ?? 999
            return lastKnownGoodCoolantTemperature
        } else {
            defaults?.set(coolantTemperature, forKey: "lastKnownGoodcoolantTemperature")
            return coolantTemperature
        }
    }
}

private func fetchUnits() -> String {
    let defaults = UserDefaults(suiteName: "group.shirazi")
    guard let units = defaults?.string(forKey: "temperatureUnits") else {
        return ""
    }
    return units
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let coolantTemperature: Double
    let units: String
}

struct CoolantComplicationEntryView : View {
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
        Gauge(value: entry.coolantTemperature,
              in: 0...250) {
            Image(systemName: "snowflake")
        } currentValueLabel: {
            Text("\(Int(entry.coolantTemperature)) \(entry.units)")
        }
        .gaugeStyle(.circular)

    }
}
struct CornerView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.2f", entry.coolantTemperature))
            Image(systemName: "snowflake")
                .font(.title)
        }
    }
}



@main
struct CoolantComplication: Widget {
    let kind: String = "CoolantComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            CoolantComplicationEntryView(entry: entry)
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
    CoolantComplication()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, coolantTemperature: 20.0, units: "°C")
    SimpleEntry(date: .now, configuration: .starEyes, coolantTemperature: 30.0, units: "°F")
}
