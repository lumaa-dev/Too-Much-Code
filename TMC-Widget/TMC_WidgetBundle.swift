//Made by Lumaa

import WidgetKit
import SwiftUI

@main
struct TMC_WidgetBundle: WidgetBundle {
    var body: some Widget {
        #if os(iOS)
        TMC_WidgetLiveActivity()
        TMC_LAProgress()
        Timer_LiveActivity()
        
        if #available(iOS 18, *) {
            TimerToggle()
        }
        #endif
    }
}
