//Made by Lumaa

import WidgetKit
import SwiftUI

@main
struct TMC_WidgetBundle: WidgetBundle {
    var body: some Widget {
//        TMC_Widget()
        
        #if os(iOS)
        TMC_WidgetLiveActivity()
        TMC_LAProgress()
        #endif
    }
}
