//Made by Lumaa

import SwiftUI

@available(iOS 18.0, macOS 15.0, *)
struct NewTabs: View {
    @State private var foodType: TestList.FoodType? = nil
    
    #if os(iOS)
    @State private var customTab: TabViewCustomization = .init()
    #endif
    
    var body: some View {
        TabView {
            Tab("All", systemImage: "tray") {
                TestList(onlyShow: nil)
            }
            .tabPlacement(.pinned)
            .customizationID("all")
            
            TabSection("Specific") {
                Tab("Fruits", systemImage: "tree") {
                    TestList(onlyShow: .fruits)
                }
                .tabPlacement(.automatic)
                .customizationID("fruits")
                
                Tab("Vegetables", systemImage: "leaf.fill") {
                    TestList(onlyShow: .vegetables)
                }
                .tabPlacement(.automatic)
                .customizationID("vegetables")
            }
            .tabPlacement(.sidebarOnly)
        }
        .tabViewStyle(.sidebarAdaptable)
        #if os(iOS)
        .tabViewCustomization($customTab)
        #endif
        
    }
}

@available(iOS 18.0, macOS 15.0, *)
#Preview {
    NewTabs()
}
