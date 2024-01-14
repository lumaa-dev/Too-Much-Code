//Made by Lumaa

#if os(iOS)
import ActivityKit
import WidgetKit
import SwiftUI

struct TMC_LAProgressAttribute: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var loading: Double
    }
    
    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TMC_LAProgress: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TMC_LAProgressAttribute.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                HStack(spacing: 20) {
                    Text("Fake Loading...")
                    
                    progress(current: context.state.loading)
                        .padding(.vertical)
                }
            }
            .activityBackgroundTint(Color.black)
            .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 20) {
                        Text("Fake Loading...")
                        
                        progress(current: context.state.loading)
                    }
                }
            } compactLeading: {
                Image(systemName: "camera.badge.clock.fill")
                    .foregroundStyle(LinearGradient(colors: [.yellow, .red, .purple], startPoint: .bottomLeading, endPoint: .topTrailing))
            } compactTrailing: {
                Text("\(Int(context.state.loading * 100))")
            } minimal: {
                Text("\(Int(context.state.loading * 100))")
            }
            .keylineTint(.purple)
        }
    }
    
    @ViewBuilder func progress(current: Double) -> some View {
        Gauge(value: current, in: 0...1) {
            Image(systemName: "camera.badge.clock.fill")
                .foregroundStyle(LinearGradient(colors: [.yellow, .red, .purple], startPoint: .bottomLeading, endPoint: .topTrailing))
        } currentValueLabel: {
            Text("\(Int(current * 100))")
                .foregroundColor(Color.white)
                .contentTransition(.numericText(value: current))
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(LinearGradient(colors: [.yellow, .red, .purple], startPoint: .bottomLeading, endPoint: .topTrailing))
    }
}
#endif
