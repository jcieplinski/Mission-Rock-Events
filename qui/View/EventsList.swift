//
//  EventsList.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI
import SwiftData
import EventKit

struct EventsList: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Query(sort: \QuiEvent.date) private var events: [QuiEvent]
  
  @State private var ekEvent: EKEvent?
  @State private var showEventEditor: Bool = false
  
  let eventStore = EKEventStore()
  
  var body: some View {
    NavigationStack {
      if events.isEmpty {
        VStack {
          Spacer()
          
          Label("No Events", systemImage: "calendar")
          
          Spacer()
        }
      }
      
      List(events) { event in
        HStack(spacing: 12) {
          Image(event.eventType.image)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
          
          VStack(alignment: .leading) {
            Text(event.title)
              .font(.headline)
            Text(event.date.formatted(date: .abbreviated, time: .shortened))
              .font(.subheadline)
            Text(event.location)
              .font(.caption)
          }
          
          Spacer()
          
          Button {
            createEvent(event: event)
          } label: {
            Image(systemName: "calendar.badge.plus")
              .imageScale(.large)
              .symbolRenderingMode(.hierarchical)
              .foregroundStyle(.primary)
          }
          .buttonStyle(.plain)
        }
      }
      .scrollBounceBehavior(.basedOnSize)
      .navigationTitle("All Events")
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showEventEditor, onDismiss: {
        ekEvent = nil
      }, content: {
        EventEditView(eventStore: eventStore, event: ekEvent)
      })
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            dismiss()
          } label: {
            Label("Done", systemImage: "xmark.circle.fill")
              .symbolRenderingMode(.hierarchical)
              .foregroundStyle(.primary)
          }
        }
      }
    }
  }
  
  private func createEvent(event: QuiEvent) {
    let newEvent = EKEvent(eventStore: eventStore)
    newEvent.title = event.title
    newEvent.startDate = event.date
    newEvent.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: event.date) ?? event.date
    newEvent.location = event.location
    ekEvent = newEvent
    showEventEditor = true
  }
}

#Preview {
  EventsList()
    .modelContainer(for: QuiEvent.self, inMemory: true)
}
