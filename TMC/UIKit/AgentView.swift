// Made by Lumaa
#if os(macOS)
import SwiftUI

struct AgentView: View {
    var body: some View {
        GroupBox("Menu Bar") {
            DockToggleView()
            .padding()
        }
        .padding()
    }
}

struct DockToggleView: View {
    private var docked: Binding<Bool> = .init(get: {
        return AgentManager.isInDock
    }, set: { newValue in
        AgentManager.isInDock = newValue
    })

    public let onClick: () -> Void

    init(onClick: @escaping () -> Void = {}) {
        self.onClick = onClick
    }

    var body: some View {
        Button {
            docked.wrappedValue.toggle()
            onClick()
        } label: {
            Text("Toggle app in dock")
        }
    }
}

#Preview {
    AgentView()
}
#endif
