//
//  NoEventCard.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI

struct NoEventCard: View {
  let nextEvent: QuiEvent?
  
  @Binding var selectedDate: Date
  
  @State private var noEventTitle: String = ""
  @State private var noEventSubtitle: String = ""
  
  var body: some View {
    VStack(spacing: 44) {
      HStack {
        Text(noEventTitle)
          .font(.largeTitle)
          .fontDesign(.rounded)
          .fontWeight(.bold)
          .multilineTextAlignment(.leading)
        
        Spacer()
      }
      
      if let nextEvent {
        HStack {
          VStack(alignment: .leading) {
            Text("Next Event:")
              .font(.subheadline)
              .fontDesign(.rounded)
              .multilineTextAlignment(.leading)
            
            Button {
              selectedDate = nextEvent.date
            } label: {
              VStack(alignment: .leading) {
                Text(
                  nextEvent.date.formatted(
                    date: .abbreviated,
                    time: .shortened
                  )
                )
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                
                Text(nextEvent.title)
                  .fontDesign(.rounded)
                  .multilineTextAlignment(.leading)
              }
            }
            .buttonStyle(.plain)
          }
          
          Spacer()
        }
      }
      
      Spacer()
      
      HStack {
        Spacer()
        
        Text(noEventSubtitle)
          .font(.body)
          .fontDesign(.rounded)
          .fontWeight(.semibold)
          .multilineTextAlignment(.trailing)
      }
    }
    .padding(44)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      ZStack {
        Rectangle()
          .foregroundStyle(.thinMaterial)
        
        Rectangle()
          .foregroundStyle(Color.noEvent).opacity(0.5)
      }
    )
    .onAppear {
      noEventTitle = NoEventTitles.getRandomTitle()
      noEventSubtitle = NoEventTitles.getRandomSubtitle()
    }
  }
}

#Preview {
  @Previewable @State var selectedDate: Date = Date()
  
  VStack {
    NoEventCard(nextEvent: QuiEvent.previewNextEvent, selectedDate: $selectedDate)
      .clipShape(RoundedRectangle(cornerRadius: 28))
      .shadow(radius: 8)
      .padding(22)
  }
  .background(
    Image("backdrop")
      .blur(radius: 100)
      .saturation(0.3)
  )
}
