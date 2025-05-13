//
//  EKEvent.swift
//  qui
//
//  Created by Joe Cieplinski on 5/13/25.
//

import EventKit

extension EKEvent: @retroactive Identifiable {
  public var id: String { self.eventIdentifier }
}
