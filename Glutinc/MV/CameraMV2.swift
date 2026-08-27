//import SwiftUI
//import AVFoundation
//import Vision
//import Combine
//
//// MARK: - ViewModel
//@MainActor
//class CameraOCRViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    @Published var extractedText: String = ""
//    @Published var capturedImage: UIImage?
//    @Published var glutenFound: [GlutenIngredient] = []
//    
//    let session = AVCaptureSession()
//    private let photoOutput = AVCapturePhotoOutput()
//    
//    private let glutenStrict = [
//        "wheat","einkorn","durum","faro","farro","graham","kamut","semolina",
//        "spelt","wheat bran","wheat germ","cracked wheat","barley","rye",
//        "triticale","malt","malt extract","malt flavoring","malt vinegar"
//    ]
//    
//    private let glutenPossible = [
//        "oats","modified food starch","starch","natural flavor","yeast extract",
//        "autolyzed yeast","brown rice syrup","broth","bouillon","smoke flavor",
//        "soy sauce","seasoning","flavoring","sauce","gravy","breading",
//        "coating","marinade","beer","ale","lager"
//    ]
//    
//    func checkCameraPermissionAndStart() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            startCamera()
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                if granted {
//                    DispatchQueue.main.async { self.startCamera() }
//                }
//            }
//        default:
//            print("❌ الوصول للكاميرا مرفوض")
//        }
//    }
//    
//    func startCamera() {
//        session.beginConfiguration()
//        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
//              let input = try? AVCaptureDeviceInput(device: camera),
//              session.canAddInput(input),
//              session.canAddOutput(photoOutput) else { return }
//        
//        session.addInput(input)
//        session.addOutput(photoOutput)
//        session.commitConfiguration()
//        session.startRunning()
//    }
//    
//    func stopCamera() {
//        if session.isRunning { session.stopRunning() }
//    }
//    
//    func takePhoto() {
//        let settings = AVCapturePhotoSettings()
//        photoOutput.capturePhoto(with: settings, delegate: self)
//    }
//    
//    func photoOutput(_ output: AVCapturePhotoOutput,
//                     didFinishProcessingPhoto photo: AVCapturePhoto,
//                     error: Error?) {
//        guard let data = photo.fileDataRepresentation(),
//              let uiImage = UIImage(data: data) else { return }
//        self.capturedImage = uiImage
//        recognizeText(from: uiImage)
//    }
//    
//    func recognizeText(from image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        let request = VNRecognizeTextRequest { [weak self] request, _ in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
//            DispatchQueue.main.async {
//                self?.extractedText = text
//                self?.detectGluten(in: text)
//            }
//        }
//        request.recognitionLevel = .accurate
//        try? requestHandler.perform([request])
//    }
//    
//    private func detectGluten(in text: String) {
//        let lower = text.lowercased()
//        let words = lower.split { !$0.isLetter }.map { String($0) }
//        let allKeywords = glutenStrict + glutenPossible
//        var found: [GlutenIngredient] = []
//        
//        for word in words {
//            for keyword in allKeywords {
//                if similarity(word, keyword) > 0.7 {
//                    found.append(GlutenIngredient(name: keyword))
//                }
//            }
//        }
//        glutenFound = found
//    }
//    
//    private func similarity(_ s1: String, _ s2: String) -> Double {
//        let longer = max(s1.count, s2.count)
//        guard longer != 0 else { return 1.0 }
//        let distance = levenshtein(s1, s2)
//        return 1.0 - Double(distance) / Double(longer)
//    }
//    
//    private func levenshtein(_ aStr: String, _ bStr: String) -> Int {
//        let a = Array(aStr), b = Array(bStr)
//        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
//        for i in 0...a.count { dist[i][0] = i }
//        for j in 0...b.count { dist[0][j] = j }
//        for i in 1...a.count {
//            for j in 1...b.count {
//                dist[i][j] = min(
//                    dist[i-1][j] + 1,
//                    dist[i][j-1] + 1,
//                    dist[i-1][j-1] + (a[i-1] == b[j-1] ? 0 : 1)
//                )
//            }
//        }
//        return dist[a.count][b.count]
//    }
//}
//
//// MARK: - Camera Preview View
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = UIScreen.main.bounds
//        view.layer.addSublayer(previewLayer)
//        context.coordinator.previewLayer = previewLayer
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        context.coordinator.previewLayer?.frame = UIScreen.main.bounds
//    }
//    
//    func makeCoordinator() -> Coordinator { Coordinator() }
//    
//    class Coordinator {
//        var previewLayer: AVCaptureVideoPreviewLayer?
//    }
//}
import SwiftUI
import AVFoundation
import Combine

@MainActor
class CameraOCRViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    // ✅ المخرجات
    @Published var extractedText: String = ""
    @Published var capturedImage: UIImage?
    @Published var glutenFound: [GlutenIngredient] = []
    @Published var analysis = ScanAnalysisResult.empty
    @Published var detectedBarcodes: [String] = []
    @Published var captureSource: ScanCaptureSource = .camera
    @Published var libraryOriginalImage: UIImage?
    @Published var needsCaptureTips = false
    @Published var productEvidence = ProductEvidence(
        barcode: nil,
        extractedText: "",
        hasIngredientList: false,
        hasNutritionLabel: false,
        hasPackagingKeywords: false,
        recognizedIngredientCount: 0
    )
    private var subjectAreaObserver: NSObjectProtocol?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    // ✅ إعدادات الكاميرا
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDevice: AVCaptureDevice?   // ✅ مهم جدًا للفوكس
//    var status: ResultView.GlutenStatus {
//        if glutenFound.contains(where: { glutenStrict.contains($0.name) }) {
//            return .contains
//        } else if glutenFound.contains(where: { glutenPossible.contains($0.name) }) {
//            return .possible
//        } else if glutenFound.isEmpty {
//            return .safe
//        } else {
//            return .unknown
//        }
//    }
    var status: ScanAnalysisStatus {
        analysis.status
    }

    // ✅ فحص الصلاحية وتشغيل الكاميرا
    func checkCameraPermissionAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCamera()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    Task { @MainActor in
                        self.startCamera()
                    }
                }
            }

        default:
            print("❌ تم رفض صلاحية الكاميرا")
        }
    }

    func startCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if self.session.isRunning {
                self.session.stopRunning()
            }

            self.session.beginConfiguration()
            if self.session.canSetSessionPreset(.photo) {
                self.session.sessionPreset = .photo
            }

            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }

            let discovery = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInWideAngleCamera,
                    .builtInUltraWideCamera
                ],
                mediaType: .video,
                position: .back
            )

            guard let camera = discovery.devices.first(where: {
                $0.deviceType == .builtInWideAngleCamera
            }) ?? discovery.devices.first,
                  let input = try? AVCaptureDeviceInput(device: camera),
                  self.session.canAddInput(input),
                  self.session.canAddOutput(self.photoOutput) else {
                print("❌ فشل إعداد الكاميرا")
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)
            self.session.addOutput(self.photoOutput)
            if #available(iOS 16.0, *) {
                self.photoOutput.maxPhotoQualityPrioritization = .quality
            } else {
                self.photoOutput.isHighResolutionCaptureEnabled = true
            }

            self.session.commitConfiguration()
            self.videoDevice = camera
            self.session.startRunning()

            Task { @MainActor in
                self.setAutoFocus()
                if let observer = self.subjectAreaObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
                self.subjectAreaObserver = NotificationCenter.default.addObserver(
                    forName: .AVCaptureDeviceSubjectAreaDidChange,
                    object: self.videoDevice,
                    queue: .main
                ) { [weak self] _ in
                    Task { @MainActor in
                        self?.setAutoFocus()
                    }
                }
            }
        }
    }

    func stopCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            Task { @MainActor in
                if let observer = self.subjectAreaObserver {
                    NotificationCenter.default.removeObserver(observer)
                    self.subjectAreaObserver = nil
                }
            }
        }
    }


    // ✅ الفوكس التلقائي
    private func setAutoFocus() {
        guard let device = videoDevice else { return }

        do {
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near
            }

            device.isSubjectAreaChangeMonitoringEnabled = true
            device.unlockForConfiguration()

            // ✅ بعد أي ضبط فوكس نتحقق من العدسة المناسبة
            switchToBestCameraForDistance()

        } catch {
            print("❌ Focus error:", error)
        }
    }


    // ✅ Tap To Focus
    func focus(at point: CGPoint) {
        guard let device = videoDevice else { return }

        do {
            try device.lockForConfiguration()

            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .continuousAutoFocus   // ✅ أقوى من autoFocus
            }

            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .continuousAutoExposure
            }

            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .near   // ✅ للأشياء القريبة
            }

            device.unlockForConfiguration()
        } catch {
            print("❌ Tap to focus error:", error)
        }
    }
    private func switchToBestCameraForDistance() {
        guard let currentDevice = videoDevice else { return }

        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        )

        // ✅ قريب جدًا → UltraWide
        if currentDevice.lensPosition > 0.85 {
            if let ultraWide = discovery.devices.first(where: {
                $0.deviceType == .builtInUltraWideCamera
            }) {
                if ultraWide.uniqueID != currentDevice.uniqueID {
                    replaceCameraSafely(with: ultraWide)
                }
            }
        }
        // ✅ بعيد → Wide
        else {
            if let wide = discovery.devices.first(where: {
                $0.deviceType == .builtInWideAngleCamera
            }) {
                if wide.uniqueID != currentDevice.uniqueID {
                    replaceCameraSafely(with: wide) 
                }
            }
        }
    }

    private func replaceCameraSafely(with newDevice: AVCaptureDevice) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)

                self.session.beginConfiguration()

                // ✅ نوقف الجلسة قبل التغيير
                if self.session.isRunning {
                    self.session.stopRunning()
                }

                // ✅ نحذف كل الـ inputs
                self.session.inputs.forEach { self.session.removeInput($0) }

                // ✅ نضيف الجديد
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    self.videoDevice = newDevice
                }

                self.session.commitConfiguration()

                // ✅ نعيد تشغيل الجلسة
                self.session.startRunning()

                // ✅ نرجّع الفوكس على Main Thread
                DispatchQueue.main.async {
                    self.setAutoFocus()
                }

            } catch {
                print("❌ Failed to replace camera safely:", error)
            }
        }
    }



    // ✅ التقاط صورة
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        if #available(iOS 16.0, *) {
            settings.photoQualityPrioritization = .quality
        } else if photoOutput.isHighResolutionCaptureEnabled {
            settings.isHighResolutionPhotoEnabled = true
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    func toggleFlash(isOn: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flash error:", error)
        }
    }

    // ✅ استلام الصورة
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {

        guard let data = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: data) else { return }

        self.capturedImage = uiImage
        self.captureSource = .camera
        recognizeText(from: uiImage, cropToFocusGuide: true)
    }

    func recognizeText(from image: UIImage) {
        recognizeText(from: image, cropToFocusGuide: false)
    }

    func recognizeCroppedLibraryImage(_ image: UIImage) {
        captureSource = .photoLibrary
        capturedImage = image
        recognizeText(from: image, cropToFocusGuide: false)
    }

    func resetScanPresentation() {
        capturedImage = nil
        analysis = .empty
        glutenFound = []
        extractedText = ""
    }

    func recognizeText(from image: UIImage, cropToFocusGuide: Bool) {
        detectedBarcodes = ProductValidator.detectBarcodes(in: image)
        LabelOCRService.recognize(image: image, cropToFocusGuide: cropToFocusGuide) { [weak self] ocr in
            guard let self else { return }
            self.extractedText = ocr.originalText
            self.applyAnalysis(
                text: ocr.originalText,
                source: .ocr,
                observations: ocr.observations
            )
            self.productEvidence = ProductValidator.evidence(
                image: image,
                extractedText: ocr.originalText,
                analysis: self.analysis,
                knownBarcodes: self.detectedBarcodes
            )
        }
    }

    func reanalyzeEditedText(_ text: String) {
        extractedText = text
        applyAnalysis(text: text, source: .userEdited, observations: [])
        if let image = capturedImage {
            productEvidence = ProductValidator.evidence(
                image: image,
                extractedText: text,
                analysis: analysis,
                knownBarcodes: detectedBarcodes
            )
        }
    }

    private func applyAnalysis(
        text: String,
        source: ScanTextSource,
        observations: [OCRTextObservation]
    ) {
        let result = ScanAnalyzer.analyze(
            text: text,
            source: source,
            observations: observations
        )
        analysis = result
        needsCaptureTips = result.status == .unreadableIngredients || result.tooSmallForOCR
        glutenFound = result.glutenHits.map { GlutenIngredient(name: $0.name) }
            + result.ambiguousHits.map { GlutenIngredient(name: $0.name) }
            + result.unknownHits.map { GlutenIngredient(name: $0.name) }
    }
}


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
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
