// Made by Lumaa
#if os(macOS)

import SwiftUI
import UniformTypeIdentifiers

@available(macOS 15.0, *)
struct ImageGradient: View {
    @State private var colors: [Color] = [
        Color.red, Color.orange, Color.yellow,
        Color.green, Color.purple, Color.blue,
        Color.teal, Color.indigo, Color.brown
    ]

    @State var showBalls: Bool = true // hehe "balls"

    @State private var points: [SIMD2<Float>] = [
        .init(x: 0.0, y: 0.0), .init(x: 0.5, y: 0.0), .init(x: 1.0, y: 0.0),
        .init(x: 0.0, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: 1.0, y: 0.5),
        .init(x: 0.0, y: 1.0), .init(x: 0.5, y: 1.0), .init(x: 1.0, y: 1.0)
    ]
    @State private var selectedI: Int = -1
    @State private var offsetPoint: CGSize = .zero

    @State private var showColorChange: Bool = false
    @State private var colorChangeI: Int = -1
    @State private var colorChange: Color = Color.blue

    @State private var xColor: Int = 3
    @State private var yColor: Int = 3

    @State private var size: CGSize = .init(width: 300, height: 300)

    @State private var showChangeSize: Bool = false
    @State private var changeSizeX: String = "300"
    @State private var changeSizeY: String = "300"

