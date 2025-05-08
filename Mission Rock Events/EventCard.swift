//
//  EventCard.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI

struct EventCard: View {
  let event: MREvent
  
  var body: some View {
    VStack {
      HStack {
        Text(event.title)
          .font(.largeTitle)
          .fontWeight(.bold)
          .fontDesign(.rounded)
          .foregroundStyle(event.eventLocation.textColor)
          .multilineTextAlignment(.leading)
        
        Spacer()
      }
      
      Spacer()
      
      Image(event.eventType.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 140, height: 140)
        .shadow(radius: 0.4)
      
      Spacer()
      
      HStack {
        Spacer()
        
        VStack {
          HStack {
            Spacer()
            
            Text(event.eventLocation.title)
              .fontWeight(.bold)
              .fontDesign(.rounded)
              .foregroundStyle(event.eventLocation.textColor)
          }
          
          HStack {
            Spacer()
            
            Text(event.date, style: .date)
            Text(event.time, style: .time)
          }
          .lineLimit(1)
          .minimumScaleFactor(0.4)
          .fontDesign(.rounded)
          .multilineTextAlignment(.trailing)
          .foregroundStyle(event.eventLocation.textColor)
        }
        .frame(maxWidth: .infinity)
      }
    }
    .padding(44)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      event.eventLocation.backgroundColor.opacity(0.6)
    )
  }
}

#Preview {
  VStack {
    EventCard(
      event: MREvent.previewEvent
    )
    .clipShape(RoundedRectangle(cornerRadius: 28))
  }
  .background(
    Image("backdrop")
      .blur(radius: 100)
      .saturation(0.3)
  )
  .padding()
}
