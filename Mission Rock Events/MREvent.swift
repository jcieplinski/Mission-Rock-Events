//
//  MREvent.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import SwiftUI
import SwiftData

@Model
final class MREvent: Codable, Equatable {
  internal init(
    title: String,
    type: String,
    location: String,
    date: Date,
    time: Date,
    performers: String,
    url: String,
    source: String
  ) {
    self.title = title
    self.type = type
    self.location = location
    self.date = date
    self.time = time
    self.performers = performers
    self.url = url
    self.source = source
  }
  
  var title: String
  var type: String
  var location: String
  var date: Date
  var time: Date
  var performers: String
  var url: String
  var source: String
  
  var eventType: EventType {
    return EventType(rawValue: type) ?? .other
  }
  
  var eventSource: EventSource {
    return EventSource(rawValue: source) ?? .other
  }
  
  var eventLocation: EventLocation {
    return EventLocation(text: location) ?? .other
  }
  
  // MARK: - Codable
  
  enum CodingKeys: String, CodingKey {
    case title
    case type
    case location
    case date
    case time
    case performers
    case url
    case source
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    title = try container.decode(String.self, forKey: .title)
    type = try container.decode(String.self, forKey: .type)
    location = try container.decode(String.self, forKey: .location)
    date = try container.decode(Date.self, forKey: .date)
    time = try container.decode(Date.self, forKey: .time)
    performers = try container.decode(String.self, forKey: .performers)
    url = try container.decode(String.self, forKey: .url)
    source = try container.decode(String.self, forKey: .source)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(title, forKey: .title)
    try container.encode(type, forKey: .type)
    try container.encode(location, forKey: .location)
    try container.encode(date, forKey: .date)
    try container.encode(time, forKey: .time)
    try container.encode(performers, forKey: .performers)
    try container.encode(url, forKey: .url)
    try container.encode(source, forKey: .source)
  }
  
  static var previewEvent: MREvent {
    return MREvent(
      title: "SF Giants vs. Colorado Rockies",
      type: EventType.baseball.rawValue,
      location: EventLocation.oraclePark.title,
      date: Date(),
      time: Date.dateStringToDate(dateString: "19:00"),
      performers: "SF Giants",
      url: "https://mlb.com/giants",
      source: "SeatGeek API"
    )
  }
  
  static var previewNextEvent: MREvent {
    return MREvent(
      title: "SF Giants vs. Colorado Rockies",
      type: EventType.baseball.rawValue,
      location: EventLocation.oraclePark.title,
      date: Date(timeIntervalSinceNow: 432000),
      time: Date.dateStringToDate(dateString: "19:00"),
      performers: "SF Giants",
      url: "https://mlb.com/giants",
      source: "SeatGeek API"
    )
  }
}


enum EventType: String, Codable, CaseIterable {
  case baseball
  case basketball
  case concert
  case other
  
  var image: String {
    switch self {
    case .baseball:
      return "giantsLogo"
    case .basketball:
      return "warriorsLogo"
    case .concert:
      return "concert"
    case .other:
      return ""
    }
  }
}

enum EventSource: String, Codable {
  case seatgeek
  case manual
  case other
  
  init?(rawValue: String) {
    switch rawValue {
    case "SeatGeek API":
      self = .seatgeek
    case "manual":
      self = .manual
    default:
      self = .other
    }
  }
}

enum EventLocation: String, Codable {
  case oraclePark
  case chaseCenter
  case other
  
  init?(text: String) {
    switch text {
    case "Oracle Park":
      self = .oraclePark
    case "Chase Center":
      self = .chaseCenter
    default:
      self = .other
    }
  }
  
  var title: String {
    switch self {
    case .oraclePark:
      return "Oracle Park"
    case .chaseCenter:
      return "Chase Center"
    case .other:
      return "Other"
    }
  }
  
  var backgroundColor: Color {
    switch self {
    case .oraclePark:
      return .oracleOrange
    case .chaseCenter:
      return .chaseBlue
    case .other:
      return .otherRed
    }
  }
  
  var textColor: Color {
    switch self {
    case .oraclePark:
      return .primary
    case .chaseCenter:
      return .white
    case .other:
      return .white
    }
  }
}
