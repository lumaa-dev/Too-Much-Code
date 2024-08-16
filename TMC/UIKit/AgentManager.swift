// Made by Lumaa
#if os(macOS)
import Foundation
import AppKit

final class AgentManager {
    public static var isInDock: Bool {
        get {
            return docked
        }
        set {
            docked = newValue
            setAppVisibility(to: newValue)
        }
    }
    private static var docked: Bool = true

    private static func setAppVisibility(to visible: Bool) {
        NSApp.setActivationPolicy(visible ? .regular : .prohibited)
        if visible {
            Thread.sleep(forTimeInterval: 1)
            NSApp.requestUserAttention(.criticalRequest)
        }
    }
}
#endif
