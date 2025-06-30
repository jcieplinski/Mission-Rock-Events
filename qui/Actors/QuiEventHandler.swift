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
  
  public func fetch() throws -> [QuiEventEntity] {
    let descriptor = FetchDescriptor<QuiEvent>()
    let fetchedEvents = try modelContext.fetch(descriptor).sorted{ $0.date < $1.date }
    
    return fetchedEvents.map(QuiEventEntity.init)
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
      
      // Keep track of today's events
      let calendar = Calendar.current
      let today = calendar.startOfDay(for: Date())
      let todaysEvents = existingEvents.filter { calendar.startOfDay(for: $0.date) == today }
      
      // Collect URLs of images we want to keep
      var imageURLsToKeep = Set<URL>()
      for event in newEvents + newSpecialEvents + todaysEvents {
        if let imageURLString = event.imageURL,
           let imageURL = URL(string: imageURLString) {
          imageURLsToKeep.insert(imageURL)
        }
      }
      
      // Clean up image cache
      await imageCache.cleanup(keeping: imageURLsToKeep)
      
      // Delete all events except today's
      for event in existingEvents {
        if !todaysEvents.contains(where: { $0.id == event.id }) {
          modelContext.delete(event)
        }
      }
      
      // Combine all new events and remove duplicates based on ID
      let allNewEvents = newEvents + newSpecialEvents
      let uniqueNewEvents = Array(Set(allNewEvents.map { $0.id })).compactMap { id in
        allNewEvents.first { $0.id == id }
      }
      
      // Add new events, checking against both today's events and existing events
      for newEvent in uniqueNewEvents {
        let isAlreadyInToday = todaysEvents.contains(where: { $0.id == newEvent.id })
        let isAlreadyInExisting = existingEvents.contains(where: { $0.id == newEvent.id })
        
        if !isAlreadyInToday && !isAlreadyInExisting {
          modelContext.insert(newEvent)
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
