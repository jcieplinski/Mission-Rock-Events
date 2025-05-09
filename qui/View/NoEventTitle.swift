//
//  NoEventTitle.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//
import Foundation

final class NoEventTitles {
  static let title1: String = "Nothing to see here..."
  static let title2: String = "Tumbleweeds rolling by"
  static let title3: String = "The stage is empty today"
  static let title4: String = "Taking a breather"
  static let title5: String = "Even performers need a day off"
  static let title6: String = "Quiet as a mouse"
  static let title7: String = "Check back tomorrow!"
  static let title8: String = "The silence is deafening"
  static let title9: String = "Gone fishing"
  static let title10: String = "Time to make your own fun"
  
  static let subtitle1: String = "Go have a picnic or something!"
  static let subtitle2: String = "Time to binge that show everyone's talking about"
  static let subtitle3: String = "Maybe try that new coffee shop down the street"
  static let subtitle4: String = "Perfect day for a nap, don't you think?"
  static let subtitle5: String = "How about catching up with an old friend?"
  static let subtitle6: String = "Treat yourself to some ice cream!"
  static let subtitle7: String = "Your couch is calling your name"
  static let subtitle8: String = "Time to dust off that hobby you've been neglecting"
  static let subtitle9: String = "Why not take a walk on the wild side?"
  static let subtitle10: String = "Carpe diem... or whatever floats your boat!"
  
  static let allTitles: [String] = [title1, title2, title3, title4, title5, title6, title7, title8, title9, title10]
  static let allSubtitles: [String] = [subtitle1, subtitle2, subtitle3, subtitle4, subtitle5, subtitle6, subtitle7, subtitle8, subtitle9, subtitle10]
  
  static func getRandomTitle() -> String {
    return allTitles.randomElement() ?? title1
  }
  
  static func getRandomSubtitle() -> String {
    return allSubtitles.randomElement() ?? subtitle1
  }
}
