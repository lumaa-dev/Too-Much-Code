//Made by Lumaa

import SwiftUI

struct TestView: View {
    private var width: CGFloat {
        #if os(iOS)
        return 150
        #else
        return 350
        #endif
    }
    
    var body: some View {
        GroupBox("Test View!") {
            Text("This view is to test windows, views, sheets, or to see where views go!")
        }
        .frame(width: width)
    }
}

#Preview {
    TestView()
}
