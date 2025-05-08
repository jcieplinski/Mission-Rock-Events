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
  @Query(sort: \MREvent.date) private var events: [MREvent]
  
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
            HStack {
              Text(event.date.formatted(date: .abbreviated, time: .omitted))
              Text(event.time.formatted(date: .omitted, time: .shortened))
            }
            .font(.subheadline)
            Text(event.location)
              .font(.caption)
          }
          
          Spacer()
          
          Button {
            let eventStore = EKEventStore()
            eventStore.requestWriteOnlyAccessToEvents { granted, error in
              if granted {
                let calendarEvent = EKEvent(eventStore: eventStore)
                calendarEvent.title = event.title
                calendarEvent.startDate = event.date
                calendarEvent.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: event.date) ?? event.date
                calendarEvent.location = event.location
                calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                  try eventStore.save(calendarEvent, span: .thisEvent)
                } catch {
                  print("Error saving event to calendar: \(error)")
                }
              }
            }
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
}

#Preview {
  EventsList()
    .modelContainer(for: MREvent.self, inMemory: true)
}
