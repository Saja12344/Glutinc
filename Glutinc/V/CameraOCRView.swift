
import SwiftUI

struct CameraView: View {
    
    @StateObject private var cameraVM = CameraOCRViewModel()
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @Environment(\.layoutDirection) var layoutDirection
    @State private var isFlashOn = false
    @Binding var selectedTab: HomeTab
    @StateObject var cloudVM = UserCloudVM()

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
                Button {
                    selectedTab = .wheat   // ✅ رجوع مباشر للهوم
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                Spacer()
                    
                    Spacer()
                    VStack {
                        // رسالة التنبيه
                        Text("Note : Focus on the ingredient list for accurate results")
                            .frame(width: 250, height: 60)
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(8)
                            .background(
                                ZStack {
                                    Color.btn.opacity(0.3)
                                        .blur(radius: 1)
                                        .background(.ultraThinMaterial)
                                }
                            )
                            .cornerRadius(16)
                        
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
                            ZStack {
                                // ✅ بلير حقيقي
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                
                                // ✅ طبقة سوداء فوق البلير
                                Color.black.opacity(0.45)
                            }
                        )
                        //
                    }
                    .ignoresSafeArea(edges: .bottom) // ✅ تمتد لآخر الشاشة حتى مع الـ safe area
                    
                    if let image = capturedImage {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()
                        
                        VStack {
                            Spacer()   // ✅ هذا يضمن أن البداية من أسفل الشاشة
                            
                            ResultView(
                                vm: cloudVM,                 // ✅ الصحيح
                                image: image,
                                ingredients: cameraVM.glutenFound,  // ✅ من الكاميرا
                                status: cameraVM.status,            // ✅ من الكاميرا
                               
                                
                                
                            )


                            .frame(
                                height: cameraVM.glutenFound.isEmpty
                                ? UIScreen.main.bounds.height * 0.45
                                : UIScreen.main.bounds.height * 0.55
                            )
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                            .shadow(radius: 12)
                            .ignoresSafeArea(edges: .bottom)
                        }
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
}


// 👇 لازم يكون الـ Preview خارج struct CameraView
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(
            selectedTab: .constant(.scan)
        )
    }
}
