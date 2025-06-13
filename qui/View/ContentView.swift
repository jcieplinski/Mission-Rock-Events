//
//  ContentView.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI
import SwiftData
import WidgetKit
import EventKitUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.imageCache) private var imageCache
  @Query(sort: \QuiEvent.date) private var events: [QuiEvent]
  
  @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
  @State private var currentEvent: QuiEvent?
  @State private var showDatePicker: Bool = false
  @State private var showEventList: Bool = false
  @State private var showInfo: Bool = false
  @State private var isRefreshing: Bool = false
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
  
  var lastUpdateText: String {
    if lastUpdateDate == Date.distantPast {
      return "Last Updated: Never"
    }
    return "Last Updated: \(lastUpdateDate.formatted(date: .abbreviated, time: .omitted))"
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        if eventsForSelectedDate.isEmpty {
          NoEventCard(
            nextEvent: nextEventAfter,
            selectedDate: $selectedDate
          )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(radius: 8)
            .padding(22)
        } else {
          ScrollView(.horizontal) {
            HStack {
              ForEach(eventsForSelectedDate) { event in
                EventCard(event: event)
                  .clipShape(RoundedRectangle(cornerRadius: 28))
                  .shadow(radius: 8)
                  .containerRelativeFrame(.horizontal, count: 1, spacing: 88)
                  .scrollTransition(.animated, axis: .horizontal) { content, phase in
                    content
                      .scaleEffect(phase.isIdentity ? 1 : 0.98)
                  }
                  .id(event)
              }
            }
            .scrollTargetLayout()
          }
          .onAppear {
            currentEvent = eventsForSelectedDate.first
          }
          .scrollPosition(id: $currentEvent)
          .contentMargins(22, for: .scrollContent)
          .scrollTargetBehavior(.viewAligned)
          .scrollIndicators(.hidden)
        }
      }
      .onChange(of: selectedDate) {
        currentEvent = eventsForSelectedDate.first
      }
      .background(
        ZStack {
          Image("backdrop")
            .saturation(0.2)
          
          Rectangle()
            .foregroundStyle(.ultraThinMaterial)
          
          Rectangle()
            .foregroundStyle(currentEvent?.eventLocation.backgroundColor ?? Color.noEvent)
            .opacity(0.3)
        }
        
      )
      .animation(.default, value: currentEvent)
      .animation(.default, value: selectedDate)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showInfo.toggle()
          } label: {
            Image(systemName: "info.circle")
          }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
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
            .presentationBackground(.thinMaterial)
          }
          
          Spacer()
          
          HStack(spacing: 8) {
            Text(lastUpdateText)
              .font(.caption)
              .foregroundStyle(.secondary)
            
            if events.isEmpty {
              Button {
                Task {
                  await refreshEvents()
                }
              } label: {
                Image(systemName: "arrow.clockwise")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              .disabled(isRefreshing)
            }
          }
          
          Spacer()
          
          Button {
            showEventList.toggle()
          } label: {
            Label("List", systemImage: "list.triangle")
          }
          .sheet(isPresented: $showEventList) {
            EventsList(selectedDate: $selectedDate)
              .presentationBackground(.thinMaterial)
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
      .sheet(isPresented: $showInfo) {
        InfoView()
          .presentationBackground(.thinMaterial)
      }
      .navigationTitle(navigationTitle)
#if os(iOS)
      .toolbarTitleDisplayMode(.inlineLarge)
#endif
    }
  }
  
  private func refreshEvents() async {
    isRefreshing = true
    
    do {
      let handler = QuiEventHandler(modelContainer: modelContext.container)
      try await handler.updateFromWeb(imageCache: imageCache)
    } catch {
      // Handle error if needed
      print("Error refreshing events: \(error)")
    }
    
    isRefreshing = false
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