    var body: some View {
        MeshGradient(width: xColor, height: yColor, points: points, colors: colors)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay {
                if showBalls {
                    ZStack {
                        ForEach(points, id:\.self) { point in
                            pointCircle(point)
                        }
                    }
                }
            }
            .contextMenu {
                Button {
                    showChangeSize = true
                } label: {
                    Text("Change Canvas size")
                }
            }
            .padding(30)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        Button {
                            addRow()
                        } label: {
                            Label("Add Horizontally", systemImage: "arrow.left.and.right")
                        }

                        Button {
                            addColumn()
                        } label: {
                            Label("Add Vertically", systemImage: "arrow.up.and.down")
                        }

                        Divider()

                        Button {
                            removeRow()
                        } label: {
                            Label("Remove Horizontally", systemImage: "arrow.left.and.right")
                        }

                        Button {
                            removeColumn()
                        } label: {
                            Label("Remove Vertically", systemImage: "arrow.up.and.down")
                        }
                    } label: {
                        Label("Grid of Points", systemImage: "circle.grid.3x3.fill")
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        fixPointsDistance()
                    } label: {
                        Label("Reset points positions", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showBalls = false
                        if let url = self.savePanel(for: .png) {
                            self.save(at: url)
                        }
                        showBalls = true
                    } label: {
                        Label("Picture", systemImage: "photo.badge.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showColorChange) {
                self.colors[colorChangeI] = self.colorChange
            } content: {
                VStack {
                    ColorPicker(selection: $colorChange) { Text("Color of the Point") }
                    Button {
                        self.showColorChange = false
                    } label: {
                        Text("Done")
                    }
                }
                .padding(.horizontal)
            }
            .sheet(isPresented: $showChangeSize) {
                let cgfx: Float = Float(changeSizeX) ?? 300.0
                let cgfy: Float = Float(changeSizeY) ?? 300.0

                let newSize: CGSize = .init(width: CGFloat(cgfx), height: CGFloat(cgfy))
                self.size = newSize
            } content: {
                VStack(spacing: 10) {
                    TextField("Horizontal Scale", text: $changeSizeX)
                        .font(.title2)
                    TextField("Vertical Scale", text: $changeSizeY)
                        .font(.title2)
                }
                .padding(.horizontal)
            }
    }

    @ViewBuilder
    func pointCircle(_ point: SIMD2<Float>) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 17, height: 17)
            .offset(selectedI == self.points.firstIndex(of: point) ?? -1 ? offsetPoint : .zero)
            .contextMenu {
                Button {
                    let i = self.points.firstIndex(where: { $0 == point }) ?? -1

                    self.colorChangeI = i
                    self.colorChange = Color.blue
                    self.showColorChange = true
                } label: {
                    Label("Change point color", systemImage: "paintpalette")
                }
            }
            .gesture(DragGesture()
                .onChanged { event in
                    let i: Int = self.points.firstIndex(where: { $0 == point }) ?? -1
                    selectedI = i
                    offsetPoint = event.translation
                }
                .onEnded { event in
                    var moveable: SIMD2<Float> = self.points[self.selectedI]

                    moveable.x += min(Float(event.translation.width / self.size.width), 1.0)
                    moveable.y += min(Float(event.translation.height / self.size.height), 1.0)

                    moveable.x = max(0.0, min(moveable.x, 1.0))
                    moveable.y = max(0.0, min(moveable.y, 1.0))

                    self.points[self.selectedI] = moveable

                    self.selectedI = -1
                    self.offsetPoint = .zero
                }
            )
            .position(x: CGFloat(point.x) * size.width, y: CGFloat(point.y) * size.height)
    }

    //MARK: - Grid Functions

    func addRow() {
        xColor += 1

        let yPosition = Float(yColor - 1) / Float(yColor - 1)

        for x in 0..<xColor {
            let xPosition = Float(x) / Float(xColor - 1)
            points.append(SIMD2<Float>(xPosition, yPosition))
            colors.append(Color.random)
        }

        fixPointsDistance()
    }

    func addColumn() {
        yColor += 1

        for y in 0..<yColor {
            let yPosition = Float(y) / Float(yColor - 1)
            let xPosition = Float(xColor - 1) / Float(xColor - 1)
            let index = y * (xColor - 1) + xColor - 1

            points.insert(SIMD2<Float>(xPosition, yPosition), at: index + y)
            colors.insert(Color.random, at: index + y)
        }

        fixPointsDistance()
    }

    func removeRow() {
        xColor -= 1

        let currentRows = Int(sqrt(Double(points.count)))
        guard currentRows > 1 else { return } // Prevent removing the last row

        points.removeLast(currentRows)
        colors.removeLast(currentRows)

        fixPointsDistance()
    }

    func removeColumn() {
        yColor -= 1

        let currentRows = Int(sqrt(Double(points.count)))
        guard currentRows > 1 else { return } // Prevent removing the last column

        for i in stride(from: currentRows - 1, through: 0, by: -1) {
            points.remove(at: i * currentRows + (currentRows - 1))
            colors.remove(at: i * currentRows + (currentRows - 1))
        }

        fixPointsDistance()
    }

    func fixPointsDistance() {
        let xStep = 1.0 / Float(xColor - 1)
        let yStep = 1.0 / Float(yColor - 1)

        for y in 0..<yColor {
            for x in 0..<xColor {
                let pointIndex = y * xColor + x
                points[pointIndex] = SIMD2<Float>(Float(x) * xStep, Float(y) * yStep)
            }
        }
    }

    //MARK: - Save Gradient

    private func savePanel(for type: UTType) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [type]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save the ImageGradient as an image"
        savePanel.message = "Choose a folder and a name to store the image."
        savePanel.nameFieldLabel = "Image file name:"

        return savePanel.runModal() == .OK ? savePanel.url : nil
    }

    func save(at url: URL) {
        guard let cgImage = ImageRenderer(content: self).cgImage else {
            return
        }

        let image = NSImage(cgImage: cgImage, size: self.size)
        guard let representation = image.tiffRepresentation else { return }
        let imageRepresentation = NSBitmapImageRep(data: representation)

        let imageData: Data?
        imageData = imageRepresentation?.representation(using: .png, properties: [:])

        try? imageData?.write(to: url)
    }
}

extension Color {
    static var random: Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)

        return Color(red: red, green: green, blue: blue)
    }
}

@available(macOS 15.0, *)
#Preview {
    NavigationStack {
        ImageGradient()
    }
}
#endif
