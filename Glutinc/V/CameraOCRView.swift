
import SwiftUI

struct CameraView: View {
    
    @StateObject private var cameraVM = CameraOCRViewModel()
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @Environment(\.layoutDirection) var layoutDirection
    @State private var isFlashOn = false
    @ObservedObject var cloudVM: UserCloudVM
    @Binding var selectedTab: HomeTab

    var body: some View {
        NavigationView {
            ZStack {
                // خلفية الكاميرا
                CameraPreview(session: cameraVM.session)
                    .ignoresSafeArea()
                    .onAppear { cameraVM.checkCameraPermissionAndStart() }
                    .onDisappear { cameraVM.stopCamera() }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let screenSize = UIScreen.main.bounds.size
                                let focusPoint = CGPoint(
                                    x: value.location.x / screenSize.width,
                                    y: value.location.y / screenSize.height
                                )
                                cameraVM.focus(at: focusPoint)
                            }
                    )
                
                VStack {
                    HStack(spacing: 12) {

                        // 🔙 Back Button
                        Button {
                            selectedTab = .wheat
                        } label: {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        // 📝 Note Card
                        Text("Note: Focus on the ingredient list for accurate results")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(height: 56)
                            .padding(.horizontal, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.btn.opacity(0.28))
                                    .background(.ultraThinMaterial)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                    }
                    .padding(.horizontal, 16)

                        
                        Spacer()
                        FocusCornerBox()
                        
                        Spacer()
                        
                        // ✅ الشريط السفلي ممتد لآخر الشاشة
                        HStack {
                            // ✅ زر الألبوم (ثابت يمين دائمًا)
                            Button(action: { showImagePicker = true }) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 36)) // ✅ أكبر
                                    .foregroundStyle(.white)
                                    .padding(16) // ✅ بدون دائرة
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            
                            
                            
                            Spacer()
                            
                            // ✅ زر الكاميرا (المنتصف)
                            Button(action: { cameraVM.takePhoto() }) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.btn, lineWidth: 5)
                                        .frame(width: 76, height: 76)
                                    
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 67, height: 67)
                                }
                            }
                            
                            Spacer()
                            
                            // ✅ زر الفلاش (ثابت يسار دائمًا)
                            Button(action: {
                                isFlashOn.toggle()
                                cameraVM.toggleFlash(isOn: isFlashOn)
                            }) {
                                Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                    .font(.system(size: 34)) // ✅ أكبر
                                    .foregroundStyle(isFlashOn ? .white : .white)
                                    .padding(16) // ✅ بدون دائرة
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding(.horizontal, 44)
                        .padding(.vertical, 34)
                        .frame(maxWidth: .infinity)          // ✅ يمتد عرضيًا
                        
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .fill(Color.white.opacity(0.06))
                                )
                        )
                        //
                    }
                    .ignoresSafeArea(edges: .bottom) // ✅ تمتد لآخر الشاشة حتى مع الـ safe area
                    
                if let image = capturedImage {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    VStack {
                        Spacer()

                        ResultView(
                            vm: cloudVM,
                            selectedTab: $selectedTab,
                            capturedImage: $capturedImage,
                            image: image,
                            ingredients: cameraVM.glutenFound,
                        
                            status: cameraVM.status,
                        )
                        .frame(
                            height: cameraVM.glutenFound.isEmpty
                            ? UIScreen.main.bounds.height * 0.55
                            : UIScreen.main.bounds.height * 0.65
                        )
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(radius: 12)
                        .ignoresSafeArea(edges: .bottom)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: capturedImage)
                }
                    }
                    
                    
                }
            
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in
                    // صورة من الألبوم
                    capturedImage = image
                    cameraVM.capturedImage = image
                    cameraVM.recognizeText(from: image)
                }
            }
            .onChange(of: cameraVM.capturedImage) { img in
                // صورة من الكاميرا
                if let img {
                    capturedImage = img
                }
            }
            .navigationBarHidden(true)
        }
        
    }
    struct FocusCornerBox: View {
        var body: some View {
            ZStack {
                // الزاوية العلوية اليسرى
                corner
                    .rotationEffect(.degrees(0))
                    .offset(x: -90, y: -90)
                
                // الزاوية العلوية اليمنى
                corner
                    .rotationEffect(.degrees(90))
                    .offset(x: 90, y: -90)
                
                // الزاوية السفلية اليمنى
                corner
                    .rotationEffect(.degrees(180))
                    .offset(x: 90, y: 90)
                
                // الزاوية السفلية اليسرى
                corner
                    .rotationEffect(.degrees(270))
                    .offset(x: -90, y: 90)
            }
            .frame(width: 50, height: 50)   // ✅ حجم المربع
        }
        
        // ✅ شكل الزاوية الواحدة
        var corner: some View {
            Path { path in
                path.move(to: CGPoint(x: 20, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 20))
            }
            .stroke(Color.yellow, lineWidth: 4)
        }
    }



//// 👇 لازم يكون الـ Preview خارج struct CameraView
//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView(
//            selectedTab: .constant(.scan)
//        )
//    }
//}
import SwiftUI
import AVFoundation

struct CameraPreview1: UIViewRepresentable {
    
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill   // ✅ حل الآيباد
        previewLayer.connection?.videoOrientation = .portrait

        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
        previewLayer.frame = uiView.bounds   // ✅ مهم
    }
}
