//
//  AppIntent.swift
//  qui watch complications extension
//
//  Created by Joe Cieplinski on 5/10/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Qui Events" }
    static var description: IntentDescription { "Displays the number of events happening today" }
}
