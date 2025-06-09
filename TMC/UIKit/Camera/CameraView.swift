// Made by Lumaa
#if os(iOS)
import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    let cameraManager: CameraManager = .init()

    var body: some View {
        ZStack {
            CameraPreview(source: cameraManager.source)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    cameraManager.toggleRunning()
                    dismiss()
                } label: {
                    Label(String("Back"), systemImage: "chevron.backward")
                }
            }
        }
        .task {
            await start()
        }
    }

    private func start() async {
        if await cameraManager.isAuthorized {
            cameraManager.setup(starts: true)
        }
    }
}

#Preview {
    CameraView()
}
#endif
