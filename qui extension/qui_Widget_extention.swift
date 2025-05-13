//
//  Qui_Widget_Extension.swift
//  Mission Rock Events Widget Extension
//
//  Created by Joe Cieplinski on 5/8/25.
//

import WidgetKit
import SwiftUI
import SwiftData
import OSLog

struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    return SimpleEntry(
      date: Date(),
      configuration: ConfigurationAppIntent(),
      todayEvent: nil,
      todayEventImage: nil
    )
  }
  
  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
    if let entry = await getTodayEntry(for: configuration, in: context) {
      return entry
    } else {
      return SimpleEntry(
        date: Date(),
        configuration: ConfigurationAppIntent(),
        todayEvent: nil,
        todayEventImage: nil
      )
    }
  }
  
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
    if let entry = await getTodayEntry(for: configuration, in: context) {
      return Timeline(entries: [entry], policy: .atEnd)
    } else {
      let entry = SimpleEntry(
        date: Date(),
        configuration: ConfigurationAppIntent(),
        todayEvent: nil,
        todayEventImage: nil
      )
      return Timeline(entries: [entry], policy: .atEnd)
    }
  }
  
  private func getTodayEntry(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry? {
    let sharedModelContainer: ModelContainer = {
      let schema = Schema([
        QuiEvent.self,
      ])
      
      let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
      
      do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
      } catch {
        fatalError("Could not create ModelContainer: \(error)")
      }
    }()
    
    do {
      let events = try await QuiEventHandler(modelContainer: sharedModelContainer).fetch()
      
      if let todayEvent = events.filter({ $0.date.isToday() }).sorted(by: { $0.date < $1.date }).first {
        if let url = URL(string: todayEvent.imageURL ?? "") {
          let imageData = try Data(contentsOf: url)
          let image = UIImage(data: imageData)
          let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            todayEvent: todayEvent,
            todayEventImage: image
          )
          
          return entry
        } else {
          let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            todayEvent: todayEvent,
            todayEventImage: nil
          )
          
          return entry
        }
      } else {
        let entry = SimpleEntry(
          date: Date(),
          configuration: configuration,
          todayEvent: nil,
          todayEventImage: nil
        )
        
        return entry
      }
    } catch {
      Logger.swiftData.error("Error fetching events: \(error)")
      return SimpleEntry(date: Date(), configuration: configuration, todayEvent: nil, todayEventImage: nil)
    }
  }
  
  //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
  //        // Generate a list containing the contexts this widget is relevant in.
  //    }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let configuration: ConfigurationAppIntent
  let todayEvent: QuiEventEntity?
  let todayEventImage: UIImage?
}

struct Qui_Widget_ExtensionEntryView : View {
  @Environment(\.widgetFamily) var family
  
  var entry: Provider.Entry
  @Query(sort: \QuiEvent.date) private var events: [QuiEvent]
  
  var nextEvent: QuiEvent? {
    return events
      .filter { $0.date > Calendar.current.startOfDay(for: Date()) }
      .sorted { $0.date < $1.date }
      .first
  }
  
  var body: some View {
    VStack {
      switch family {
      case .systemSmall, .systemLarge, .systemMedium:
        if let todayEvent = entry.todayEvent {
          EntryCardWidgetView(event: todayEvent, image: entry.todayEventImage)
        } else {
          NoEventWidgetView(nextEvent: nextEvent)
        }
      case .accessoryCircular:
        if let image = entry.todayEventImage {
            Image(uiImage: image)
              .resizable()
              .aspectRatio(contentMode: .fit)
        } else {
          Text("No Events")
            .multilineTextAlignment(.center)
        }
      case .accessoryRectangular:
        if let todayEvent = entry.todayEvent {
          HStack {
            if let image = entry.todayEventImage {
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            }
            
            Text(todayEvent.title)
              .lineLimit(2)
              .truncationMode(.tail)
          }
        } else {
          Text("No Events")
            .multilineTextAlignment(.center)
        }
      default:
        if let todayEvent = entry.todayEvent {
          Text(todayEvent.title)
        } else {
          Text("No Events Today")
        }
      }
    }
    .frame(maxWidth: .infinity)
  }
}

struct Qui_Widget_Extension: Widget {
  let kind: String = "Mission_Rock_Events_Widget_Extension"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
      Qui_Widget_ExtensionEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
        .modelContainer(for: [QuiEvent.self])
    }
    .contentMarginsDisabled()
    .supportedFamilies([
      .systemSmall,
      .systemMedium,
      .systemLarge,
      .accessoryCircular,
      .accessoryInline,
      .accessoryRectangular,
    ])
  }
}

extension ConfigurationAppIntent {
  fileprivate static var smiley: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    return intent
  }
  
  fileprivate static var starEyes: ConfigurationAppIntent {
    let intent = ConfigurationAppIntent()
    return intent
  }
}

#Preview(as: .systemSmall) {
  Qui_Widget_Extension()
} timeline: {
  SimpleEntry(date: .now, configuration: .smiley, todayEvent: nil, todayEventImage: nil)
  SimpleEntry(date: .now, configuration: .starEyes, todayEvent: nil, todayEventImage: nil)
}

#Preview(as: .accessoryInline) {
  Qui_Widget_Extension()
} timeline: {
  SimpleEntry(date: .now, configuration: .smiley, todayEvent: nil, todayEventImage: nil)
}

#Preview(as: .accessoryCircular) {
  Qui_Widget_Extension()
} timeline: {
  SimpleEntry(date: .now, configuration: .smiley, todayEvent: nil, todayEventImage: nil)
}
