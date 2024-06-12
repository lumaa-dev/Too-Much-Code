//Made by Lumaa

import SwiftUI
import Combine
#if os(iOS)
import ActivityKit
#endif

struct TimerView: View {
    @StateObject private var timer: AppTimer = .shared
    
    @State private var setTime: Double = 5.0
    @State private var activityNotice: Bool = false
    private var autoTimer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 100)
            Gauge(value: Double(timer.currentTime), in: Double(0)...Double(timer.time)) {
                Image(systemName: "timer")
            } currentValueLabel: {
                Text(timer.currentTime, format: .number)
                    .contentTransition(.numericText(countsDown: true))
                    .transaction { t in
                        t.animation = .default
                    }
            }
            .gaugeStyle(.accessoryCircularCapacity)
            
            Spacer()
            
            HStack {
                Button {
                    if timer.isRunning {
                        timer.stopTimer()
                    } else {
                        timer.setDuration(.seconds(setTime))
                        timer.startTimer()
                    }
                } label: {
                    Text(timer.isRunning ? "Stop" : "Start")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                
                #if os(macOS)
                HelpLink {
                    activityNotice.toggle()
                }
                .popover(isPresented: $activityNotice, arrowEdge: .top) {
                    Text("The Live Activity feature is not available on macOS")
                        .padding()
                }
                #endif
            }
            
            Text(setTime, format: .number)
            Slider(value: $setTime, in: 5...60, step: 1.0) {
                Text("Duration")
            }
            .padding()
        }
        .onReceive(autoTimer) { _ in
            guard timer.isRunning && timer.currentTime < timer.time else { return }
            
            withAnimation(.spring) {
                timer.currentTime += 1
            }
        }
        .toolbar {
            if #available(iOS 18.0, *) {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        VStack {
                            Text("You can add the \"Test Timer\" action in the Control Center or on your Action button thanks to iOS 18")
                                .padding(.vertical)
                            
                            Image("ControlCenter_Gallery")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                                .padding(.vertical)
                            
                            Image("ControlCenter_Set")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150)
                                .padding(.vertical)
                        }
                        .navigationTitle("Control Center")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Control Center", systemImage: "widget.small.badge.plus")
                    }
                }
            }
        }
    }
}

@Observable
final class AppTimer: ObservableObject, Codable, Equatable, Hashable, Identifiable {
    static func == (lhs: AppTimer, rhs: AppTimer) -> Bool {
        lhs.id == rhs._id
    }
    
    static let shared: AppTimer = AppTimer()
    
    var id: UUID = UUID()
    var isRunning: Bool = false
    private(set) var duration: Duration = .seconds(10)
    var currentTime: Int = 0
//    private var timerObject: Timer.TimerPublisher { Timer.publish(every: TimeInterval(self.time), on: .main, in: .common) }
//    private(set) var activeTimer: Publishers.Autoconnect<Timer.TimerPublisher>? = nil
    
    var time: Int {
         Int(self.duration.components.seconds)
    }
    
    func setDuration(_ newDuration: Duration) {
        guard !isRunning else { return }
        self.duration = newDuration
    }
    
    init(isRunning: Bool, duration: Duration, currentTime: Int) {
        self.isRunning = isRunning
        self.duration = duration
        self.currentTime = currentTime
    }
    
    init() {
        self.isRunning = false
        self.duration = .seconds(10.0)
        self.currentTime = 0
    }
    
    func startTimer() {
        guard !isRunning else { return }
        self.isRunning = true
        
//        timerObject.sink { _ in
//            
//        }
//        self.activeTimer = timerObject.autoconnect()
        
        #if os(iOS)
        self.startActivity()
        #endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(self.duration.components.seconds))) {
            guard self.isRunning else { return }
            
            withAnimation(.spring) {
                self.currentTime = self.time
            }
        }
    }
    
    func stopTimer() {
        guard isRunning else { return }
        self.isRunning = false
        
        #if canImport(ActivityKit)
        self.endActivity()
        #endif
        
        withAnimation(.easeOut) {
            self.currentTime = 0
        }
//        timer.upstream.connect().cancel()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

#if os(iOS)
extension AppTimer {
    func startActivity() {
        endActivity()
        
        let contentState = TimerAttributes.ContentState(loading: self)
        
        do {
            _ = try Activity.request(attributes: TimerAttributes(), content: ActivityContent(state: contentState, staleDate: .now + TimeInterval(self.time), relevanceScore: 10))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(self.time)) {
                self.pingActivity()
            }
        } catch {
            print(error)
        }
    }
    
    func pingActivity() {
        guard let currentTimer = Activity<TimerAttributes>.activities.first else { return }
        
        let contentState = TimerAttributes.ContentState(loading: self)
        let content = ActivityContent(state: contentState, staleDate: .distantFuture, relevanceScore: 10)
        
        Task {
            await currentTimer.update(content, alertConfiguration: .init(title: "TMC Timer", body: "Timer has ended", sound: .default))
        }
    }
    
    func endActivity() {
        if let currentTimer = Activity<TimerAttributes>.activities.first {
            Task { await currentTimer.end(nil, dismissalPolicy: .immediate) }
        }
    }
}
#endif
