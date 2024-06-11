//Made by Lumaa

import SwiftUI

struct ContentView: View {
    var isMac: Bool {
        #if os(macOS)
            return true
        #else
            return false
        #endif
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(String("Live Activities"))) {
                    #if os(iOS)
                        NavigationLink {
                            LiveActivityView()
                                .tint(Color.blue)
                        } label: {
                            Label(String("Live Activity"), systemImage: "clock.badge.fill")
                                .foregroundStyle(.blue)
                        }
                        
                        NavigationLink {
                            InstaLiveActivityView()
                                .tint(LinearGradient(colors: [.yellow, .red, .purple], startPoint: .bottomLeading, endPoint: .topTrailing))
                        } label: {
                            Label(String("Instagram Live Activity"), systemImage: "camera.badge.clock.fill")
                                .foregroundStyle(LinearGradient(colors: [.yellow, .red, .purple], startPoint: .leading, endPoint: .trailing))
                        }
                    
                    #else
                        Label(String("Live Activity"), systemImage: "clock.badge.fill")
                            .foregroundStyle(.gray)
                        
                        Label(String("Instagram Live Activity"), systemImage: "camera.badge.clock.fill")
                            .foregroundStyle(.gray)
                    #endif
                }
                
                Section(header: Text(String("UIKit"))) {
                    #if os(iOS)
                        NavigationLink {
                            CustomSheetView()
                                .tint(Color.purple)
                        } label: {
                            Label(String("Sheets"), systemImage: "rectangle.stack")
                                .foregroundStyle(Color.purple)
                        }
                    #else
                        Label(String("Sheets"), systemImage: "rectangle.stack")
                            .foregroundStyle(.gray)
                    #endif
                }
                
                Section(header: Text(String("Device Communication"))) {
                    NavigationLink {
                        BatteryView()
                    } label: {
                        Label(String("Battery Connectivity"), systemImage: "battery.75percent")
                            .foregroundStyle(.green)
                    }
                }
                
                Section(header: Text(String("Credits"))) {
                    Link(destination: URL(string: "https://techhub.social/@lumaa")!) {
                        Text(String("By @lumaa@techhub.social"))
                    }
                    ShareLink(item: URL(string: "https://github.com/lumaa-dev/Too-Much-Code")!) {
                        Label(String("Share the GitHub Repository"), systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle(String("Too Much Code"))
        }
    }
}

#Preview {
    ContentView()
}
