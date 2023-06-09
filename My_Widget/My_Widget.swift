//
//  My_Widget.swift
//  My_Widget
//
//  Created by Brilliant Gamez on 8/12/22.
//

import EventKit
import Intents
import SwiftUI
import WidgetKit

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: .now, configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct WidgetDate: View {
    var body: some View {
        ZStack{
            Image("widget_background")
        }
        .padding(.leading, 4)
        .offset(y: 2)
    }
}

struct EventsWidgetEntryView: View {
    internal init(entry: Provider.Entry) {
        self.entry = entry
        self.canAccessEvents = EventStore.shared.canAccessEvents
    }
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry
    let canAccessEvents: Bool
    
    var displayedEvents: [EKEvent] {
        var events = EventStore.shared.events(for: entry.date)
        
//        if entry.configuration.showAllCalendars != 1,
//           let calendarIDs = entry.configuration.calendars?.compactMap(\.identifier) {
//            events = events
//                .filter { event in
//                    calendarIDs.contains { $0 == event.calendar.calendarIdentifier }
//                }
//        }
        
        // Ensures that the events fit the size of their widgets.
        let limit: Int? = {
            switch widgetFamily {
                case .systemSmall, .systemMedium: return 2
                case .systemLarge: return 6
                default: return nil
            }
        }()
        
        if let limit = limit {
            return Array(events.prefix(limit))
        } else {
            return events
        }
    }
    
    var body: some View {
        Group {
            if !canAccessEvents {
//                Placeholder("No Access to Events")
            } else {
                let events = displayedEvents
                
                if events.isEmpty {
//                    Placeholder("No more jobs!")
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        WidgetDate()
                        
                        VStack(spacing: 6) {
                            ForEach(events, id: \.eventIdentifier) { event in
//                                EventItem(event)
//                                    .clipShape(ContainerRelativeShape())
                            }
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .horizontal], 12)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

@main
struct EventsWidget: Widget {
    let kind: String = "EventsWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: ConfigurationIntent.self,
                            provider: Provider()) { entry in
            EventsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Events")
        .description("Your remaining events for today.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct EventsWidget_Previews: PreviewProvider {
    static var previews: some View {
        EventsWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        EventsWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        EventsWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
