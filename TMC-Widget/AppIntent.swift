//Made by Lumaa

import WidgetKit
import AppIntents

struct StartTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start a timer"
    static var description = IntentDescription("This allows you to start a test timer and its Live Activity")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Start a \(\.$time) second timer")
    }
    
    // An example configurable parameter.
    @Parameter(title: "Time in seconds", default: 10)
    var time: Int
    
    func perform() async throws -> some IntentResult {
        AppTimer.shared.setDuration(.seconds(self.time))
        AppTimer.shared.startTimer()
        
        return .result()
    }
}

struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop the timer"
    static var description = IntentDescription("Stop any currently active test timer")
    
    func perform() async throws -> some IntentResult {
        AppTimer.shared.stopTimer()
        AppTimer.shared.endActivity()
        
        return .result()
    }
}
