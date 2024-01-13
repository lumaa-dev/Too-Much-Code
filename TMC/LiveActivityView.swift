//Made by Lumaa

import SwiftUI
import ActivityKit

struct LiveActivityView: View {
    @State private var activity: Activity<TMC_WidgetAttributes>?
    @State private var hasActivity: Bool = false
    @State private var switchedEmoji: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            if hasActivity {
                Text(String("Live Activity is running\nEmoji: \(switchedEmoji ? "😀" : "🤩")"))
                    .multilineTextAlignment(.center)
                    .font(.title.bold())
            }
            
            VStack (spacing: 10) {
                Button {
                    try? startActivity()
                } label: {
                    Text(String("Start"))
                }
                .disabled(hasActivity)
                .buttonStyle(.bordered)
                
                Button {
                    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                        Task {
                            await updateActivity()
                        }
                    }
                } label: {
                    Text(String("Update"))
                }
                .disabled(!hasActivity)
                .buttonStyle(.bordered)
                
                Button {
                    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                        Task {
                            await endActivity()
                        }
                    }
                } label: {
                    Text(String("Stop"))
                }
                .disabled(!hasActivity)
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("Live Activity")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func startActivity() throws {
        let att = TMC_WidgetAttributes(name: "TMC")
        let initialState = TMC_WidgetAttributes.ContentState(emoji: switchedEmoji ? "😀" : "🤩")
        
        do {
            activity = try Activity.request(attributes: att, content: .init(state: initialState, staleDate: nil))
            
            withAnimation {
                hasActivity = true
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateActivity() async {
        guard let activity else { return }
        let contentState = TMC_WidgetAttributes.ContentState(emoji: switchedEmoji ? "😀" : "🤩")
        
        withAnimation {
            switchedEmoji.toggle()
        }
        
        await activity.update(
            ActivityContent<TMC_WidgetAttributes.ContentState>(
                state: contentState,
                staleDate: Date.now + 15,
                relevanceScore: 100
            ),
            alertConfiguration: .init(title: "Notif Title", body: "Notif Body", sound: .named("N/A"))
        )
    }
    
    func endActivity() async {
        guard let activity else { return }
        
        let contentState = TMC_WidgetAttributes.ContentState(emoji: "👋")
        await activity.end(ActivityContent(state: contentState, staleDate: nil), dismissalPolicy: .after(.now + 5))
        
        withAnimation {
            hasActivity = false
            switchedEmoji = false
        }
    }
}

#Preview {
    LiveActivityView()
}
