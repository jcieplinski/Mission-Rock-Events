//
//  QuiEventEntity.swift
//  qui
//
//  Created by Joe Cieplinski on 5/8/25.
//

import SwiftData
import AppIntents

struct QuiEventEntity: Identifiable, AppEntity {
  static var defaultQuery = QuiEventQuery()
  
  static var typeDisplayRepresentation: TypeDisplayRepresentation = "Event"
  
  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(title)")
  }
  
  var id: UUID
  var title: String
  var type: String
  var location: String
  var date: Date
  var time: Date
  var performers: String
  var url: String
  var source: String
  
  internal init(
    id: UUID,
    title: String,
    type: String,
    location: String,
    date: Date,
    time: Date,
    performers: String,
    url: String,
    source: String
  ) {
    self.id = id
    self.title = title
    self.type = type
    self.location = location
    self.date = date
    self.time = time
    self.performers = performers
    self.url = url
    self.source = source
  }
  
  init(event: QuiEvent) {
    self.id = event.id
    self.title = event.title
    self.type = event.type
    self.location = event.location
    self.date = event.date
    self.time = event.time
    self.performers = event.performers
    self.url = event.url
    self.source = event.source
  }
}
