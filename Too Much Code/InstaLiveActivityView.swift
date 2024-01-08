//Made by Lumaa

import SwiftUI
import ActivityKit

struct InstaLiveActivityView: View {
    @State private var activity: Activity<TMC_LAProgressAttribute>?
    @State private var hasActivity: Bool = false
    @State private var load: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            if hasActivity {
                Text(String("Live Activity is running\nLoad: \(load)"))
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
            }
        }
        .navigationTitle("Live Activity")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func startActivity() throws {
        let att = TMC_LAProgressAttribute(name: "TMC_Progress")
        let initialState = TMC_LAProgressAttribute.ContentState(loading: load)
        
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
        let newLoad: Double = .random(in: 0...1)
        let contentState = TMC_LAProgressAttribute.ContentState(loading: newLoad)
        
        withAnimation {
            load = newLoad
        }
        
        await activity.update(
            ActivityContent<TMC_LAProgressAttribute.ContentState>(
                state: contentState,
                staleDate: Date.now + 15,
                relevanceScore: 100
            ),
            alertConfiguration: .init(title: "Notif Title", body: "Notif Body", sound: .named("N/A"))
        )
    }
    
    func endActivity() async {
        guard let activity else { return }
        
        let contentState = TMC_LAProgressAttribute.ContentState(loading: 1.0)
        await activity.end(ActivityContent(state: contentState, staleDate: nil), dismissalPolicy: .after(.now + 5))
        
        withAnimation {
            hasActivity = false
            load = 0.0
        }
    }
}

#Preview {
    InstaLiveActivityView()
}
