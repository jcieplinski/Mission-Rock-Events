
//
//  NoEventWatch.swift
//  qui
//
//  Created by Joe Cieplinski on 5/9/25.
//

import SwiftUI

struct NoEventWatch: View {
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
      
      Spacer()
      
      if let nextEvent {
        HStack {
          VStack(alignment: .leading) {
            Text("Next Event:")
              .font(.subheadline)
              .fontDesign(.rounded)
              .multilineTextAlignment(.leading)
            
            Text(
              nextEvent.date.formatted(
                date: .abbreviated,
                time: .shortened
              )
            )
            .fontDesign(.rounded)
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .foregroundStyle(nextEvent.eventLocation.textColor)
          }
          
          Spacer()
        }
        
        Spacer()
      }
      
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
    .onAppear {
      noEventTitle = NoEventTitles.getRandomTitle()
      noEventSubtitle = NoEventTitles.getRandomSubtitle()
    }
  }
}
