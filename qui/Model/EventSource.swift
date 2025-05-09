//
//  EventSource.swift
//  qui
//
//  Created by Joe Cieplinski on 5/8/25.
//

import Foundation

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
