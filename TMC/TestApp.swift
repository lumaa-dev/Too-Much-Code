//Made by Lumaa

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct TestApp: App {
    #if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    #endif
    
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(iOS)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background || newPhase == .inactive {
                        print("app in fake \(newPhase == .background ? "full bg" : "short bg")")
//                        BackgroundBattery.main.schedule()
                    }
                }
                #endif
        }
        #if os(macOS)
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        #endif
        
        #if os(macOS)
        if #available(macOS 15.0, *) {
            UtilityWindow("Utility", id: "test-utility") {
                TestView()
            }
        }
        #endif
    }
}

#if canImport(UIKit)
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BackgroundBattery.main.createTasks()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("app in full bg")
        BackgroundBattery.main.schedule()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("app in short bg")
        BackgroundBattery.main.schedule()
    }
}
#endif
