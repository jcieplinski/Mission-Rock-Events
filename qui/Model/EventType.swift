//
//  EventType.swift
//  qui
//
//  Created by Joe Cieplinski on 5/8/25.
//

import Foundation

enum EventType: String, Codable, CaseIterable {
  case baseball
  case basketball
  case concert
  case other
  
  init?(rawValue: String) {
    switch rawValue.lowercased() {
    case "baseball", "baseball game":
      self = .baseball
    case "basketball", "basketball game":
      self = .basketball
    case "concert", "special event":
      self = .concert
    default:
      self = .other
    }
  }
  
  var image: String {
    switch self {
    case .baseball:
      return "giantsLogo"
    case .basketball:
      return "warriorsLogo"
    case .concert:
      return "concert"
    case .other:
      return "otherEvent"
    }
  }
}
