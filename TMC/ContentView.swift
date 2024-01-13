//Made by Lumaa

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(String("Live Activities"))) {
                    NavigationLink {
                        LiveActivityView()
                    } label: {
                        Label(String("Live Activity"), systemImage: "clock.badge.fill")
                            .foregroundStyle(.blue)
                    }
                    
                    NavigationLink {
                        InstaLiveActivityView()
                    } label: {
                        Label(String("Instagram Live Activity"), systemImage: "camera.badge.clock.fill")
                            .foregroundStyle(LinearGradient(colors: [.yellow, .red, .purple], startPoint: .leading, endPoint: .trailing))
                    }
                }
                
                Section {
                    Text(String("By Lumaa"))
                }
            }
            .navigationTitle(String("Too Much Code"))
        }
    }
}

#Preview {
    ContentView()
}
