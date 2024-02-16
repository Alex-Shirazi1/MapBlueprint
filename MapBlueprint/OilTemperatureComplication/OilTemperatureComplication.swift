//
//  OilTemperatureComplication.swift
//  OilTemperatureComplication
//
//  Created by Alex Shirazi on 2/15/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), oilTemperature: 169)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, oilTemperature: fetchOilTemperature())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        var currentOilTemperature = fetchOilTemperature()
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, oilTemperature: currentOilTemperature)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Oil Temperature")]
    }
    private func fetchOilTemperature() -> Double {
        let defaults = UserDefaults(suiteName: "group.shirazi")
        let oilTemperature = defaults?.double(forKey: "oilTemperature") ?? -1.0
        if oilTemperature < 0 || oilTemperature > 500 {
            let lastKnownGoodOilTemperature = defaults?.double(forKey: "lastKnownGoodOilTemperature") ?? 999
            return lastKnownGoodOilTemperature
        } else {
            defaults?.set(oilTemperature, forKey: "lastKnownGoodOilTemperature")
            return oilTemperature
        }
    }

    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let oilTemperature: Double
}

struct oilComplicationEntryView : View {
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
        Gauge(value: entry.oilTemperature,
              in: 0...250) {
            Image(systemName: "oilcan.fill")
        } currentValueLabel: {
            Text("\(Int(entry.oilTemperature)) °F")
        }
        .gaugeStyle(.circular)

    }
}
struct CornerView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.2f", entry.oilTemperature))
            Image(systemName: "oilcan.fill")
                .font(.title)
        }
    }
}



@main
struct oilComplication: Widget {
    let kind: String = "oilComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            oilComplicationEntryView(entry: entry)
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
    oilComplication()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, oilTemperature: 20.0)
    SimpleEntry(date: .now, configuration: .starEyes, oilTemperature: 30.0)
}
