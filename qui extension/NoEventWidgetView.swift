//
//  NoEventWidgetView.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/8/25.
//

import SwiftUI

struct NoEventWidgetView: View {
  let nextEvent: QuiEvent?
  
  @State private var noEventTitle: String = ""
  @State private var noEventSubtitle: String = ""
  
  var body: some View {
    VStack() {
      HStack {
        Text("No Events Today")
          .font(.title3)
          .fontDesign(.rounded)
          .minimumScaleFactor(0.6)
          .fontWeight(.bold)
          .multilineTextAlignment(.leading)
        
        Spacer()
      }
      
      if let nextEvent {
        HStack {
          VStack(alignment: .leading) {
            Text("Next Event:")
              .font(.caption2)
              .fontDesign(.rounded)
              .multilineTextAlignment(.leading)
            
            Text(
              nextEvent.date.formatted(
                date: .abbreviated,
                time: .shortened
              )
            )
            .font(.caption)
            .fontDesign(.rounded)
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
          }
          
          Spacer()
        }
      }
      
      Spacer()
      
      HStack {
        Spacer()
        
        Text(noEventSubtitle)
          .font(.caption)
          .fontDesign(.rounded)
          .fontWeight(.semibold)
          .multilineTextAlignment(.trailing)
          .minimumScaleFactor(0.6)
      }
    }
    .padding()
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
