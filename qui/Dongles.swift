//
//  Dongles.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//

import Foundation

extension Date {
  func isToday() -> Bool {
    Calendar.current.startOfDay(for: Date()) == Calendar.current.startOfDay(for: self)
  }
  
  func isYesterday() -> Bool {
    let calendar = Calendar.current
    
    guard let yesterday = Date.yesterday() else { return false }
    
    return calendar.startOfDay(for: yesterday) == calendar.startOfDay(for: self)
  }
  
  static func yesterday() -> Date? {
    return Calendar.current.date(byAdding: .day, value: -1, to: Date())
  }
  
  static func dateStringToDate(dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.date(from: dateString) ?? Date()
  }
}
