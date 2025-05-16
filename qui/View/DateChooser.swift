//
//  DateChooser.swift
//  qui
//
//  Created by Joe Cieplinski on 5/9/25.
//

import SwiftUI

struct DateChooser: View {
  @Binding var selectedDate: Date
  @Binding var showDatePicker: Bool
  
  
  var body: some View {
    NavigationStack {
      DatePicker(
        "Select Date",
        selection: $selectedDate,
        in: Calendar.current.startOfDay(for: Date())...,
        displayedComponents: [.date]
      )
      .padding()
      #if os(watchOS)
      .datePickerStyle(.automatic)
      #else
      .datePickerStyle(.graphical)
      #endif
      #if os(iOS)
      .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium])
      #endif
      .navigationTitle("Calendar")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        #if os(watchOS)
        ToolbarItem(placement: .bottomBar) {
          Button {
            selectedDate = Date()
            showDatePicker = false
          } label: {
            Text("Go to Today")
          }
        }
        #else
        ToolbarItem(placement: .topBarLeading) {
          Button {
            selectedDate = Date()
          } label: {
            Text("Go to Today")
          }
        }
        
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
        #endif
      }
    }
  }
}

#Preview {
  @Previewable @State var selectedDate: Date = Date()
  @Previewable @State var showDatePicker: Bool = false
  
  VStack {
    EmptyView()
  }
  .sheet(isPresented: .constant(true)) {
    DateChooser(
      selectedDate: $selectedDate,
      showDatePicker: $showDatePicker
    )
  }
}
