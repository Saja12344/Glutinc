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
import Vision
import Combine

@MainActor
class CameraOCRViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {

    // ✅ المخرجات
    @Published var extractedText: String = ""
    @Published var capturedImage: UIImage?
    @Published var glutenFound: [GlutenIngredient] = []
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
    var status: ResultView.GlutenStatus {

        let strictNames = glutenStrict + glutenStrictAR
        let possibleNames = glutenPossible + glutenPossibleAR

        if glutenFound.contains(where: { strictNames.contains($0.name) }) {
            return .contains
        }

        if glutenFound.contains(where: { possibleNames.contains($0.name) }) {
            return .possible
        }

        // ⭐ OCR قرأ نص واضح
        if extractedText.count > 20 {
            return .safe
        }

        return .unknown
    }

    // ✅ كلمات الغلوتين
    private let glutenStrict = [
        // Grains & Flours
        "wheat",
        "barley",
        "rye",
        "malt",
        "malt flavoring",
        "malt vinegar",
        "regular pasta",
        "flour tortillas",
        "pretzels",
        "matzo",

        // Potatoes
        "french fries fried with other foods",

        // Dairy
        "malted milk",

        // Eggs
        "eggs benedict",

        // Meat & Poultry
        "breaded meat",
        "flour coated meat",

        // Soy & Alternatives
        "seitan",
        "3-grain tempeh",

        // Nuts & Fruits & Vegetables
        "flour coated nuts",
        "fruits with flour sauce",
        "vegetables with flour sauce",

        // Sauces & Seasonings
        "regular soy sauce",
        "sauces containing flour",

        // Beverages
        "beer",
//        "ale",
        "lager",
        "gluten-removed beer"
    ]


    private let glutenPossible = [
        // Grains
        "oats (uncontaminated only)",
        "rice products with flavorings",
        "seasoned chips",

        // Potatoes
        "french fries (shared fryer)",

        // Dairy
        "flavored yogurt",
        "flavored cheese spreads",

        // Meat
        "marinated meat",

        // Soy
        "miso",

        // Beans
        "flavored canned beans",

        // Dressings
        "dressings",

        // Beverages
        "flavored almond milk",
        "flavored soy milk"
    ]
    private let glutenFreeSafe = [
        // Grains & Flours
        "amaranth",
        "arrowroot",
        "buckwheat",
        "corn",
        "cornstarch",
        "flax",
        "millet",
        "quinoa",
        "polenta",
        "plain rice",
        "sorghum",
        "tapioca",
        "teff",
        "gluten-free pasta",
        "corn tortillas",
        "plain corn chips",
        "plain potato chips",

        // Potatoes
        "plain potatoes",
        "sweet potatoes",

        // Dairy
        "milk",
        "plain yogurt",
        "cream",
        "cheese",

        // Eggs
        "regular eggs",

        // Meat & Fish
        "unprocessed meat",

        // Soy
        "tofu",
        "edamame",
        "regular tempeh",

        // Nuts & Seeds & Beans
        "all natural nuts",
        "all natural seeds",
        "all natural beans",

        // Fruits & Vegetables
        "all natural fruits",
        "all natural vegetables",

        // Oils & Seasonings
        "butter",
        "oils",
        "salt",
        "pepper",
        "honey",
        "jam",
        "gluten-free soy sauce",

        // Beverages
        "coffee",
        "tea",
        "juices"
    ]
    private let glutenStrictAR = [
        "قمح", "شعير", "جاودار", "مالت", "نكهة المالت", "خل المالت",
        "مكرونة عادية", "تورتيلا دقيق", "بريتزل", "ماتزو",
        "بطاطس مقلية بزيت مشترك",
        "حليب مملت", "بيض بندكت",
        "لحم مغطى بالبقسماط", "لحم مغطى بالدقيق",
        "سيتان", "تمبيه ثلاثي الحبوب",
        "مكسرات مغطاة بالدقيق", "فواكه بصلصة دقيق", "خضار بصلصة دقيق",
        "صويا صوص عادي", "صلصات فيها دقيق",
        "بيرة", "إيل", "لايغر", "بيرة منزوعة الغلوتين"
    ]
    private let glutenPossibleAR = [
        "شوفان", "منتجات أرز منكهة", "شيبس منكه",
        "بطاطس مقلية بزيت مشترك",
        "زبادي منكه", "جبن منكه",
        "لحم متبل",
        "ميسو",
        "فاصوليا معلبة منكهة",
        "تتبيلات",
        "حليب لوز منكه", "حليب صويا منكه"
    ]
    private let glutenFreeSafeAR = [
        "قطيفة", "أروروت", "حنطة سوداء", "ذرة", "نشا الذرة", "بذور الكتان",
        "دخن", "كينوا", "بولينتا", "أرز عادي", "ذرة رفيعة", "تابيوكا",
        "تيف", "مكرونة خالية من الغلوتين", "تورتيلا ذرة",
        "شيبس ذرة", "شيبس بطاطس",
        "بطاطس عادية", "بطاطس حلوة",
        "حليب", "زبادي طبيعي", "كريمة", "جبن",
        "بيض",
        "لحم غير معالج",
        "توفو", "إدامامي", "تمبيه عادي",
        "مكسرات طبيعية", "بذور طبيعية", "بقوليات طبيعية",
        "فواكه طبيعية", "خضروات طبيعية",
        "زبدة", "زيوت", "ملح", "فلفل", "عسل", "مربى",
        "صويا صوص خالي من الغلوتين",
        "قهوة", "شاي", "عصائر"
    ]



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
        if session.isRunning { return }

