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
        
        #if os(iOS)
        var filteredTotal = [filteredFruits, filteredVege]
        return filteredTotal.items
        #else
        var filteredTotal: [String] = []
        
        for fruit in filteredFruits {
            filteredTotal.append(fruit)
        }
        for vegetable in filteredVege {
            filteredTotal.append(vegetable)
        }
        
        return filteredTotal
        #endif
    }
    
    var body: some View {
        List {
            if results.isEmpty && !isSearching {
                if onlyShow == .fruits || onlyShow == nil {
                    Section(header: Text("Fruits")) {
                        ForEach(fruits, id: \.self) { fruit in
                            Text(fruit)
                                .id(fruit)
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
                                .id(vegetable)
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
                ForEach(results, id: \.self) { result in
                    let ownership: String = fruits.contains(result) ? "Fruit" : "Vegetable"
                    
                    VStack(alignment: .leading) {
                        Text(result)
                        
                        if self.onlyShow != nil {
                            Text(ownership)
                                .foregroundStyle(.gray)
                                .font(.caption)
                        }
                    }
                    .id(result)
                }
            }
        }
        #if os(iOS)
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
        #else
        .searchable(text: $searchQuery, placement: .toolbar)
        #endif
    }
    
    enum FoodType: String {
        case fruits
        case vegetables
    }
}

#Preview {
    TestList()
}
