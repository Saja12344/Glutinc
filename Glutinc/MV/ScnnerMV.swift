//import SwiftUI
//import AVFoundation
//import UIKit
//import Combine
//
//class ScannerViewModel: ObservableObject {
//    
//    // استخدم @Published لتحديث الـ Preview عند إنشاء/تغيير الجلسة
//    @Published var session = AVCaptureSession()
//    
//    private let sessionQueue = DispatchQueue(label: "cameraQueue")
//    private var isConfigured = false
//    private var isStarting = false
//    
//    // OCR
//    @Published var extractedText: String = ""
//    @Published var glutenFound: [GlutenIngredient] = []
//    
////    init() {}
//    
//    // MARK: - طلب الإذن ثم تشغيل الكاميرا
//    func requestPermissionAndStart() {
//        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//            guard let self else { return }
//            DispatchQueue.main.async {
//                if granted {
//                    self.startCamera()
//                } else {
//                    print("❌ Camera access not granted")
//                }
//            }
//        }
//    }
//      
//
//        func startCamera() {
//            session.beginConfiguration()
//            
//            // إضافة مدخل الكاميرا
//            guard let camera = AVCaptureDevice.default(for: .video),
//                  let input = try? AVCaptureDeviceInput(device: camera),
//                  session.canAddInput(input) else { return }
//            session.addInput(input)
//            
//            // إضافة المخرجات (مثلاً صورة)
//            let output = AVCaptureVideoDataOutput()
//            if session.canAddOutput(output) {
//                session.addOutput(output)
//            }
//            
//            session.commitConfiguration()
//            session.startRunning()
//        }
//
//        func stopCamera() {
//            if session.isRunning {
//                session.stopRunning()
//            }
//        }
//
//    // MARK: - إعداد الكاميرا
//    private func configureCamera() {
//        session.beginConfiguration()
//        
//        // إزالة أي مدخلات/مخرجات قديمة
//        for input in session.inputs {
//            session.removeInput(input)
//        }
//        for output in session.outputs {
//            session.removeOutput(output)
//        }
//        
//        // اختيار الكاميرا الخلفية
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
//                                                   for: .video,
//                                                   position: .back) else {
//            print("❌ No back camera device available")
//            session.commitConfiguration()
//            return
//        }
//        
//        do {
//            let input = try AVCaptureDeviceInput(device: device)
//            if session.canAddInput(input) {
//                session.addInput(input)
//            } else {
//                print("❌ Cannot add camera input")
//            }
//        } catch {
//            print("❌ Failed to create camera input: \(error)")
//        }
//        
//        // Output للفيديو (لو بتحتاج معالجة إطارات لاحقاً)
//        let output = AVCaptureVideoDataOutput()
//        output.alwaysDiscardsLateVideoFrames = true
//        if session.canAddOutput(output) {
//            session.addOutput(output)
//        } else {
//            print("❌ Cannot add video output")
//        }
//        
//        session.commitConfiguration()
//        isConfigured = true
//    }
//    
//    // MARK: - OCR
//    func scan(image: UIImage) {
//        OCRService.shared.extractText(from: image) { text in
//            DispatchQueue.main.async {
//                self.extractedText = text
//                self.detectGluten(in: text)
//            }
//        }
//    }
//    
//    // MARK: - تحليل الغلوتين
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
//    private func detectGluten(in text: String) {
//        let lower = text.lowercased()
//        let words = lower.split { !$0.isLetter }.map { String($0) }
//        
//        var found: [GlutenIngredient] = []
//        let allKeywords = glutenStrict + glutenPossible
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
//    
//    // MARK: - Levenshtein
//    func similarity(_ s1: String, _ s2: String) -> Double {
//        let longer = max(s1.count, s2.count)
//        guard longer != 0 else { return 1.0 }
//        
//        let distance = levenshtein(s1, s2)
//        return 1.0 - Double(distance) / Double(longer)
//    }
//    
//    func levenshtein(_ aStr: String, _ bStr: String) -> Int {
//        let a = Array(aStr)
//        let b = Array(bStr)
//
//        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
//
//        for i in 0...a.count { dist[i][0] = i }
//        for j in 0...b.count { dist[0][j] = j }
//
//        for i in 1...a.count {
//            for j in 1...b.count {
//                dist[i][j] = min(
//                    dist[i-1][j] + 1,
//                    dist[i][j-1] + 1,
//                    dist[i-1][j-1] + (a[i-1] == b[j-1] ? 0 : 1)
//                )
//            }
//        }
//
//        return dist[a.count][b.count]
//    }
//}
