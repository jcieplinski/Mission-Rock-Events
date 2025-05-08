//
//  Mission_Rock_Events_Widget_ExtensionBundle.swift
//  Mission Rock Events Widget Extension
//
//  Created by Joe Cieplinski on 5/8/25.
//

import WidgetKit
import SwiftUI

@main
struct Mission_Rock_Events_Widget_ExtensionBundle: WidgetBundle {
    var body: some Widget {
        Mission_Rock_Events_Widget_Extension()
        Mission_Rock_Events_Widget_ExtensionControl()
        Mission_Rock_Events_Widget_ExtensionLiveActivity()
    }
}
