//
//  UserDefaults.swift
//  qui
//
//  Created by Joe Cieplinski on 5/10/25.
//

import Foundation

extension UserDefaults {
  static var appGroup: UserDefaults {
    UserDefaults(suiteName: Constants.appGroup) ?? .standard
  }
}
