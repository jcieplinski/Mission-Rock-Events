//
//  EventLocation.swift
//  qui
//
//  Created by Joe Cieplinski on 5/8/25.
//

import SwiftUI

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
