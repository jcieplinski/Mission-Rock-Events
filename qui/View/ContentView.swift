//
//  ContentView.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \QuiEvent.date) private var events: [QuiEvent]
  
  @State private var selectedDate: Date?
  @State private var currentEvent: QuiEvent?
  @State private var showDatePicker: Bool = false
  @State private var showEventList: Bool = false
  
  let dateFormatter = DateFormatter()
  
  var todayEvents: [QuiEvent] {
    return events.filter { $0.date.isToday() }.sorted { $0.date < $1.date }
  }
  
  var eventsForSelectedDate: [QuiEvent] {
    guard let selectedDate else { return todayEvents }
    
    return events.filter {
      Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: selectedDate)
    }.sorted { $0.date < $1.date }
  }

  var nextEventAfter: QuiEvent? {
    guard let selectedDate else { return nil }
    
    return events
      .filter { $0.date > selectedDate }
      .sorted { $0.date < $1.date }
      .first
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        if eventsForSelectedDate.isEmpty {
          NoEventCard(nextEvent: nextEventAfter)
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
      .padding(.bottom, 11)
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
      .toolbar {
        ToolbarItemGroup(placement: .automatic) {
          Button {
            showDatePicker.toggle()
          } label: {
            Label("Calendar", systemImage: "calendar")
          }
          .sheet(isPresented: $showDatePicker) {
            NavigationStack {
              DatePicker(
                "Select Date",
                selection: Binding(
                  get: { selectedDate ?? Date() },
                  set: { selectedDate = $0 }
                ),
                in: Date()...,
                displayedComponents: [.date]
              )
              .padding()
              .datePickerStyle(.graphical)
              .presentationDetents([.medium])
              .navigationTitle("Calendar")
              .navigationBarTitleDisplayMode(.inline)
              .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                  Button {
                    showDatePicker = false
                  } label: {
                    Label("Done", systemImage: "xmark.circle.fill")
                      .symbolRenderingMode(.hierarchical)
                      .foregroundStyle(.primary)
                  }
                  .tint(.primary)
                }
              }
            }
          }
          
          Button {
            showEventList.toggle()
          } label: {
            Label("List", systemImage: "list.triangle")
          }
          .sheet(isPresented: $showEventList) {
            EventsList()
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
      .navigationTitle((selectedDate == nil ? "Today" : selectedDate?.formatted(date: .abbreviated, time: .omitted)) ?? "")
      .toolbarTitleDisplayMode(.inlineLarge)
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
      date: Date(),
      time: Date.dateStringToDate(dateString: "15:00"),
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
