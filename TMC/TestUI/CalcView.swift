// Made by Lumaa

import SwiftUI

struct CalcView: View {
    var items: [GridItem] {
        [
            GridItem(self.gridType.toType()),
            GridItem(self.gridType.toType()),
            GridItem(self.gridType.toType()),
            GridItem(self.gridType.toType())
        ]
    }

    @State private var gridType: GridType = .flexible
    @State private var width: Double = 200.0
    @State private var height: Double = 200.0

    var body: some View {
        VStack {
            Spacer()

            if gridType != .stack {
                LazyVGrid(columns: self.items) {
                    nums
                }
                .function(width: self.width, height: self.height)
            } else {
                GridStack(rows: 3, columns: 3) { row, col in
                    numberView(row * 3 + col)
                }
                .function(width: self.width, height: self.height)
            }

            Spacer()

            Picker(selection: $gridType) {
                ForEach(GridType.allCases, id: \.self) { t in
                    Text(t.rawValue)
                        .id(t)
                }
            } label: {
                Text("Grid Type")
            }

            Slider(value: $width, in: 20...500) { Text("Width") }
                .padding(.horizontal)
            Slider(value: $height, in: 20...500) { Text("Height") }
                .padding(.horizontal)

            Menu {
                Button {
                    self.height = self.width
                } label: {
                    Text("Width")
                }

                Button {
                    self.width = self.height
                } label: {
                    Text("Height")
                }
            } label: {
                Text("Perfect .frame()")
            }
        }
    }

    func numberView(_ int: Int) -> some View {
        Text(String(int))
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.green)
            .clipShape(Circle())
            .background(Color.yellow)
    }

    private var nums: some View {
        ForEach(0...9, id: \.self) { int in
            numberView(int)
        }
    }

    private enum GridType: String, CaseIterable {
        case fixed
        case adaptive
        case flexible
        case stack

        func toType() -> GridItem.Size {
            switch self {
                case .fixed:
                    return .fixed(60)
                case .adaptive:
                    return .adaptive(minimum: 20, maximum: 200)
                case .flexible:
                    return .flexible(minimum: 20, maximum: 200)
                default:
                    return .fixed(60)
            }
        }
    }
}

#Preview {
    CalcView()
}

private struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack {
                    ForEach(0 ..< columns, id: \.self) { column in
                        content(row, column)
                    }
                }
            }
        }
    }

    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}

fileprivate extension View {
    func function(width: CGFloat, height: CGFloat) -> some View {
        self
            .frame(width: width, height: height, alignment: .center)
            .background(Color.black)
            .overlay {
                Rectangle()
                    .stroke(Color.red, lineWidth: 2.0)
                    .frame(width: width, height: height)
            }
    }
}
