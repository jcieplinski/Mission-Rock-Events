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
  @State private var searchText: String = ""
  @State private var filteredEvents: [QuiEvent] = []
  
  @Binding var selectedDate: Date
  
  let eventStore = EKEventStore()
  
  private func updateFilteredEvents() {
    if searchText.isEmpty {
      filteredEvents = events
    } else {
      filteredEvents = events.filter { event in
        event.title.localizedCaseInsensitiveContains(searchText) ||
        event.location.localizedCaseInsensitiveContains(searchText) ||
        event.type.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
  
  var body: some View {
    NavigationStack {
      if filteredEvents.isEmpty {
        VStack {
          Spacer()
          
          Label("No Events", systemImage: "calendar")
          
          Spacer()
        }
      }
      
      List(filteredEvents) { event in
        Button {
          selectedDate = event.date
          dismiss()
        } label: {
          HStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: event.imageURL ?? "")) { image in
              image
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            } placeholder: {
              ProgressView()
            }
            
            VStack(alignment: .leading) {
              Text(event.title)
                .font(.headline)
              Text(event.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
              Text(event.location)
                .font(.caption)
            }
            
#if os(iOS)
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
#endif
          }
        }
        .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
      }
      .searchable(text: $searchText, placement: .automatic)
      .onChange(of: searchText) { _, _ in
        updateFilteredEvents()
      }
      .onChange(of: events) { _, _ in
        updateFilteredEvents()
      }
      .onAppear {
        updateFilteredEvents()
      }
      .scrollBounceBehavior(.basedOnSize)
      .scrollContentBackground(.hidden)
      .navigationTitle("All Events")
      .navigationBarTitleDisplayMode(.inline)
#if os(iOS)
      .sheet(isPresented: $showEventEditor, onDismiss: {
        ekEvent = nil
      }, content: {
        EventEditView(eventStore: eventStore, event: $ekEvent)
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
#endif
    }
  }
  
  private func createEvent(event: QuiEvent) {
    ekEvent = EKEvent(eventStore: eventStore)
    ekEvent?.title = event.title
    ekEvent?.startDate = event.date
    ekEvent?.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: event.date) ?? event.date
    ekEvent?.location = event.location
    showEventEditor = true
  }
}

#Preview {
  @Previewable @State var selectedDate: Date = Date()
  EventsList(selectedDate: $selectedDate)
    .modelContainer(for: QuiEvent.self, inMemory: true)
}
