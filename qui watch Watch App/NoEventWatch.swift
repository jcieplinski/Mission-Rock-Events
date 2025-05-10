
//
//  NoEventWatch.swift
//  qui
//
//  Created by Joe Cieplinski on 5/9/25.
//

import SwiftUI

struct NoEventWatch: View {
  let nextEvent: QuiEvent?
  
  @Binding var selectedDate: Date
  
  @State private var noEventTitle: String = ""
  @State private var noEventSubtitle: String = ""
  
  var body: some View {
    VStack() {
      HStack {
        Text("No Events Today")
          .font(.title2)
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
              .font(.subheadline)
              .fontDesign(.rounded)
              .multilineTextAlignment(.leading)
            
            Button {
              selectedDate = nextEvent.date
            } label: {
              Text(
                nextEvent.date.formatted(
                  date: .abbreviated,
                  time: .shortened
                )
              )
              .fontDesign(.rounded)
              .fontWeight(.bold)
              .multilineTextAlignment(.leading)
            }
            .buttonStyle(.plain)
          }
          
          Spacer()
        }
      }
      
      Spacer(minLength: 1)
      
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
