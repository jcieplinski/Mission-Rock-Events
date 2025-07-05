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
  
  @AppStorage("lastUpdateDate") private var lastUpdateDate: Date = Date.distantPast
  
  public func fetch() async throws -> [QuiEventEntity] {
    let descriptor = FetchDescriptor<QuiEvent>()
    let fetchedEvents = try modelContext.fetch(descriptor).sorted{ $0.date < $1.date }
    
    // Deduplicate events based on their unique ID
    let uniqueEvents = Array(Set(fetchedEvents.map { $0.id })).compactMap { id in
      fetchedEvents.first { $0.id == id }
    }.sorted { $0.date < $1.date }
    
    return uniqueEvents.map(QuiEventEntity.init)
  }
  
  public func updateFromWeb(imageCache: ImageCache) async throws {
    do {
      // Fetch new events from web API
      let newEvents = try await fetchEvents()
      let newSpecialEvents = try await fetchSpecialEvents()
      
      Logger.urlSession.info("Fetched \(newEvents.count) events")
      Logger.urlSession.info("Fetched \(newSpecialEvents.count) special events")
      
      guard !newEvents.isEmpty else { return }
      
      // Get existing events from database
      let descriptor = FetchDescriptor<QuiEvent>()
      let existingEvents = try modelContext.fetch(descriptor)
      
      // Keep track of today's events and future events
      let calendar = Calendar.current
      let today = calendar.startOfDay(for: Date())
      let todaysEvents = existingEvents.filter { calendar.startOfDay(for: $0.date) == today }
      let futureEvents = existingEvents.filter { calendar.startOfDay(for: $0.date) > today }
      
      // Collect URLs of images we want to keep
      var imageURLsToKeep = Set<URL>()
      for event in newEvents + newSpecialEvents + todaysEvents + futureEvents {
        if let imageURLString = event.imageURL,
           let imageURL = URL(string: imageURLString) {
          imageURLsToKeep.insert(imageURL)
        }
      }
      
      // Clean up image cache
      await imageCache.cleanup(keeping: imageURLsToKeep)
      
      // Delete only past events (not today's or future events)
      for event in existingEvents {
        if calendar.startOfDay(for: event.date) < today {
          modelContext.delete(event)
        }
      }
      
      // Combine all new events and remove duplicates based on ID
      let allNewEvents = newEvents + newSpecialEvents
      let uniqueNewEvents = Array(Set(allNewEvents.map { $0.id })).compactMap { id in
        allNewEvents.first { $0.id == id }
      }
      
      // Add new events, checking against existing events to avoid duplicates
      for newEvent in uniqueNewEvents {
        // Check if this event already exists in the database
        let existingDescriptor = FetchDescriptor<QuiEvent>(predicate: #Predicate<QuiEvent> { event in
          event.id == newEvent.id
        })
        let existingEvent = try modelContext.fetch(existingDescriptor).first
        
        if existingEvent == nil {
          modelContext.insert(newEvent)
        } else {
          // Update existing event with new data if needed
          existingEvent?.title = newEvent.title
          existingEvent?.type = newEvent.type
          existingEvent?.location = newEvent.location
          existingEvent?.date = newEvent.date
          existingEvent?.timeTBD = newEvent.timeTBD
          existingEvent?.performers = newEvent.performers
          existingEvent?.url = newEvent.url
          existingEvent?.imageURL = newEvent.imageURL
          existingEvent?.source = newEvent.source
        }
      }
      
      try modelContext.save()
      
      // Update the last update date on successful completion
      lastUpdateDate = Date()
      
    } catch {
      Logger.swiftData.error("Error fetching new events from web API: \(error)")
    }
  }
  
  private func fetchEvents() async throws -> [QuiEvent] {
    guard let url = URL(string: Constants.eventsAPIEndpoint) else {
      throw URLError(.badURL)
    }
    
    do {
      let (data, _) = try await URLSession(configuration: .ephemeral).data(from: url)
      
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
  
  func fetchSpecialEvents() async throws -> [QuiEvent] {
    guard let url = URL(string: Constants.specialEventsAPIEndpoint) else {
      throw URLError(.badURL)
    }
    
    do {
      let (data, _) = try await URLSession(configuration: .ephemeral).data(from: url)
      
      let decoder = JSONDecoder()
      
      do {
        let allSpecialEvents = try decoder.decode([QuiEvent].self, from: data)
        
        // Filter out past events
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return allSpecialEvents.filter { event in
          calendar.startOfDay(for: event.date) >= today
        }
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
