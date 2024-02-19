//
//  BatteryVoltageComplication.swift
//  BatteryVoltageComplication
//
//  Created by Alex Shirazi on 2/18/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), batteryVoltage: 12.6)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, batteryVoltage: fetchbatteryVoltage())
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let currentbatteryVoltage = fetchbatteryVoltage()
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, batteryVoltage: currentbatteryVoltage)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Battery Voltage ")]
    }
    private func fetchbatteryVoltage() -> Double {
        let defaults = UserDefaults(suiteName: "group.shirazi")
        let batteryVoltage = defaults?.double(forKey: "batteryVoltage") ?? -1.0
        if batteryVoltage < 9 || batteryVoltage > 20 {
            let lastKnownGoodBatteryVoltage = defaults?.double(forKey: "lastKnownGoodBatteryVoltage") ?? 999
            return lastKnownGoodBatteryVoltage
        } else {
            defaults?.set(batteryVoltage, forKey: "lastKnownGoodBatteryVoltage")
            return batteryVoltage
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let batteryVoltage: Double
}

struct batteryVoltageComplicationEntryView : View {
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
        Gauge(value: entry.batteryVoltage,
              in: 10...16) {
            Image(systemName: "minus.plus.batteryblock.fill")
        } currentValueLabel: {
            Text(String(format: "%.1f V", entry.batteryVoltage))
        }
        .gaugeStyle(.circular)

    }
}
struct CornerView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f", entry.batteryVoltage))
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.title)
        }
    }
}



@main
struct batteryVoltageComplication: Widget {
    let kind: String = "batteryVoltageComplication"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            batteryVoltageComplicationEntryView(entry: entry)
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
    batteryVoltageComplication()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, batteryVoltage: 12.6)
    SimpleEntry(date: .now, configuration: .starEyes, batteryVoltage: 12.8)
}
