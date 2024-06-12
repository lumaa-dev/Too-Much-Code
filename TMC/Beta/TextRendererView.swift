//Made by Lumaa

import SwiftUI

//TODO: https://developer.apple.com/videos/play/wwdc2024/10151/
struct TextRendererView: View {
    var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            Text("Hello, World!")
                .textRenderer(CustomTextRenderer())
        } else {
            Text("Unavailable!")
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
struct CustomTextRenderer: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        withAnimation(.spring.repeatForever(autoreverses: true)) {
            ctx.transform.translatedBy(x: 10, y: 10)
            ctx.transform.translatedBy(x: 0, y: 0)
        }
        
        if let line = layout.first {
            ctx.draw(line)
        }
    }
}

#Preview {
    TextRendererView()
}
