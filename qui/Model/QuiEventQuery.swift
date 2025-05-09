//
//  QuiEventQuery.swift
//  qui
//
//  Created by Joe Cieplinski on 5/8/25.
//

import SwiftData
import AppIntents

struct QuiEventQuery: EntityQuery, Sendable {
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
  
  func suggestedEntities() async throws -> [QuiEventEntity] {
    return await MainActor.run {
      let descriptor = FetchDescriptor<QuiEvent>()
      let fetchedEvents = try? sharedModelContainer.mainContext.fetch(descriptor).sorted{ $0.date < $1.date }
      
      let events = fetchedEvents ?? []
      
      return events.map { event -> QuiEventEntity in
        return QuiEventEntity(event: event)
      }
    }
  }
  
  func defaultResult() async -> QuiEventEntity? {
    return await MainActor.run {
      let descriptor = FetchDescriptor<QuiEvent>()
      let fetchedEvents = try? sharedModelContainer.mainContext.fetch(descriptor).sorted{ $0.date < $1.date }
      
      let events = fetchedEvents ?? []
      
      if let first = events.first {
        return QuiEventEntity(event: first)
      }
      
      return nil
    }
  }
  
  func entities(for identifiers: [QuiEventEntity.ID]) async throws -> [QuiEventEntity] {
    return await MainActor.run {
      let descriptor = FetchDescriptor<QuiEvent>()
      let fetchedEvents = try? sharedModelContainer.mainContext.fetch(descriptor).sorted{ $0.date < $1.date }
      
      let events = fetchedEvents ?? []
      
      let filtered = events.filter {
        identifiers.contains($0.id)
      }
      
      return filtered.map { event -> QuiEventEntity in
        return QuiEventEntity(event: event)
      }
    }
  }
}
