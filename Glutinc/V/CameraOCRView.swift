
import SwiftUI

struct CameraView: View {
    
    @StateObject private var vm = CameraOCRViewModel()
    @State private var showImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var showResults = false
    @Environment(\.layoutDirection) var layoutDirection
    
    
    var body: some View {
        NavigationView {
            ZStack {
                // عرض الكاميرا
                CameraPreview(session: vm.session)
                    .ignoresSafeArea()
                    .onAppear { vm.checkCameraPermissionAndStart() }
                    .onDisappear { vm.stopCamera() }

                
                VStack {
                    Text("Note : Focus on the ingredient list for accurate results")
                        .frame(width: 300, height: 60)
                        .font(.system(size: 15, weight: .regular, design: .default)) // خط كلاسيكي
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center) // لتوسيط النص
                        .padding(8)
                        .background(
                               ZStack {
                                   Color.blue.opacity(0.3) // لون أزرق شفاف
                                   .blur(radius: 1)        // يعطي تأثير الزجاج
                                   .background(.ultraThinMaterial) // المظهر الزجاجي
                               }
                           )
                        .cornerRadius(16)

                    Spacer()
                    
                    ZStack {
                        // زر الكاميرا في الوسط
                        Button(action: { vm.takePhoto() }) {
                            ZStack {
                                // الحد الخارجي
                                Circle()
                                    .stroke(Color.white, lineWidth: 5)
                                    .frame(width: 80, height: 80) // أكبر شوي من الداخلية عشان تظهر المسافة

                                // الدائرة الداخلية
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 70, height: 70) // حجم أصغر من الحد الخارجي
                            }
                        }
                        .padding(.bottom, 16) // مسافة من أسفل الشاشة

                        HStack {
                            if layoutDirection == .rightToLeft {
                                Spacer() // يدفع زر الصورة إلى أقصى اليسار
                            }

                            // زر اختيار صورة من الألبوم
                            Button(action: { showImagePicker = true }) {
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .clipShape(Circle())
                            }
                            .frame(width: 60, height: 60)
                            .padding(.bottom, 16)

                            if layoutDirection != .rightToLeft {
                                Spacer() // يدفع زر الصورة إلى أقصى اليمين
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(16)
                    .background(.gray.opacity(0.6))

                }


                
                
                
                
                
                
                
                // NavigationLink خفي للانتقال للصفحة الثانية
                NavigationLink(
                    destination: ResultView(
                        image: capturedImage ?? UIImage(),
                        ingredients: vm.glutenFound
                    ),
                    isActive: $showResults
                ) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in
                    capturedImage = image
                    vm.capturedImage = image
                    vm.recognizeText(from: image)
                    showResults = true
                }
            }
            .onChange(of: vm.capturedImage) { img in
                if img != nil {
                    capturedImage = img
                    showResults = true
                }
            }
            .navigationBarHidden(true) // لإخفاء شريط التنقل
        }
    }
    struct CameraView_Previews: PreviewProvider {
        static var previews: some View {
            CameraView()
        }
    }
}
