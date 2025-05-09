//
//  EventCardWatch.swift
//  qui
//
//  Created by Joe Cieplinski on 5/9/25.
//

import SwiftUI

struct EventCardWatch: View {
  let event: QuiEvent
  
  var body: some View {
    VStack(spacing: 4) {
      HStack {
        Text(event.title)
          .font(.title3)
          .fontWeight(.bold)
          .fontDesign(.rounded)
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
      }
      
      Spacer()
      
      Image(event.eventType.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: 100, maxHeight: 100)
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
          }
          
          HStack {
            Spacer()
            
            Text(event.date.formatted(date: .abbreviated, time: .shortened))
          }
          .lineLimit(1)
          .minimumScaleFactor(0.4)
          .fontDesign(.rounded)
          .multilineTextAlignment(.trailing)
        }
        .frame(maxWidth: .infinity)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  EventCardWatch(
    event: QuiEvent.previewEvent
  )
}
