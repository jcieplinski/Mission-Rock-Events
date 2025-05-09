//
//  TodayEventsIntent.swift
//  qui
//
//  Created by Joe Cieplinski on 5/8/25.
//

import AppIntents
import Foundation
import SwiftUI
import SwiftData

struct TodayEventsIntent: AppIntent {
  typealias Value = String
  
  init() {}
  
  var sharedModelContainer: ModelContainer = {
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
  
  static var title: LocalizedStringResource = "Today's Events"
  static var description = IntentDescription("Shows events happening near you today")
  static var openAppWhenRun: Bool = false
  
  func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
    let events = try await QuiEventHandler(modelContainer: sharedModelContainer).fetch()
    
    if let todayEvent = events.filter({ $0.date.isToday() }).sorted(by: { $0.date < $1.date }).first {
      return .result(
        value: todayEvent.title,
        dialog: "\(todayEvent.title) at \(todayEvent.location) at \(todayEvent.date.formatted(date: .omitted, time: .shortened))"
      )
    }
    
    return .result(value: "No Events Today", dialog: "No Events Today")
  }
}

@ModelActor
actor QuiEventHandler {
  public func fetch() throws -> [QuiEventEntity] {
    let descriptor = FetchDescriptor<QuiEvent>()
    let fetchedEvents = try modelContext.fetch(descriptor).sorted{ $0.date < $1.date }
    
    return fetchedEvents.map(QuiEventEntity.init)
  }
}
