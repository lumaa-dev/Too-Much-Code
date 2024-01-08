//Made by Lumaa

import ActivityKit
import WidgetKit
import SwiftUI

struct TMC_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TMC_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TMC_WidgetAttributes.self) { context in
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
            .keylineTint(Color.red)
        }
    }
}

extension TMC_WidgetAttributes {
    fileprivate static var preview: TMC_WidgetAttributes {
        TMC_WidgetAttributes(name: "World")
    }
}

extension TMC_WidgetAttributes.ContentState {
    fileprivate static var smiley: TMC_WidgetAttributes.ContentState {
        TMC_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TMC_WidgetAttributes.ContentState {
         TMC_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TMC_WidgetAttributes.preview) {
   TMC_WidgetLiveActivity()
} contentStates: {
    TMC_WidgetAttributes.ContentState.smiley
    TMC_WidgetAttributes.ContentState.starEyes
}
