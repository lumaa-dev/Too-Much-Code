//Made by Lumaa

import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct TimerToggle: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "fr.lumaa.TMC.TimerToggle",
            provider: TimerValueProvider()
        ) { isRunning in
            ControlWidgetToggle(
                "Test Timer",
                isOn: isRunning,
                action: ToggleTimerIntent()
            ) { _ in
                Label(isRunning ? "Counting down" : "Stopped", systemImage: "timer")
                    .controlWidgetActionHint(isRunning ? "Start" : "Stop")
            }
            .tint(Color.orange)
        }
        .displayName("Test Timer")
    }
}

@available(iOS 18.0, *)
struct TimerValueProvider: ControlValueProvider {
    func currentValue() async throws -> Bool {
        return AppTimer.shared.isRunning
    }
    
    let previewValue: Bool = false
}