        session.beginConfiguration()

        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,
                .builtInUltraWideCamera   // ✅ تدعم الماكرو
            ],
            mediaType: .video,
            position: .back
        )

        // ✅ نختار العدسة الأفضل (Wide أولاً ثم UltraWide عند القرب)
        guard let camera = discovery.devices.first(where: {
            $0.deviceType == .builtInWideAngleCamera
        }) ?? discovery.devices.first,
        let input = try? AVCaptureDeviceInput(device: camera),
        session.canAddInput(input),
        session.canAddOutput(photoOutput) else {

            print("❌ فشل إعداد الكاميرا")
            session.commitConfiguration()
            return
        }

        // ✅ إزالة أي Inputs قديمة
        session.inputs.forEach { session.removeInput($0) }

        session.addInput(input)
        session.addOutput(photoOutput)

        session.commitConfiguration()
        session.startRunning()

        // ✅ نخزّن الجهاز للفوكس
        videoDevice = camera

        // ✅ تفعيل سلوك الوردة (ماكرو)
        setAutoFocus()

        // ✅ إعادة الفوكس تلقائيًا عند تغيّر المشهد
        // ✅ إزالة أي observer قديم قبل إضافة الجديد
        if let observer = subjectAreaObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        subjectAreaObserver = NotificationCenter.default.addObserver(
            forName: .AVCaptureDeviceSubjectAreaDidChange,
            object: videoDevice,
            queue: .main
        ) { [weak self] _ in
            self?.setAutoFocus()
        }

    }

    // ✅ إيقاف الكاميرا
    func stopCamera() {
        if session.isRunning {
            session.stopRunning()
        }

        if let observer = subjectAreaObserver {
            NotificationCenter.default.removeObserver(observer)
            subjectAreaObserver = nil
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
        recognizeText(from: uiImage)
    }

    // ✅ OCR
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")

            DispatchQueue.main.async {
                self?.extractedText = text
                self?.detectGluten(in: text)
            }
        }

        request.recognitionLevel = .accurate
        try? requestHandler.perform([request])
    }

    // ✅ تحليل الغلوتين
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
//
//        glutenFound = found
//    }
    var allStrict: [String] {
        glutenStrict + glutenStrictAR
    }

    var allPossible: [String] {
        glutenPossible + glutenPossibleAR
    }

//    private func detectGluten(in text: String) {
//        let lower = text.lowercased()
//
//        var found: [GlutenIngredient] = []
//        var matchedKeywords = Set<String>() // ✅ لمنع التكرار
//        var didMatchAnything = false        // ✅ لمعرفة هل تعرفنا على أي مكوّن
//
//        // ✅ أولاً: Strict (خطر)
//        for keyword in allStrict {
//            if lower.contains(keyword.lowercased()) {
//                didMatchAnything = true
//                if !matchedKeywords.contains(keyword) {
//                    matchedKeywords.insert(keyword)
//                    found.append(GlutenIngredient(name: keyword))
//                }
//            }
//        }
//
//        // ✅ ثانياً: Possible (محتمل)
//        for keyword in allPossible {
//            if lower.contains(keyword.lowercased()) {
//                didMatchAnything = true
//                if !matchedKeywords.contains(keyword) {
//                    matchedKeywords.insert(keyword)
//                    found.append(GlutenIngredient(name: keyword))
//                }
//            }
//        }
//
//        // ✅ ثالثاً: تحديد النتيجة النهائية
////        if found.isEmpty {
////            if didMatchAnything {
////                // تم التعرف على كلمات لكن ليست خطرة
////                found.append(GlutenIngredient(name: "Safe"))
////            } else {
////                // لم يتم التعرف على أي مكونات معروفة
////                found.append(GlutenIngredient(name: "Unknown ❔"))
////            }
////        }
////
////        glutenFound = found
//        if found.isEmpty {
//            // إذا في كلمات من سياق المكونات → نقول Unknown
//            if containsFoodContext {
//                found.append(GlutenIngredient(name: "Unknown ❔"))
//            } else {
//                // بدون مكونات: نخلي القائمة فاضية
//                found = []
//            }
//        }
//
//    }
    private func detectGluten(in text: String) {

        let enText = normalizeEnglish(text)
        let arText = normalizeArabic(text)

        var found: [GlutenIngredient] = []
        var matched = Set<String>()

        // 🔴 Strict
        for keyword in glutenStrict {
            if enText.contains(keyword) {
                matched.insert(keyword)
                found.append(GlutenIngredient(name: keyword))
            }
        }

        for keyword in glutenStrictAR {
            if arText.contains(normalizeArabic(keyword)) {
                matched.insert(keyword)
                found.append(GlutenIngredient(name: keyword))
            }
        }

        // 🟠 Possible
        for keyword in glutenPossible {
            if enText.contains(keyword) {
                matched.insert(keyword)
                found.append(GlutenIngredient(name: keyword))
            }
        }

        for keyword in glutenPossibleAR {
            if arText.contains(normalizeArabic(keyword)) {
                matched.insert(keyword)
                found.append(GlutenIngredient(name: keyword))
            }
        }

        // ✅ نحفظ فقط المكونات
        glutenFound = found
    }
    private func normalizeArabic(_ text: String) -> String {
        text
            .replacingOccurrences(of: "[ًٌٍَُِّْ]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "أ", with: "ا")
            .replacingOccurrences(of: "إ", with: "ا")
            .replacingOccurrences(of: "آ", with: "ا")
            .replacingOccurrences(of: "ى", with: "ي")
            .replacingOccurrences(of: "ة", with: "ه")
    }

    private func normalizeEnglish(_ text: String) -> String {
        text.lowercased()
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

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
