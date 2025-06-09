// Made by Lumaa
#if canImport(UIKit)
import SwiftUI
import UIKit
import Foundation
import AVFoundation

final class CameraManager {
    static var session: AVCaptureSession = .init()
    var source: CameraSource

    init(source: CameraSource) {
        self.source = source
    }

    init() {
        self.source = PreviewSource(session: Self.session)
    }

    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)

            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized

            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }

            return isAuthorized
        }
    }

    var isCameraRunning: Bool = false
    private var alreadySetup: Bool = false

    func setup(starts: Bool = false) {
        if !alreadySetup {
            Self.session.beginConfiguration()
            let videoDevice = self.getBackCamera()
            guard
                let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                Self.session.canAddInput(videoDeviceInput)
            else { return }
            Self.session.addInput(videoDeviceInput)

            let photoOutput = AVCapturePhotoOutput()
            guard Self.session.canAddOutput(photoOutput) else { return }
            Self.session.sessionPreset = .photo
            Self.session.addOutput(photoOutput)
            Self.session.commitConfiguration()
            self.alreadySetup = true
        }

        if starts {
            Self.session.startRunning()
            self.isCameraRunning = true
        }
    }

    func toggleRunning() {
        if !Self.session.isRunning {
            Self.session.startRunning()
            self.isCameraRunning = true
        } else {
            Self.session.stopRunning()
            self.isCameraRunning = false
        }
    }

    private func getBackCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device.")
        }
    }

//    func capturePhoto() async {
//        do {
//            let photo = try await captureService.capturePhoto(with: photoFeatures.current)
//            try await mediaLibrary.save(photo: photo)
//        } catch {
//            self.error = error
//        }
//    }

//    private func handlePhoto() async throws {
//        // Wrap the delegate-based capture API in a continuation to use it in an async context.
//        try await withCheckedThrowingContinuation { continuation in
//
//            // Create a settings object to configure the photo capture.
//            let photoSettings = AVCapturePhotoSettings()
//            photoSettings.flashMode = .off
//
//            let delegate = PhotoCaptureDelegate(continuation: continuation)
//            monitorProgress(of: delegate)
//
//            // Capture a new photo with the specified settings.
//            photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
//        }
//    }
}

struct CameraPreview: UIViewRepresentable {
    private let source: CameraSource

    init(source: CameraSource) {
        self.source = source
    }

    func makeUIView(context: Context) -> PreviewView {
        let preview = PreviewView()
        // Connect the preview layer to the capture session.
        source.connect(to: preview)
        return preview
    }

    func updateUIView(_ previewView: PreviewView, context: Context) {}

    class PreviewView: UIView, CameraTarget {
        init() {
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }

        func setSession(_ session: AVCaptureSession) {
            previewLayer.session = session
        }
    }
}

struct PreviewSource: CameraSource {

    private let session: AVCaptureSession

    init(session: AVCaptureSession) {
        self.session = session
    }

    func connect(to target: CameraTarget) {
        target.setSession(session)
    }
}

//target = uikit
//source = avcapturesession

protocol CameraSource {
    func connect(to target: CameraTarget)
}

protocol CameraTarget {
    func setSession(_ session: AVCaptureSession)
}
#endif
