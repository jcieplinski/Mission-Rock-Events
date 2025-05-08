//
//  Mission_Rock_Events_Widget_ExtensionLiveActivity.swift
//  Mission Rock Events Widget Extension
//
//  Created by Joe Cieplinski on 5/8/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Mission_Rock_Events_Widget_ExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Mission_Rock_Events_Widget_ExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Mission_Rock_Events_Widget_ExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Mission_Rock_Events_Widget_ExtensionAttributes {
    fileprivate static var preview: Mission_Rock_Events_Widget_ExtensionAttributes {
        Mission_Rock_Events_Widget_ExtensionAttributes(name: "World")
    }
}

extension Mission_Rock_Events_Widget_ExtensionAttributes.ContentState {
    fileprivate static var smiley: Mission_Rock_Events_Widget_ExtensionAttributes.ContentState {
        Mission_Rock_Events_Widget_ExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Mission_Rock_Events_Widget_ExtensionAttributes.ContentState {
         Mission_Rock_Events_Widget_ExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Mission_Rock_Events_Widget_ExtensionAttributes.preview) {
   Mission_Rock_Events_Widget_ExtensionLiveActivity()
} contentStates: {
    Mission_Rock_Events_Widget_ExtensionAttributes.ContentState.smiley
    Mission_Rock_Events_Widget_ExtensionAttributes.ContentState.starEyes
}
