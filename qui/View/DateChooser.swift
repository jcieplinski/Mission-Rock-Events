//
//  DateChooser.swift
//  qui
//
//  Created by Joe Cieplinski on 5/9/25.
//

import SwiftUI

struct DateChooser: View {
  @Binding var selectedDate: Date?
  @Binding var showDatePicker: Bool
  
  
  var body: some View {
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
      }
    }
  }
}

#Preview {
  @Previewable @State var selectedDate: Date?
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
