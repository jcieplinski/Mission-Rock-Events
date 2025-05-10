//
//  QuiApp.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct QuiApp: App {
  @AppStorage(DefaultsKey.lastFetch) private var lastFetch: Date?
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
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          // We only want to fetch new data once per day
          if let lastFetch, lastFetch.isToday() {
            return
          }
          
          Task {
            do {
              try await QuiEventHandler(modelContainer: sharedModelContainer).updateFromWeb()
              lastFetch = Date()
            } catch {
              Logger.swiftData.error("Error fetching new stuff: \(error)")
            }
          }
        }
    }
    .modelContainer(sharedModelContainer)
  }
}
