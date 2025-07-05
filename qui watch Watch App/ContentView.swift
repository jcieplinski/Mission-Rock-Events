//
//  ContentView.swift
//  qui watch Watch App
//
//  Created by Joe Cieplinski on 5/9/25.
//

import SwiftUI
import SwiftData
import WidgetKit
import WatchKit

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.imageCache) private var imageCache
  @State private var events: [QuiEvent] = []
  
  @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
  @State private var currentEvent: QuiEvent?
  @State private var showDatePicker: Bool = false
  @State private var showEventList: Bool = false
  @State private var showInfo: Bool = false
  @State private var isBackgroundRefreshing: Bool = false
  @AppStorage("lastUpdateDate") private var lastUpdateDate: Date = Date.distantPast
  
  let dateFormatter = DateFormatter()
  
  var navigationTitle: String {
    if selectedDate.isToday() {
      return "Today"
    }
    
    return selectedDate.formatted(date: .abbreviated, time: .omitted)
  }
  
  var eventsForSelectedDate: [QuiEvent] {
    return events.filter {
      Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: selectedDate)
    }.sorted { $0.date < $1.date }
  }
  
  var nextEventAfter: QuiEvent? {
    return events
      .filter { $0.date > selectedDate }
      .sorted { $0.date < $1.date }
      .first
  }
  
  private func loadEvents() {
    do {
      // Load existing events immediately from database (synchronous)
      let descriptor = FetchDescriptor<QuiEvent>()
      events = try modelContext.fetch(descriptor).sorted { $0.date < $1.date }
      
      // Check if we need to refresh events in the background
      let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
      if lastUpdateDate < oneHourAgo {
        // Fetch updates in the background without blocking the UI
        isBackgroundRefreshing = true
        Task {
          await refreshEvents()
          isBackgroundRefreshing = false
        }
      }
    } catch {
      print("Error loading events: \(error)")
    }
  }
  
  private func refreshEvents() async {
    do {
      let handler = QuiEventHandler(modelContainer: modelContext.container)
      try await handler.updateFromWeb(imageCache: imageCache)
      // Reload events after updating
      loadEvents()
    } catch {
      print("Error refreshing events: \(error)")
    }
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        if eventsForSelectedDate.isEmpty {
          NoEventWatch(
            nextEvent: nextEventAfter,
            selectedDate: $selectedDate
          )
        } else {
          TabView(selection: $currentEvent) {
            ForEach(eventsForSelectedDate) { event in
              EventCardWatch(event: event)
                .tag(event)
            }
          }
          .onAppear {
            if currentEvent == nil {
              currentEvent = eventsForSelectedDate.first
            }
          }
          .tabViewStyle(.page)
        }
      }
      .ignoresSafeArea([])
      .onAppear {
        loadEvents()
      }
      .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
        loadEvents()
      }
      .onChange(of: selectedDate) {
        currentEvent = eventsForSelectedDate.first
      }
      .sheet(isPresented: $showEventList) {
        EventsList(selectedDate: $selectedDate)
      }
      .sheet(isPresented: $showInfo) {
        InfoView()
      }
      .background(
        ZStack {
          Image("backdrop")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .opacity(0.4)
            .saturation(0)
            .ignoresSafeArea()
          
          Rectangle()
            .foregroundStyle(.thinMaterial)
            .ignoresSafeArea()
          
          LinearGradient(
            colors: [
              currentEvent?.eventLocation.backgroundColor ?? Color.noEvent,
              Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
          )
          .ignoresSafeArea()
          .opacity(0.4)
        }
      )
      .animation(.default, value: currentEvent)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            showDatePicker.toggle()
          } label: {
            Label("Calendar", systemImage: "calendar")
          }
          .sheet(isPresented: $showDatePicker) {
            DateChooser(
              selectedDate: $selectedDate,
              showDatePicker: $showDatePicker,
              currentEvent: currentEvent
            )
          }
        }
          
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showEventList.toggle()
          } label: {
            Label("List", systemImage: "list.triangle")
          }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
          HStack {
            Button {
              showInfo.toggle()
            } label: {
              Image(systemName: "info.circle")
            }
            
            Spacer()
            
            Button {
              Task {
                await refreshEvents()
              }
            } label: {
              Image(systemName: "arrow.clockwise")
            }
          }
        }
        
//        ToolbarItemGroup(placement: .bottomBar) {
//          Button {
//            deleteAllEvents()
//          } label: {
//            Label("Delete Fake Events", systemImage: "trash")
//          }
//          
//          Spacer()
//          
//          Button {
//            addFakeEvent()
//          } label: {
//            Label("Add Fake Event", systemImage: "plus")
//          }
//        }
      }
      .navigationTitle(navigationTitle)
#if os(iOS)
      .toolbarTitleDisplayMode(.inlineLarge)
#endif
    }
  }
  
  private func deleteAllEvents() {
    events.forEach { event in
      modelContext.delete(event)
    }
    
    try? modelContext.save()
    
    currentEvent = nil
    WidgetCenter.shared.reloadAllTimelines()
  }
  
  private func getRandomEventType() -> EventType {
    let randomIndex = Int.random(in: 0..<EventType.allCases.count)
    return EventType.allCases[randomIndex]
  }
}

#Preview {
  ContentView()
    .modelContainer(for: QuiEvent.self, inMemory: true)
}
