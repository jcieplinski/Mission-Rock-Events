//
//  Logger.swift
//  qui
//
//  Created by Joe Cieplinski on 5/10/25.
//


import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? ""
    
    static let swiftData = Logger(subsystem: subsystem, category: "swiftData")
    static let storeKit = Logger(subsystem: subsystem, category: "storeKit")
}
