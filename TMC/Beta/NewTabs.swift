//Made by Lumaa

import SwiftUI

@available(iOS 18.0, macOS 15.0, *)
struct NewTabs: View {
    @State private var foodType: TestList.FoodType? = nil
    
    // this does not work?
    @State private var customTab: TabViewCustomization = .init()
    
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
                .customizationID("fruits")
                
                Tab("Vegetables", systemImage: "leaf.fill") {
                    TestList(onlyShow: .vegetables)
                }
                .customizationID("vegetables")
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($customTab)
    }
}

@available(iOS 18.0, macOS 15.0, *)
#Preview {
    NewTabs()
}
