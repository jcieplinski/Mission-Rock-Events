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
  
  static func dateStringToDate(dateString: String, timeString: String) -> (date: Date, timeTBD: Bool) {
    var timeTBD: Bool = false
    let dateFormatter = DateFormatter()
    
    if !timeString.contains(":") {
      timeTBD = true
      dateFormatter.dateFormat = "YYYY-MM-dd"
      return (date: dateFormatter.date(from: dateString) ?? Date(), timeTBD: timeTBD)
    } else {
      dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
      return (date: dateFormatter.date(from: "\(dateString) \(timeString)") ?? Date(), timeTBD: timeTBD)
    }
  }
  
  static func dateToStringDateStringTime(date: Date) -> (stringDate: String, stringTime: String) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
    
    let string = dateFormatter.string(from: date)
    let split = string.split(separator: " ")
    
    return (stringDate: String(split[0]), stringTime: String(split[1]))
  }
}
