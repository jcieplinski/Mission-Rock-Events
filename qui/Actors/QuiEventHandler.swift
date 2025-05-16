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
  
  public func updateFromWeb(imageCache: ImageCache) async throws {
    do {
      // Fetch new events from web API
      let newEvents = try await fetchEvents()
      let newSpecialEvents = try await fetchSpecialEvents()
      
      Logger.urlSession.info("Fetched \(newEvents.count) events")
      Logger.urlSession.info("Fetched \(newSpecialEvents.count) special events")
      
      // Get existing events from database
      let descriptor = FetchDescriptor<QuiEvent>()
      let existingEvents = try modelContext.fetch(descriptor)
      
      // Collect URLs of images we want to keep
      var imageURLsToKeep = Set<URL>()
      for event in newEvents + newSpecialEvents {
        if let imageURLString = event.imageURL,
           let imageURL = URL(string: imageURLString) {
          imageURLsToKeep.insert(imageURL)
        }
      }
      
      // Clean up image cache
      await imageCache.cleanup(keeping: imageURLsToKeep)
      
      // Update database
      for event in existingEvents {
        modelContext.delete(event)
      }
      
      for newEvent in newEvents {
        modelContext.insert(newEvent)
      }
      
      for newSpecialEvent in newSpecialEvents {
        modelContext.insert(newSpecialEvent)
      }
      
      try modelContext.save()
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
