import SwiftUI
import AVFoundation
import Combine
import Vision

@MainActor
class CameraOCRViewModel: ObservableObject {
    @Published var extractedText: String = ""
    @Published var capturedImage: UIImage?

    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()

    func checkCameraPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async { self.startCamera() }
                }
            }
        default:
            print("❌ الوصول للكاميرا مرفوض")
        }
    }

    func startCamera() {
        session.beginConfiguration()
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input),
              session.canAddOutput(photoOutput) else { return }

        session.addInput(input)
        session.addOutput(photoOutput)
        session.commitConfiguration()
        session.startRunning()
    }

    func stopCamera() {
        if session.isRunning { session.stopRunning() }
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            DispatchQueue.main.async {
                self?.extractedText = text
            }
        }
        request.recognitionLevel = .accurate
        try? requestHandler.perform([request])
    }
}

// MARK: - Delegate
extension CameraOCRViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: data) else { return }
        self.capturedImage = uiImage
        recognizeText(from: uiImage)
    }
}
