//
//  ContentView.swift
//  qui watch Watch App
//
//  Created by Joe Cieplinski on 5/9/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \QuiEvent.date) private var events: [QuiEvent]
  
  @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
  @State private var currentEvent: QuiEvent?
  @State private var showDatePicker: Bool = false
  @State private var showEventList: Bool = false
  
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
  
  var body: some View {
    NavigationStack {
      VStack {
        if eventsForSelectedDate.isEmpty {
          NoEventWatch(nextEvent: nextEventAfter)
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
      .onChange(of: selectedDate) {
        currentEvent = eventsForSelectedDate.first
      }
      .sheet(isPresented: $showEventList) {
        EventsList()
      }
      .background(
        ZStack {
          Image("backdrop")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .opacity(0.4)
            .saturation(0)
          
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
          .opacity(0.4)
          .ignoresSafeArea()
        }
          .ignoresSafeArea()
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
              showDatePicker: $showDatePicker
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
          Button {
            deleteAllEvents()
          } label: {
            Label("Delete Fake Events", systemImage: "trash")
          }
          
          Spacer()
          
          Button {
            addFakeEvent()
          } label: {
            Label("Add Fake Event", systemImage: "plus")
          }
        }
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
  
  private func addFakeEvent() {
    let eventType = getRandomEventType()
    
    let event = QuiEvent(
      id: UUID(),
      title: "This is an event with a longer name",
      type: eventType.rawValue,
      location: eventType == .baseball ? EventLocation.oraclePark.title : EventLocation.chaseCenter.title,
      date: Calendar.current.date(bySettingHour: 19, minute: 30, second: 0, of: Date()) ?? Date(),
      performers: eventType == .baseball ? "SF Giants" : "GS Warriors",
      url: "https://www.mlb.com/giants",
      source: EventSource.seatgeek.rawValue
    )
    
    modelContext.insert(event)
    
    Task {
      try? await Task.sleep(for: .seconds(1))
      WidgetCenter.shared.reloadAllTimelines()
    }
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
