//Made by Lumaa

import SwiftUI

struct TestList: View {
    @Environment(\.isSearching) private var isSearching: Bool
    
    var onlyShow: FoodType? = nil
    
    @State private var fruits: [String] = [
        "Apple",
        "Banana",
        "Orange",
        "Strawberry",
        "Lemon",
        "Pineapple",
        "Pear",
        "Watermelon"
    ]
    
    @State private var vegetables: [String] = [
        "Carrot",
        "Tomato",
        "Potato",
        "Cucumber"
    ]
    
    @State private var searchQuery: String = ""
    private var results: [String] {
        guard searchQuery.isEmpty else { return [] }
        
        let filteredFruits = self.onlyShow == .fruits || self.onlyShow == nil ? fruits.filter({ $0.localizedCaseInsensitiveContains(searchQuery) }) : []
        let filteredVege = self.onlyShow == .vegetables || self.onlyShow == nil ? vegetables.filter({ $0.localizedCaseInsensitiveContains(searchQuery) }) : []
        
        let filteredTotal = [filteredFruits, filteredVege]
        return filteredTotal.items
    }
    
    var body: some View {
        List {
            if results.isEmpty && !isSearching {
                if onlyShow == .fruits || onlyShow == nil {
                    Section(header: Text("Fruits")) {
                        ForEach(fruits, id: \.self) { fruit in
                            Text(fruit)
                        }
                        .onDelete { index in
                            fruits.remove(atOffsets: index)
                        }
                        .onMove { indexSet, index in
                            fruits.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                }
                
                if onlyShow == .vegetables || onlyShow == nil {
                    Section(header: Text("Vegetables")) {
                        ForEach(vegetables, id: \.self) { vegetable in
                            Text(vegetable)
                        }
                        .onDelete { index in
                            vegetables.remove(atOffsets: index)
                        }
                        .onMove { indexSet, index in
                            vegetables.move(fromOffsets: indexSet, toOffset: index)
                        }
                    }
                }
            } else {
                ForEach(results, id: \.self) { fruit in
                    Text(fruit)
                }
            }
        }
    }
    
    enum FoodType: String {
        case fruits
        case vegetables
    }
}

#Preview {
    TestList()
}
