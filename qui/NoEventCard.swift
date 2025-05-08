//
//  NoEventCard.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI

struct NoEventCard: View {
  let nextEvent: MREvent?
  
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
      
      Spacer()
      
      if let nextEvent {
        HStack {
          VStack(alignment: .leading) {
            Text("Next Event:")
              .font(.subheadline)
              .fontDesign(.rounded)
              .multilineTextAlignment(.leading)
            
            HStack {
              Text(nextEvent.date, style: .date)
              Text(nextEvent.time, style: .time)
            }
            .fontDesign(.rounded)
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .foregroundStyle(nextEvent.eventLocation.textColor)
            
            Text(nextEvent.title)
              .fontDesign(.rounded)
              .multilineTextAlignment(.leading)
          }
          
          Spacer()
        }
        
        Spacer()
      }
      
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
  VStack {
    NoEventCard(nextEvent: MREvent.previewNextEvent)
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
