//
//  QuiEventHandler.swift
//  qui
//
//  Created by Joe Cieplinski on 5/10/25.
//

import SwiftUI
import SwiftData
import OSLog

@ModelActor
actor QuiEventHandler {
  public func fetch() throws -> [QuiEventEntity] {
    let descriptor = FetchDescriptor<QuiEvent>()
    let fetchedEvents = try modelContext.fetch(descriptor).sorted{ $0.date < $1.date }
    
    return fetchedEvents.map(QuiEventEntity.init)
  }
  
  public func updateFromWeb() async throws {
    // Fetch new events from web API
    let newEvents = try await fetchEvents()
    
    // Get existing events from database
    let descriptor = FetchDescriptor<QuiEvent>()
    let existingEvents = try modelContext.fetch(descriptor)
    
    // Create sets of IDs for efficient lookup
    let newEventIds = Set(newEvents.map { $0.id })
    let existingEventIds = Set(existingEvents.map { $0.id })
    
    // Delete events that no longer exist in API response
    for event in existingEvents {
      if !newEventIds.contains(event.id) {
        modelContext.delete(event)
      }
    }
    
    // Update existing or insert new events
    for newEvent in newEvents {
      if existingEventIds.contains(newEvent.id) {
        // Update existing event
        if let existingEvent = existingEvents.first(where: { $0.id == newEvent.id }) {
          existingEvent.title = newEvent.title
          existingEvent.type = newEvent.type
          existingEvent.location = newEvent.location
          existingEvent.date = newEvent.date
          existingEvent.performers = newEvent.performers
          existingEvent.url = newEvent.url
          existingEvent.source = newEvent.source
        }
      } else {
        // Insert new event
        modelContext.insert(newEvent)
      }
    }
    
    try modelContext.save()
  }
  
  private func fetchEvents() async throws -> [QuiEvent] {
    guard let url = URL(string: Constants.eventsAPIEndpoint) else {
      throw URLError(.badURL)
    }
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      
      let decoder = JSONDecoder()
      
      do {
        return try decoder.decode([QuiEvent].self, from: data)
      } catch {
        throw URLError(.cannotParseResponse)
      }
      
    } catch let error as URLError {
      throw error
    } catch {
      throw URLError(.unknown)
    }
  }
}
