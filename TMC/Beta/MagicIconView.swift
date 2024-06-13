//Made by Lumaa

import SwiftUI

struct MagicIconView: View {
    @State private var currentIcon: String = "bell"
    @State private var lastDifferent: String = ""
    @State private var hasBg: Bool = true
    
    var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            switcher
        } else {
            Text("Unavailable!")
        }
    }
    
    @available(iOS 18.0, macOS 15.0, *)
    var switcher: some View {
        VStack {
            // apparently, using label is better? no difference for me?
            Label("Icon", systemImage: currentIcon)
                .font(.system(size: 80))
                .frame(width: 150, height: 150, alignment: .center)
                .contentTransition(.symbolEffect(.replace.magic(fallback: .offUp.byLayer)))
                .background(hasBg ? Color.gray.opacity(0.35) : Color.clear)
                .labelStyle(.iconOnly)
            
            Spacer()
                .frame(height: 40)
            
            Button {
                let isDefault = currentIcon == "bell"
                
                if isDefault {
                    currentIcon = lastDifferent == "bell.badge" ? "bell.slash" : "bell.badge"
                    lastDifferent = currentIcon
                } else {
                    currentIcon = "bell"
                }
            } label: {
                Text("Change Icon")
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Toggle("Activate Background", isOn: $hasBg)
                .toggleStyle(.button)
        }
    }
}

#Preview {
    MagicIconView()
}
