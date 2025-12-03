////
////  CameraMV.swift
////  Glutinc
////
////  Created by saja khalid on 10/06/1447 AH.
////
//
//import SwiftUI
//import AVFoundation
//
//struct CameraPreview: UIViewRepresentable {
//    class VideoPreviewView: UIView {
//        override class var layerClass: AnyClass {
//            AVCaptureVideoPreviewLayer.self
//        }
//        
//        var previewLayer: AVCaptureVideoPreviewLayer {
//            return layer as! AVCaptureVideoPreviewLayer
//        }
//    }
//    
//    let session: AVCaptureSession
//    
//    func makeUIView(context: Context) -> VideoPreviewView {
//        let view = VideoPreviewView()
//        view.previewLayer.session = session
//        view.previewLayer.videoGravity = .resizeAspectFill
//        return view
//    }
//    
//    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
//}


//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: .zero)
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.bounds
//
//        view.layer.addSublayer(previewLayer)
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) { }
//}
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: .zero)
//        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.bounds
//        previewLayer.connection?.videoOrientation = .portrait // ⬅️ مهم للتأكد من الاتجاه
//        view.layer.addSublayer(previewLayer)
//        
//        // تحديث أبعاد الطبقة عند تغيير حجم الـ UIView
//        view.layer.layoutIfNeeded()
//        
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            previewLayer.frame = uiView.bounds
//        }
//    }
//}
import SwiftUI
import AVFoundation
//
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: .zero)
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.connection?.videoOrientation = .portrait
//        view.layer.addSublayer(previewLayer)
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            previewLayer.frame = uiView.bounds
//        }
//    }
//}
// 2️⃣ في CameraPreview
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.bounds
//        previewLayer.connection?.videoOrientation = .portrait
//        view.layer.addSublayer(previewLayer)
//        return view
//    }
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            previewLayer.frame = uiView.bounds
//        }
//    }
//}
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.connection?.videoOrientation = .portrait
//        view.layer.addSublayer(previewLayer)
//        return view
//    }
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            previewLayer.frame = uiView.bounds
//        }
//    }
//}
//import SwiftUI
//import AVFoundation
//
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        view.layer.addSublayer(previewLayer)
//
//
//        previewLayer.frame = UIScreen.main.bounds
//        view.layer.addSublayer(previewLayer)
//
//        // مهم جداً
//        context.coordinator.previewLayer = previewLayer
//
//        return view
//    }
//    class CameraPreviewUIView: UIView {
//        var previewLayer: AVCaptureVideoPreviewLayer?
//
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            previewLayer?.frame = bounds
//        }
//    }
//    
//
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        context.coordinator.previewLayer?.frame = UIScreen.main.bounds
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    class Coordinator {
//        var previewLayer: AVCaptureVideoPreviewLayer?
//    }
//}
