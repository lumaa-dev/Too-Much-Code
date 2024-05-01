//Made by Lumaa
#if os(iOS)
import SwiftUI

struct CustomSheetView: View {
    @State private var showFullSheet: Bool = false
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Button {
                    showFullSheet.toggle()
                } label: {
                    Text("Show full sheet")
                }
            }
        } label: {
            Label("UIKit sheets", systemImage: "rectangle.stack")
        }
        .padding(.horizontal)
        .sheet(isPresented: $showFullSheet) {
            SheetView()
                .presentationCornerRadius(58)
                .sizedSheet()
        }
    }
}

struct SizedSheetStyle: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        return .init()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let rootView = uiView.viewBeforeWindow {
                rootView.frame = .init(
                    origin: CGPoint.zero,
                    size: .init(width: rootView.frame.width, height: rootView.frame.height)
                )
                
                rootView.bounds.size = .init(width: rootView.bounds.width, height: rootView.bounds.height + 140) // 140 is constant
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func sizedSheet() -> some View {
        self
            .presentationDragIndicator(.hidden)
            .presentationDetents([.large])
            .background(SizedSheetStyle())
    }
}

fileprivate extension UIView {
    var viewBeforeWindow: UIView? {
        if let superview, superview is UIWindow {
            return self
        }
        
        return superview?.viewBeforeWindow
    }
}

struct SheetView: View{
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                Text("This is a sub-view, from a sheet")
                Button {
                    dismiss()
                } label: {
                    Text("Dismiss")
                }
            }
            .padding(.horizontal)
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .overlay(alignment: .top) {
           grabber
        }
    }
    
    var grabber: some View {
        Capsule(style: .circular)
            .frame(width: 35, height: 5, alignment: .center)
            .safeAreaPadding()
            .background {
                Capsule(style: .circular)
                    .frame(width: 35, height: 5, alignment: .center)
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .foregroundStyle(Material.ultraThin)
    }
}

#Preview {
    CustomSheetView()
}
#endif
