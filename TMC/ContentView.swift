//Made by Lumaa

import SwiftUI

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow: OpenWindowAction
    
    var isMac: Bool {
        #if os(macOS)
            return true
        #else
            return false
        #endif
    }
    
    var isBeta: Bool {
        if #available(iOS 18.0, macOS 15.0, *) {
            return true
        } else {
            return false
        }
    }
    
    private var newOSString: String {
        isMac ? "macOS Sequoia" : "iOS 18"
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
                    
                    NavigationLink {
                        TimerView()
                            .tint(Color.orange)
                    } label: {
                        Label(String("Timer"), systemImage: "timer")
                            .foregroundStyle(Color.orange)
                    }
                }
                
                Section(header: Text(String("UIKit & AppKit"))) {
                    #if os(iOS)
                        NavigationLink {
                            CustomSheetView()
                                .tint(Color.purple)
                        } label: {
                            Label(String("iOS Sheets"), systemImage: "rectangle.stack")
                                .foregroundStyle(Color.purple)
                        }
                    #else
                        Label(String("iOS Sheets"), systemImage: "rectangle.stack")
                            .foregroundStyle(.gray)
                    #endif

                    #if os(macOS)
                    NavigationLink {
                        AgentView()
                    } label: {
                        Label(String("Menu Bar"), systemImage: "filemenu.and.cursorarrow")
                            .foregroundStyle(Color(nsColor: NSColor.labelColor))
                    }
                    #else
                    Label(String("Menu Bar"), systemImage: "filemenu.and.cursorarrow")
                        .foregroundStyle(Color.gray)
                    #endif

#if os(iOS)
                    NavigationLink {
                        CameraView()
                            .tint(Color.blue)
                    } label: {
                        Label(String("Camera"), systemImage: "camera.fill")
                            .foregroundStyle(Color.blue)
                    }
#else
                    Label(String("Camera"), systemImage: "camera.fill")
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
                
                Section(header: Text("New \(newOSString) content")) {
                    Text("This section is enabled for users using a \(newOSString) beta.")
                        .listRowBackground(Rectangle().fill(Color.red.gradient))
                    
                    Button {
                        openWindow(id: "test-utility")
                    } label: {
                        Label("Utility Window", systemImage: "macwindow")
                    }
                    .disabled(!isMac && isBeta)
                    .foregroundColor(!isMac && isBeta ? Color.gray : Color.blue)
                    
                    NavigationLink {
                        MagicIconView()
                    } label: {
                        Label("Magic SF Symbol transition", systemImage: "wand.and.sparkles.inverse")
                            .foregroundColor(Color.yellow)
                    }
                    .disabled(!isBeta)
                    
                    if #available(iOS 18.0, macOS 15.0, *) {
                        NavigationLink {
                            NewTabs()
                        } label: {
                            Label("Sidebar TabView", systemImage: "sidebar.leading")
                                .foregroundColor(Color.teal)
                        }
                    } else {
                        Label("Sidebar TabView", systemImage: "sidebar.leading")
                            .foregroundColor(Color.gray)
                    }
                    
                    NavigationLink {
                        TranslationView()
                    } label: {
                        Label("Translation API", systemImage: "translate")
                            .foregroundColor(Color.cyan)
                    }
                    .disabled(!isBeta)

                    NavigationLink {
                        TextRendererView()
                    } label: {
                        Label("TextRenderer", systemImage: "textformat.size")
                            .foregroundColor(Color.indigo)
                    }
                    .disabled(!isBeta)
                    
                    NavigationLink {
                        MeshGradientView()
                    } label: {
                        Label("MeshGradient", systemImage: "paintpalette.fill")
                            .foregroundStyle(LinearGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple], startPoint: .leading, endPoint: .trailing))
                    }
                    .disabled(!isBeta)

                    #if canImport(AccessorySetupKit)
                    NavigationLink {
                        if #available(iOS 18.0, *) {
                            SetupAccessory()
                        } else {
                            Text("Unavailable!")
                        }
                    } label: {
                        Label("SetupAccessory with AirPods", systemImage: "airpods.pro")
                            .foregroundColor(Color.blue)
                    }
                    .disabled(!isBeta || isMac)
                    #else
                    Label("SetupAccessory with AirPods", systemImage: "airpods.pro")
                        .foregroundColor(Color.gray)
                    #endif

                    #if os(macOS)
                    if #available(macOS 15.0, *) {
                        NavigationLink {
                            ImageGradient()
                        } label: {
                            Label("ImageGradient", systemImage: "paintpalette.fill")
                                .foregroundStyle(LinearGradient(colors: [.red, .orange, .yellow, .green, .blue, .purple], startPoint: .leading, endPoint: .trailing))
                        }
                        .disabled(!isBeta && isMac)
                    } else {
                        Label("ImageGradient", systemImage: "paintpalette.fill")
                            .foregroundStyle(Color.gray)
                    }
                    #else
                    Label("ImageGradient", systemImage: "paintpalette.fill")
                        .foregroundStyle(Color.gray)
                    #endif
                }
                
                // MARK: - Credits
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
