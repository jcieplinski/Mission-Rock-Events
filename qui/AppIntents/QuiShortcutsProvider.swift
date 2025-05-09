//
//  QuiShortcutsProvider.swift
//  qui
//
//  Created by Joe Cieplinski on 5/8/25.
//

import AppIntents

struct QuiShortcutsProvider: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: TodayEventsIntent(),
      phrases: [
        "Any \(.applicationName) events today",
        "Show me today's \(.applicationName) events",
        "Show me \(.applicationName) events"
      ],
      shortTitle: "Today's qui Events",
      systemImageName: "ticket"
    )
    
    AppShortcut(
      intent: EventsForDateIntent(),
      phrases: [
        "Check \(.applicationName) events for a date",
        "What's happening on \(.applicationName)?",
        "Show me \(.applicationName) events for",
      ],
      shortTitle: "qui Events for a Specific Day",
      systemImageName: "calendar.badge.clock"
    )
  }
}
