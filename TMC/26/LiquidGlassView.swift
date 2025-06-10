// Made by Lumaa

import SwiftUI

@available(iOS 26.0, *)
struct LiquidGlassView: View {
    var body: some View {
        TabView {
            Tab {
                firstView
            } label: {
                Label("First", systemImage: "1.circle")
            }

            Tab {
                secondView
            } label: {
                Label("Best", systemImage: "2.circle")
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .navigationTitle(Text("Nav Title"))
        .navigationSubtitle(Text("New subtitle wow!"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var firstView: some View {
        Text("First View haha iOS 26 goated")
    }

    private var secondView: some View {
        List {
            ForEach(0...20, id: \.self) { num in
                Button("\(num)") {}
                    .buttonStyle(.glass)
            }
        }
    }
}
