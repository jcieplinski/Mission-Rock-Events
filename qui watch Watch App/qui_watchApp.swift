//
//  qui_watchApp.swift
//  qui watch Watch App
//
//  Created by Joe Cieplinski on 5/9/25.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct qui_watchApp: App {
  @AppStorage(DefaultsKey.lastFetch) private var lastFetch: Date?
  @State private var imageCache: ImageCache? = ImageCache(diskCache: DiskImageCache())
  
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      QuiEvent.self,
    ])
    
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, allowsSave: true)
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .task {
          if imageCache == nil {
            imageCache = await ImageCache(diskCache: DiskImageCache())
          }
        }
        .onAppear {
          // We only want to fetch new data once per day
#if DEBUG
#else
          if let lastFetch, lastFetch.isToday() {
            return
          }
#endif
          
          Task {
            do {
              try await QuiEventHandler(modelContainer: sharedModelContainer).updateFromWeb(imageCache: imageCache!)
              lastFetch = Date()
            } catch {
              Logger.swiftData.error("Error fetching new stuff: \(error)")
            }
          }
        }
    }
    .modelContainer(sharedModelContainer)
    .environment(\.imageCache, imageCache ?? ImageCache(diskCache: DiskImageCache()))
  }
}
