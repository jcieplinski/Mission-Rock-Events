//
//  EventType.swift
//  qui
//
//  Created by Joe Cieplinski on 5/8/25.
//

import Foundation

enum EventType: String, Codable, CaseIterable {
  case sports
  case concert
  case other
  
  init?(rawValue: String) {
    switch rawValue.lowercased() {
    case "sports":
      self = .sports
    case "concert", "special event":
      self = .concert
    default:
      self = .other
    }
  }
}
