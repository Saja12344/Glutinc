//
//  Untitled.swift
//  Glutinc22
//
//  Created by dana on 16/06/1447 AH.
//
import SwiftUI

// تابّات التاب بار
enum HomeTab {
    case wheat
    case scan
    case profile
}

struct HomeView: View {
    @State private var searchText: String = ""
    @State private var selectedTab: HomeTab = .scan
    @Environment(\.colorScheme) private var colorScheme   // نعرف هل لايت ولا دارك

    var body: some View {
        ZStack(alignment: .bottom) {

            // - الخلفية (لايت + دارك)

            if colorScheme == .dark {
                // دارك مود: خلفية غامقة + Radial خفيف فوقها
                Color("BackgroundMain")
                    .ignoresSafeArea()

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color("GradientEnd"),    // الأزرق
                        Color("GradientStart"),  // الأبيض الخفيف
                        .clear
                    ]),
                    center: .topTrailing,
                    startRadius: 40,
                    endRadius: 600
                )
                .opacity(0.9)
                .ignoresSafeArea()
            } else {
                // لايت مود: نفس الـ Radial

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color("GradientEnd"),    // الأزرق 2274A5 – من الزاوية
                        Color("GradientStart"),  // الأبيض FCFCFC – بالنص
                        Color("GradientMiddle")  // الأخضر CEEDE7 – يغطي تحت
                    ]),
                    center: .topTrailing,
                    startRadius: 40,
                    endRadius: 600
                )
                .ignoresSafeArea()
            }

            // - المحتوى

            VStack {
                Spacer().frame(height: 60)  // مسافة من فوق

                //  السيرتش (نفسه في اللايت والدارك)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray.opacity(0.7))

                    TextField("Search", text: $searchText)
                        .textFieldStyle(.plain)

                    Button {

                    } label: {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                )
                .padding(.horizontal, 24)

                Spacer()                    // مكان الكروت (فاضي الآن)
                Spacer().frame(height: 80)  // مساحة للتاب بار
            }

            // التاب بار القلاسي
            GlassTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
        }
    }
}

//- Glass Tab Bar

struct GlassTabBar: View {
    @Binding var selectedTab: HomeTab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.wheat, imageName: "wheat")
            tabButton(.scan, imageName: "scan")
            tabButton(.profile, imageName: "profile")
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)          // قلاسي
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
        .frame(width: 260, height: 72)            // ما يغطي الشاشة كلها
    }

    private func tabButton(_ tab: HomeTab, imageName: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            ZStack {
                // المربع الصغير تحت التاب المختار
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.10),
                                radius: 12, x: 0, y: 4)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 4)
                }

                Image(imageName)
                    .resizable()
                    .renderingMode(.template)     // عشان يتلوّن
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(
                        selectedTab == tab
                        ? Color("PrimaryBlue")     // أزرق على المختار
                        : Color.primary.opacity(0.4)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        //.preferredColorScheme(.dark)
}
