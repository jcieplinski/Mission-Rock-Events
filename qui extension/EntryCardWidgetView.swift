//
//  EntryCardWidgetView.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/8/25.
//

import SwiftUI

struct EntryCardWidgetView: View {
  let event: QuiEvent
  
  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Text(event.title)
          .font(.title3)
          .fontWeight(.bold)
          .fontDesign(.rounded)
          .foregroundStyle(event.eventLocation.textColor)
          .multilineTextAlignment(.leading)
          .minimumScaleFactor(0.4)
          .lineLimit(2)
          .truncationMode(.tail)
        
        Spacer()
      }
      
      Spacer(minLength: 1)
      
      Image(event.eventType.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: 100, maxHeight: 100)
        .shadow(radius: 0.4)
      
      Spacer(minLength: 1)
      
      HStack {
        Spacer()
        
        VStack {
          HStack {
            Spacer()
            
            Text(event.eventLocation.title)
              .font(.caption)
              .minimumScaleFactor(0.6)
              .fontWeight(.bold)
              .fontDesign(.rounded)
              .foregroundStyle(event.eventLocation.textColor)
          }
          
          HStack {
            Spacer()
            
            Text(event.date.formatted(date: .abbreviated, time: .shortened))
          }
          .font(.caption)
          .lineLimit(1)
          .minimumScaleFactor(0.4)
          .fontDesign(.rounded)
          .multilineTextAlignment(.trailing)
          .foregroundStyle(event.eventLocation.textColor)
        }
        .frame(maxWidth: .infinity)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      event.eventLocation.backgroundColor.opacity(0.6)
    )
  }
}

#Preview {
  VStack {
    EntryCardWidgetView(
      event: QuiEvent.previewEvent
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
