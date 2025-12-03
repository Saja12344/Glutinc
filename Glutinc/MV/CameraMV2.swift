import SwiftUI
import AVFoundation
import Vision
import Combine

// MARK: - ViewModel
@MainActor
class CameraOCRViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var extractedText: String = ""
    @Published var capturedImage: UIImage?
    @Published var glutenFound: [GlutenIngredient] = []
    
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    private let glutenStrict = [
        "wheat","einkorn","durum","faro","farro","graham","kamut","semolina",
        "spelt","wheat bran","wheat germ","cracked wheat","barley","rye",
        "triticale","malt","malt extract","malt flavoring","malt vinegar"
    ]
    
    private let glutenPossible = [
        "oats","modified food starch","starch","natural flavor","yeast extract",
        "autolyzed yeast","brown rice syrup","broth","bouillon","smoke flavor",
        "soy sauce","seasoning","flavoring","sauce","gravy","breading",
        "coating","marinade","beer","ale","lager"
    ]
    
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
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: data) else { return }
        self.capturedImage = uiImage
        recognizeText(from: uiImage)
    }
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            DispatchQueue.main.async {
                self?.extractedText = text
                self?.detectGluten(in: text)
            }
        }
        request.recognitionLevel = .accurate
        try? requestHandler.perform([request])
    }
    
    private func detectGluten(in text: String) {
        let lower = text.lowercased()
        let words = lower.split { !$0.isLetter }.map { String($0) }
        let allKeywords = glutenStrict + glutenPossible
        var found: [GlutenIngredient] = []
        
        for word in words {
            for keyword in allKeywords {
                if similarity(word, keyword) > 0.7 {
                    found.append(GlutenIngredient(name: keyword))
                }
            }
        }
        glutenFound = found
    }
    
    private func similarity(_ s1: String, _ s2: String) -> Double {
        let longer = max(s1.count, s2.count)
        guard longer != 0 else { return 1.0 }
        let distance = levenshtein(s1, s2)
        return 1.0 - Double(distance) / Double(longer)
    }
    
    private func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr), b = Array(bStr)
        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                dist[i][j] = min(
                    dist[i-1][j] + 1,
                    dist[i][j-1] + 1,
                    dist[i-1][j-1] + (a[i-1] == b[j-1] ? 0 : 1)
                )
            }
        }
        return dist[a.count][b.count]
    }
}

// MARK: - Camera Preview View
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = UIScreen.main.bounds
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
