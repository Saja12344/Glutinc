//
//import SwiftUI
//
//struct GlutenScannerView: View {
//    
//    @StateObject private var vm = GlutenScannerViewModel()
//    @State private var startCamera = false
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            
//            Button {
//                startCamera = true
//            } label: {
//                Text("📸 التقط صورة للمكونات")
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//            }
//            
//            if !vm.extractedText.isEmpty {
//                Text("النص المستخرج:")
//                    .font(.headline)
//                
//                ScrollView {
//                    Text(vm.extractedText)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                }
//                .frame(height: 150)
//            }
//            
//            if !vm.glutenFound.isEmpty {
//                Text("🚨 يحتوي على غلوتن:")
//                    .foregroundColor(.red)
//                    .font(.headline)
//                
//                ForEach(vm.glutenFound) { ingredient in
//                    Text("• \(ingredient.name)")
//                        .foregroundColor(.red)
//                }
//            }
//        }
//        .padding()
//        // 3️⃣ في GlutenScannerView: شغل الكاميرا عند ظهور fullScreenCover وليس في onAppear العادي
//        .fullScreenCover(isPresented: $startCamera) {
//            ZStack {
//                CameraPreview(session: vm.session)
//                    .edgesIgnoringSafeArea(.all)
//                    .onAppear {
//                        vm.startCamera() // شغّل الكاميرا بعد ظهور الشاشة
//                    }
//                    .onDisappear {
//                        vm.stopCamera() // وقف الكاميرا عند إغلاق الشاشة
//                    }
//                
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button(action: { startCamera = false }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.white)
//                                .opacity(0.8)
//                        }
//                    }
//                    .padding()
//                    Spacer()
//                }
//            }
//        }
//
//
//
//
//
//    }
//    }
//
//import SwiftUI
//import AVFoundation
//import UIKit
//import Combine


//
//struct GlutenScannerCameraView: View {
//    @StateObject private var vm = GlutenScannerViewModel()
//    @State private var showCamera = false
//    @State private var showImagePicker = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//
//            // زر فتح الكاميرا
//            Button("📸 التقط صورة") {
//                showCamera = true
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(12)
//
//            // زر اختيار صورة من الألبوم
//            Button("🖼️ اختر صورة من الجهاز") {
//                showImagePicker = true
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.green)
//            .foregroundColor(.white)
//            .cornerRadius(12)
//
//            // عرض النص المستخرج
//            if !vm.extractedText.isEmpty {
//                Text("النص المستخرج:")
//                    .font(.headline)
//                
//                ScrollView {
//                    Text(vm.extractedText)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                }
//                .frame(height: 150)
//            }
//
//            // عرض مكونات الغلوتين المكتشفة
//            if !vm.glutenFound.isEmpty {
//                Text("🚨 يحتوي على غلوتن:")
//                    .foregroundColor(.red)
//                    .font(.headline)
//                
//                ForEach(vm.glutenFound) { item in
//                    Text("• \(item.name)")
//                        .foregroundColor(.red)
//                }
//            }
//
//        }
//        .padding()
//        // كاميرا full screen
//        .fullScreenCover(isPresented: $showCamera) {
//            ZStack {
//                CameraPreview(session: vm.session)
//                    .edgesIgnoringSafeArea(.all)
//                    .onAppear { vm.startCamera() }
//                    .onDisappear { vm.stopCamera() }
//
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button(action: { showCamera = false }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.white)
//                                .opacity(0.8)
//                        }
//                    }
//                    .padding()
//                    Spacer()
//                }
//            }
//        }
//        // ImagePicker sheet
//        .sheet(isPresented: $showImagePicker) {
//            ImagePicker { image in
//                vm.scan(image: image)
//            }
//        }
//    }
////}
//struct GlutenScannerCameraView: View {
//    @StateObject private var vm = GlutenScannerViewModel()
//    @State private var showCamera = false
//    @State private var showImagePicker = false
//    
//
//    var body: some View {
//        VStack(spacing: 20) {
//
//            Button("📸 التقط صورة") {
//                showCamera = true
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(12)
//
//            Button("🖼️ اختر صورة من الجهاز") {
//                showImagePicker = true
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.green)
//            .foregroundColor(.white)
//            .cornerRadius(12)
//
//            if !vm.extractedText.isEmpty {
//                Text("النص المستخرج:")
//                    .font(.headline)
//                ScrollView {
//                    Text(vm.extractedText)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                }
//                .frame(height: 150)
//            }
//
//            if !vm.glutenFound.isEmpty {
//                Text("🚨 يحتوي على غلوتن:")
//                    .foregroundColor(.red)
//                    .font(.headline)
//                ForEach(vm.glutenFound) { item in
//                    Text("• \(item.name)").foregroundColor(.red)
//                }
//            }
//
//        }
//        .padding()
//        .fullScreenCover(isPresented: $showCamera) {
//            ZStack {
//                CameraPreview(session: vm.session)
//                    .edgesIgnoringSafeArea(.all)
//                    .onAppear { vm.checkCameraPermissionAndStart() }
//                    .onDisappear { vm.stopCamera() }
//
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button(action: { showCamera = false }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.white)
//                                .opacity(0.8)
//                        }
//                    }
//                    .padding()
//                    Spacer()
//                }
//            }
//        }
//        .sheet(isPresented: $showImagePicker) {
//            ImagePicker { image in
//                vm.scan(image: image)
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//struct GlutenScannerCameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        GlutenScannerCameraView()
//    }
//}
