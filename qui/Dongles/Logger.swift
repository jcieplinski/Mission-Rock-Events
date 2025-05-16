//
//  Logger.swift
//  qui
//
//  Created by Joe Cieplinski on 5/10/25.
//


import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? ""
    
    static let swiftData = Logger(subsystem: subsystem, category: "swiftData")
    static let urlSession = Logger(subsystem: subsystem, category: "urlSession")
    static let imageCache = Logger(subsystem: subsystem, category: "imageCache")
    static let storeKit = Logger(subsystem: subsystem, category: "storeKit")
}
