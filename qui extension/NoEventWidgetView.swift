//
//  NoEventWidgetView.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/8/25.
//

import SwiftUI
import WidgetKit

struct NoEventWidgetView: View {
  @Environment(\.widgetFamily) var family
  let nextEvent: QuiEvent?
  
  @State private var noEventTitle: String = "No Events Today"
  @State private var noEventSubtitle: String = "Check back later!"
  
  var body: some View {
    VStack() {
      HStack {
        Text(noEventTitle)
          .font(.title3)
          .fontDesign(.rounded)
          .minimumScaleFactor(0.6)
          .fontWeight(.bold)
          .multilineTextAlignment(.leading)
        
        Spacer()
      }
      
      if family != .systemSmall {
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
          .padding(.top, 12)
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
      // For widgets, use simple static text to avoid complexity
      noEventTitle = "No Events Today"
      noEventSubtitle = "Check back later!"
    }
  }
}
