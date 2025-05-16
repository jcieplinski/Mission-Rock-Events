//
//  InfoView.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/15/25.
//

import SwiftUI
#if os(iOS)
import MessageUI
#endif

struct InfoView: View {
  @Environment(\.dismiss) private var dismiss
  
  @State private var showingMailComposer: Bool = false
  
#if os(iOS)
  @State var result: Result<MFMailComposeResult, Error>? = nil
#endif
  
  var body: some View {
    NavigationStack {
      List {
        Section {
          Link(destination: URL(string: "https://seatgeek.com")!) {
            HStack {
              Text("Event data provided by SeatGeek.")
              Spacer()
              Image("SeatGeek")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            }
            .padding()
          }
          .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
          
          Text("All images and logos property of their respective owners.")
            .padding()
            .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
        }
        
        Section {
          VStack(spacing: 12) {
            Image("Joe")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 60, height: 60)
              .clipShape(Circle())
            Text("Created by Joe in Mission Rock, San Francisco, CA. This app is a labor of love. If you enjoy using it, I'd appreciate a rating or review.")
          }
          .padding()
          .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
        }
        
        Section {
          Link(destination: URL(string: "https://apps.apple.com/app/id6745844640?action=write-review")!) {
            HStack {
              Text("Review on the App Store")
              Spacer()
              Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            }
          }
          .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
        }
        
#if os(iOS)
        if MFMailComposeViewController.canSendMail() {
          Button("Send Feedback") {
            showingMailComposer = true
          }
          .fontWeight(.semibold)
          .foregroundStyle(Color.black)
          .listRowBackground(
            ZStack {
              Rectangle().foregroundStyle(.ultraThinMaterial)
              Color.oracleOrange.opacity(0.75)
            }
          )
        }
        
        Section {
          Link(destination: URL(string: "https://apple.co/3w27sUw")!) {
            HStack {
              Text("RECaf")
              Spacer()
              Image("recafIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
            }
          }
          .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
          
          Link(destination: URL(string: "https://apple.co/448kUCP")!) {
            HStack {
              Text("Fin")
              Spacer()
              Image("finIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
            }
          }
          .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
          
          Link(destination: URL(string: "https://apple.co/3U4iUqI")!) {
            HStack {
              Text("x2y")
              Spacer()
              Image("x2yIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
            }
          }
          .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
          
          Link(destination: URL(string: "https://apple.co/4cCZ7ra")!) {
            HStack {
              Text("The Last Word")
              Spacer()
              Image("stirred")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
            }
          }
          .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
        } header: {
          Text("Other Apps by Joe")
        }
#endif
      }
#if os(iOS)
      .scrollBounceBehavior(.basedOnSize)
      .scrollContentBackground(.hidden)
      .sheet(isPresented: $showingMailComposer) {
        MailView(result: $result)
      }
#endif
      .navigationTitle("About")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
#if os(iOS)
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
#endif
      }
    }
  }
}

#Preview {
  InfoView()
}
