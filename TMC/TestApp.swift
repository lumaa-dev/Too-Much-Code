//Made by Lumaa

import SwiftUI

@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        #endif
    }
}
