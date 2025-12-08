//
//  tabbar.swift
//  Glutinc
//
//  Created by saja khalid on 17/06/1447 AH.
//

import SwiftUI
// ✅ تابّات التاب بار
enum HomeTab {
    case wheat
    case scan
    case profile
}
struct MainTabContainer: View {

    @State private var selectedTab: HomeTab = .wheat
    @StateObject var userVM = UserCloudVM()

    var body: some View {
        ZStack(alignment: .bottom) {

            // ✅ المحتوى حسب التاب
            Group {
                switch selectedTab {

                case .wheat:
                    HomeView()

                case .scan:
                    CameraView(selectedTab: $selectedTab)   // ✅ مع زر رجوع

                case .profile:
                    ProfileView(vm: userVM)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ✅ إخفاء التاب بار داخل الكاميرا
            if selectedTab != .scan {
                GlassTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}
// ✅ التاب بار القلاسي
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
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
        .frame(width: 260, height: 72)
    }

    private func tabButton(_ tab: HomeTab, imageName: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            ZStack {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color.white.opacity(0.95))
                        .shadow(radius: 8)
                        .padding(4)
                }

                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(
                        selectedTab == tab
                        ? Color("PrimaryBlue")
                        : Color.primary.opacity(0.4)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }
}
