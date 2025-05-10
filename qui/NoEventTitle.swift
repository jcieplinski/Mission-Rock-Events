//
//  NoEventTitle.swift
//  Mission Rock Events
//
//  Created by Joe Cieplinski on 5/7/25.
//
import Foundation

final class NoEventTitles {
  static let title1: String = "Nothing to see here…"
  static let title2: String = "Tumbleweeds rolling by"
  static let title3: String = "The stage is empty today"
  static let title4: String = "Taking a breather"
  static let title5: String = "Even performers need a day off"
  static let title6: String = "Quiet as a mouse"
  static let title7: String = "Check back tomorrow!"
  static let title8: String = "The silence is deafening"
  static let title9: String = "Gone fishing"
  static let title10: String = "Time to make your own fun"
  static let title11: String = "Just another quiet day"
  static let title12: String = "The calm before the storm"
  static let title13: String = "Taking an intermission"
  static let title14: String = "Plot twist: no events today"
  static let title15: String = "Time for a coffee break"
  static let title16: String = "Peaceful and serene"
  static let title17: String = "The show must go on… some other day"
  static let title18: String = "Currently in stealth mode"
  static let title19: String = "Out to lunch"
  static let title20: String = "Battery recharging…"
  
  static let subtitle1: String = "Go have a picnic or something"
  static let subtitle2: String = "Time to binge that show everyone’s talking about"
  static let subtitle3: String = "Maybe try that new coffee shop down the street"
  static let subtitle4: String = "Perfect day for a nap, don’t you think?"
  static let subtitle5: String = "How about catching up with an old friend?"
  static let subtitle6: String = "Treat yourself to some ice cream!"
  static let subtitle7: String = "Your couch is calling your name"
  static let subtitle8: String = "Time to dust off that hobby you’ve been neglecting"
  static let subtitle9: String = "Why not take a walk on the wild side?"
  static let subtitle10: String = "Carpe diem… or whatever floats your boat!"
  static let subtitle11: String = "Perfect time to start that book you’ve been meaning to read"
  static let subtitle12: String = "How about trying out a new recipe?"
  static let subtitle13: String = "Maybe reorganize your sock drawer"
  static let subtitle14: String = "Time to practice your dance moves"
  static let subtitle15: String = "Take your camera out for a photo adventure"
  static let subtitle16: String = "Call a friend; they miss you"
  static let subtitle17: String = "Plan that trip you keep talking about"
  static let subtitle18: String = "Start a garden, even if it’s just one plant"
  static let subtitle19: String = "Write that novel you’ve been thinking about"
  static let subtitle20: String = "Learn a new language, or at least try to!"
  
  static let allTitles: [String] = [title1, title2, title3, title4, title5, title6, title7, title8, title9, title10, title11, title12, title13, title14, title15, title16, title17, title18, title19, title20]
  static let allSubtitles: [String] = [subtitle1, subtitle2, subtitle3, subtitle4, subtitle5, subtitle6, subtitle7, subtitle8, subtitle9, subtitle10, subtitle11, subtitle12, subtitle13, subtitle14, subtitle15, subtitle16, subtitle17, subtitle18, subtitle19, subtitle20]
  
  static func getRandomTitle() -> String {
    return allTitles.randomElement() ?? title1
  }
  
  static func getRandomSubtitle() -> String {
    return allSubtitles.randomElement() ?? subtitle1
  }
}
