//
//  ContentView.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \MREvent.date) private var events: [MREvent]
  
  @State private var selectedDate: Date?
  @State private var currentEvent: MREvent?
  @State private var showDatePicker: Bool = false
  @State private var showEventList: Bool = false
  
  let dateFormatter = DateFormatter()
  
  var todayEvents: [MREvent] {
    return events.filter { $0.date.isToday() }.sorted { $0.date < $1.date }
  }
  
  var eventsForSelectedDate: [MREvent] {
    guard let selectedDate else { return todayEvents }
    
    return events.filter {
      Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: selectedDate)
    }.sorted { $0.date < $1.date }
  }

  var nextEventAfter: MREvent? {
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
          .scrollPosition(id: $currentEvent)
          .contentMargins(22, for: .scrollContent)
          .scrollTargetBehavior(.viewAligned)
          .scrollIndicators(.hidden)
        }
      }
      .onChange(of: selectedDate) {
        currentEvent = eventsForSelectedDate.first
      }
      .padding(.bottom, 22)
      .background(
        ZStack {
          Image("backdrop")
            .saturation(0.2)
          
          Rectangle()
            .foregroundStyle(.ultraThinMaterial)

            Rectangle()
              .foregroundStyle(currentEvent?.eventLocation.backgroundColor ?? .noEventGreen)
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
          .fullScreenCover(isPresented: $showEventList) {
            EventsList()
          }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
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
  
  private func addFakeEvent() {
    let eventType = getRandomEventType()

    let event = MREvent(
      title: "This is an event",
      type: eventType.rawValue,
      location: eventType == .baseball ? EventLocation.oraclePark.title : EventLocation.chaseCenter.title,
      date: Date(),
      time: Date.dateStringToDate(dateString: "15:00"),
      performers: eventType == .baseball ? "SF Giants" : "GS Warriors",
      url: "https://www.mlb.com/giants",
      source: EventSource.seatgeek.rawValue
    )
    
    modelContext.insert(event)
  }
  
  private func getRandomEventType() -> EventType {
    let randomIndex = Int.random(in: 0..<EventType.allCases.count)
    return EventType.allCases[randomIndex]
  }
}

#Preview {
  ContentView()
    .modelContainer(for: MREvent.self, inMemory: true)
}
