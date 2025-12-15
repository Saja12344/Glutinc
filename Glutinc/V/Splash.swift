////
////  Splash.swift
////  Glutinc22
////
////  Created by dana on 17/06/1447 AH.
////
//import SwiftUI
//
//struct Splash: View {
//    @Environment(\.colorScheme) private var colorScheme
//    @State private var isActive: Bool = false
//    @EnvironmentObject var cloudVM: UserCloudVM
//
//    // اللوقو حسب المود
//    private var logoName: String {
//        colorScheme == .dark ? "glutinc2" : "glutinc"
//    }
//
//    var body: some View {
//        Group {
//            if isActive {
//                // بعد السبلـاش يفتح الهوم بيج
//                MainTabContainer()
//                    .environmentObject(cloudVM)
//            } else {
//                ZStack {
//            // الخلفية نفس HomeView تماماً
//
//                    if colorScheme == .dark {
//                        // دارك مود
//                        Color("BackgroundMain")
//                            .ignoresSafeArea()
//
//                        RadialGradient(
//                            gradient: Gradient(colors: [
//                                Color("GradientEnd"),                       // الأزرق
//                                Color("GradientStart").opacity(0.10),      // أبيض خفيييف
//                                .clear
//                            ]),
//                            center: .topTrailing,
//                            startRadius: 40,
//                            endRadius: 600
//                        )
//                        .opacity(0.9)
//                        .ignoresSafeArea()
//
//                    } else {
//                        // لايت مود
//                        RadialGradient(
//                            gradient: Gradient(colors: [
//                                Color("GradientEnd"),    // الأزرق من الزاوية
//                                Color("GradientMiddle")  // الأخضر يغطي الباقي
//                            ]),
//                            center: .topTrailing,
//                            startRadius: 40,
//                            endRadius: 600
//                        )
//                        .ignoresSafeArea()
//                    }
//
//                    // اللوقو في النص
//                    Image(logoName)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 180, height: 180)
//                        .shadow(color: .black.opacity(0.18),
//                                radius: 24, x: 0, y: 12)
//                }
//                .onAppear {
//                    // بعد 2 ثانية يروح للهوم
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        withAnimation(.easeOut) {
//                            isActive = true
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//// اختياري بس عشان اشوفه في الـ Preview
//#Preview {
//    Splash()
//        .preferredColorScheme(.light)
//}
import SwiftUI

struct Splash: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var cloudVM: UserCloudVM
    
    @State private var showLogo = false
    @State private var typedText = ""
    @State private var isActive = false
    @State private var revealWidth: CGFloat = 0
    
    
    var body: some View {
        Group {
            if isActive {
                MainTabContainer()
                    .environmentObject(cloudVM)
            } else {
                ZStack {
                    
                    // ✅ الخلفية المتفق عليها
                    Color(colorScheme == .dark ? .black : .white)
                        .ignoresSafeArea()
                    
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.48, blue: 0.95)
                                .opacity(colorScheme == .dark ? 0.35 : 0.55),
                            Color.clear
                        ],
                        startPoint: .topTrailing,
                        endPoint: .center
                    )
                    .ignoresSafeArea()
                    
                    // ✅ المحتوى
                    HStack(spacing: 12) {
                        
                        // 🔹 Logo Mark
                        HStack(spacing: 12) {
                            
                            // 🔹 Logo Mark
                            Image("logo-mark")
                                .resizable()
                                   .scaledToFit()
                                   .frame(width: 110, height: 110)
                            
                            // 🔹 Logo Wordmark (ينكشف كأنه كتابة)
                            Image("logo-wordmark")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 42)
                                .mask(
                                    Rectangle()
                                        .frame(width: revealWidth,
                                               alignment: .leading )
                                        .alignmentGuide(.leading) { _ in 0 }
                                )
                                .onAppear {
                                    // العرض الحقيقي للكلمة تقريبًا
                                    withAnimation(.linear(duration: 1.2)) {
                                        revealWidth = 260
                                    }
                                }
                        }
                        
                    }
                }
                .onAppear {
                    startAnimation()
                }
            }
        }
    }
    
    // MARK: - Animation flow
    private func startAnimation() {
        
        // 1️⃣ خلي اللوقو ثابت – ما نسوي له شي
        revealWidth = 0
        
        // 2️⃣ نبدأ "الكتابة" بعد توقف بسيط
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.linear(duration: 1.8)) {
                revealWidth = 260   // عدليها حسب عرض الاسم
            }
        }
        
        // 3️⃣ ننتظر شوي بعد ما يخلص → نروح للهوم
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeOut(duration: 0.4)) {
                isActive = true
            }
        }
    }}

