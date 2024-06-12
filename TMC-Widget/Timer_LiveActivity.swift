//Made by Lumaa

#if os(iOS)
import SwiftUI
import WidgetKit
import ActivityKit

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var loading: AppTimer
    }
    
    var start: Date = .now
}

struct Timer_LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            HStack {
                Text("Timer")
                    .font(.headline)
                
                Spacer()
                
                specialGauge(context: context)
            }
            .padding()
            .activityBackgroundTint(Color.black)
            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // this doesnt work BEFORE the timer ends
                DynamicIslandExpandedRegion(.leading) {
                    Text("Timer")
                        .font(.headline)
                        .padding()
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    specialGauge(context: context)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(Color.orange)
            } compactTrailing: {
                countdown(context: context)
                    .frame(alignment: .trailing)
            } minimal: {
                countdown(context: context, color: Color.orange)
            }
            .keylineTint(Color.orange)
        }
    }
    
    @ViewBuilder
    func specialGauge(context: ActivityViewContext<TimerAttributes>) -> some View {
        Gauge(value: Double(context.state.loading.currentTime), in: 0.0...Double(context.state.loading.time)) {
            Image(systemName: "timer")
                .foregroundStyle(Color.orange)
        } currentValueLabel: {
            countdown(context: context)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(Color.orange)
    }
    
    @ViewBuilder
    func countdown(context: ActivityViewContext<TimerAttributes>, color: Color = Color.white) -> some View {
        Text(context.attributes.start + TimeInterval(context.state.loading.currentTime), style: .timer)
            .foregroundColor(color)
            .contentTransition(.numericText(countsDown: true))
            .frame(maxWidth: 50, alignment: .trailing)
    }
}
#endif
