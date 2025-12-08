//
//  ProfileView.swift
//  Glutinc
//
//  Created by Deemah Alhazmi on 01/12/2025.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: UserVM
    @State private var goToShop = false
    @State private var goToScan = false
    @State private var selectedTab: Int = 3   // 1 = shop, 2 = scan, 3 = profile
    @Environment(\.colorScheme) private var colorScheme
    private var isAR: Bool {
        Locale.preferredLanguages.first?.hasPrefix("ar") == true
    }

    // NEW: segment selection (1 = Posts, 2 = Saved)
    @State private var selectedSegment: Int = 1

    var body: some View {
        ZStack {
           // AppGradient.background.ignoresSafeArea()
            if colorScheme == .dark {
                // دارك مود: خلفية غامقة + Radial خفيف فوقها
                Color("BackgroundMain")
                    .ignoresSafeArea()

                RadialGradient(
                    gradient: Gradient(colors: [
                        Color("GradientEnd"),    // الأزرق
                       // Color("GradientStart"),  // الأبيض الخفيف
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
                       // Color("GradientStart"),  // الأبيض FCFCFC – بالنص
                        Color("GradientMiddle")  // الأخضر CEEDE7 – يغطي تحت
                    ]),
                    center: .topTrailing,
                    startRadius: 40,
                    endRadius: 600
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 20) {

                // Photo + name
                VStack(spacing: 6) {
                    ZStack {
                        if let img = vm.user.photo {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            Image("userPhoto").resizable().scaledToFill()
                        }
                    }
                    .frame(width: 110, height: 110).clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: 3))

                    Text(vm.user.name).foregroundStyle(Color.black)
                        .font(.system(size: 22, weight: .semibold))
                }
                .padding(.top, 40)

                // === Segmented switch (Posts / Saved) ===
                VStack(spacing: 12) {
                    HStack(spacing: 60) {
                        // Posts
                        Button {
                            withAnimation(.spring()) { selectedSegment = 1 }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "text.justify")
                                    .font(.system(size: 20))
                                    .foregroundStyle(selectedSegment == 1 ? Color.black : .white.opacity(0.7))
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.black)
                                    .frame(width: selectedSegment == 1 ? 40 : 0, height: 3)
                                    .animation(.easeInOut, value: selectedSegment)
                            }
                        }

                        // Saved
                        Button {
                            withAnimation(.spring()) { selectedSegment = 2 }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(selectedSegment == 2 ? Color.black : .white.opacity(0.7))
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.black)
                                    .frame(width: selectedSegment == 2 ? 40 : 0, height: 3)
                                    .animation(.easeInOut, value: selectedSegment)
                            }
                        }
                    }
                }

                // === Content under the segment ===
                if selectedSegment == 1 {
                    // Posts (for now use savedImages so it builds;
                    // when you add vm.user.posts, just replace the array below)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(vm.user.savedImages, id: \.self) { ProductCard(imageName: $0) }
                    }
                    .padding(.horizontal)
                } else {
                    // Saved items
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(vm.user.savedImages, id: \.self) { ProductCard(imageName: $0) }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 0)

                // Tiny bottom bar
                let barHeight: CGFloat = 64
                let pillInset: CGFloat = 6

                GeometryReader { geo in
                    let itemWidth = (geo.size.width - 32) / 3  // 16px side padding
                    let pillWidth = itemWidth - pillInset * 2

                    ZStack(alignment: .leading) {
                        // Glass capsule background
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

                        // Sliding selected pill
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
                            )
                            .frame(width: pillWidth, height: barHeight - pillInset * 2)
                            .offset(x: {
                                switch selectedTab {
                                case 1: return 16 + pillInset + 0 * itemWidth
                                case 2: return 16 + pillInset + 1 * itemWidth
                                default: return 16 + pillInset + 2 * itemWidth
                                }
                            }())
                            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)

                        // Tap targets + icons
                        HStack(spacing: 0) {
                            // SHOP
                            Button {
                                selectedTab = 1; goToShop = true
                            } label: {
                                Image(systemName: "basket")
                                    .font(.system(size: 24, weight: .regular))
                                    .frame(width: itemWidth, height: barHeight)
                                    .foregroundStyle(selectedTab == 1 ? Color.teal : Color.black)
                            }
                            .buttonStyle(.plain)

                            // SCAN
                            Button {
                                selectedTab = 2; goToScan = true
                            } label: {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 24, weight: .regular))
                                    .frame(width: itemWidth, height: barHeight)
                                    .foregroundStyle(selectedTab == 2 ? Color.teal : Color.black)
                            }
                            .buttonStyle(.plain)

                            // PROFILE (current)
                            Button {
                                selectedTab = 3
                            } label: {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24, weight: .regular))
                                    .frame(width: itemWidth, height: barHeight)
                                    .foregroundStyle(selectedTab == 3 ? Color.teal : Color.black)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(height: barHeight)
                }
                .frame(height: 64)                // keep layout stable
                .padding(.horizontal, 90)
                .padding(.bottom, 30)

            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination:
                        SettingsView(vm: vm)
                            .environment(\.layoutDirection, isAR ? .rightToLeft : .leftToRight) // ← NEW
                ) {
                    Image(systemName: "gearshape").foregroundStyle(.black)//.glassEffect()
                }
            }
        }

        // Arabic mirrors automatically; force if you preview Arabic only:
        //.environment(\.layoutDirection, .rightToLeft)
        
        .background(
            Group {
                NavigationLink("", isActive: $goToShop) {
                    Text("Shop Page (Coming Soon)")
                        .navigationTitle("Shop")
                }.hidden()

                NavigationLink("", isActive: $goToScan) {
                    CameraView()
                            .navigationBarHidden(true) 
                }.hidden()
            }
        )

    }

}

#Preview("Profile – EN") {
    let vm = UserVM()
    // Optional demo data:
    // vm.user.savedImages = ["prod1","prod2"]  // make sure these exist in Assets
    // vm.user.name = "Jasmin"
   
    return NavigationStack {                 // show the toolbar gear in preview
        ProfileView(vm: vm)
    }
    //.preferredColorScheme(.dark)
}

#Preview("الملف الشخصي – AR • RTL") {
    let vm = UserVM()
    vm.user.name = "جاسمين"
    
    return NavigationStack {
        ProfileView(vm: vm)
            .environment(\.layoutDirection, .rightToLeft) // force RTL in preview
    }
    .preferredColorScheme(.light)
}

