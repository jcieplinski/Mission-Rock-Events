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
  
  let id: UUID
  let title: String
  let type: String
  let location: String
  let date: Date
  let performers: String?
  let url: String?
  let source: String
  
  internal init(
    id: UUID,
    title: String,
    type: String,
    location: String,
    date: Date,
    performers: String?,
    url: String?,
    source: String
  ) {
    self.id = id
    self.title = title
    self.type = type
    self.location = location
    self.date = date
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
    self.performers = event.performers
    self.url = event.url
    self.source = event.source
  }
}
