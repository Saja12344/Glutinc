//
//  Splash.swift
//  Glutinc22
//
//  Created by dana on 17/06/1447 AH.
//
import SwiftUI

struct Splash: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isActive: Bool = false

    // اللوقو حسب المود
    private var logoName: String {
        colorScheme == .dark ? "glutinc2" : "glutinc"
    }

    var body: some View {
        Group {
            if isActive {
                // بعد السبلـاش يفتح الهوم بيج
                MainTabContainer()
            } else {
                ZStack {
            // الخلفية نفس HomeView تماماً

                    if colorScheme == .dark {
                        // دارك مود
                        Color("BackgroundMain")
                            .ignoresSafeArea()

                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color("GradientEnd"),                       // الأزرق
                                Color("GradientStart").opacity(0.10),      // أبيض خفيييف
                                .clear
                            ]),
                            center: .topTrailing,
                            startRadius: 40,
                            endRadius: 600
                        )
                        .opacity(0.9)
                        .ignoresSafeArea()

                    } else {
                        // لايت مود
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color("GradientEnd"),    // الأزرق من الزاوية
                                Color("GradientMiddle")  // الأخضر يغطي الباقي
                            ]),
                            center: .topTrailing,
                            startRadius: 40,
                            endRadius: 600
                        )
                        .ignoresSafeArea()
                    }

                    // اللوقو في النص
                    Image(logoName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .shadow(color: .black.opacity(0.18),
                                radius: 24, x: 0, y: 12)
                }
                .onAppear {
                    // بعد 2 ثانية يروح للهوم
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

// اختياري بس عشان اشوفه في الـ Preview
#Preview {
    Splash()
        .preferredColorScheme(.light)
}
