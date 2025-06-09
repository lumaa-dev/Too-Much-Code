//Made by Lumaa

import SwiftUI

struct MeshGradientView: View {
    var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {    
            // width / height = colors per row / columns
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.2, 0), .init(1, 0),
                .init(0, 0.25), .init(0.6, 0.35), .init(1, 0.75),
                .init(0, 1), .init(0.92, 1), .init(1, 1)
            ], colors: [
                .red, .purple, .indigo,
                .orange, Color.label, .blue,
                .yellow, .green, .mint
            ])
            .ignoresSafeArea()
        } else {
            Text("Unavailable!")
        }
    }
}

extension Color {
    #if os(iOS)
    static let label: Color = Color(uiColor: UIColor.label)
    #else
    static let label: Color = Color(nsColor: NSColor.labelColor)
    #endif
}

#Preview {
    MeshGradientView()
}
