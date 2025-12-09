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

    // 1 = Posts, 2 = Saved
    @State private var selectedSegment: Int = 1

    var body: some View {
        ZStack {
            // Background
            if colorScheme == .dark {
                Color("BackgroundMain").ignoresSafeArea()
                RadialGradient(
                    gradient: Gradient(colors: [ Color("GradientEnd"), .clear ]),
                    center: .topTrailing,
                    startRadius: 40,
                    endRadius: 600
                )
                .opacity(0.9)
                .ignoresSafeArea()
            } else {
                RadialGradient(
                    gradient: Gradient(colors: [ Color("GradientEnd"), Color("GradientMiddle") ]),
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
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: 3))

                    Text(vm.user.name)
                        .foregroundStyle(.primary) // was .black
                        .font(.system(size: 22, weight: .semibold))
                }
                .padding(.top, 40)

                // Segmented (Posts / Saved)
                VStack(spacing: 12) {
                    HStack(spacing: 60) {

                        // Posts
                        Button {
                            withAnimation(.spring()) { selectedSegment = 1 }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "text.justify")
                                    .font(.system(size: 20))
                                    .foregroundStyle(selectedSegment == 1 ? .primary : .secondary)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.primary)
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
                                    .foregroundStyle(selectedSegment == 2 ? .primary : .secondary)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.primary)
                                    .frame(width: selectedSegment == 2 ? 40 : 0, height: 3)
                                    .animation(.easeInOut, value: selectedSegment)
                            }
                        }
                    }
                }

                // === Content under the segment ===
                Group {
                    if selectedSegment == 1 {
                        // User's posts from CloudKit
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(vm.posts) { post in
                                PostCard(post: post)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Saved/bookmarked posts from CloudKit
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(vm.saved) { post in
                                PostCard(post: post)
                            }
                        }
                        .padding(.horizontal)
                    }
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
                                    .foregroundStyle(selectedTab == 1 ? Color.teal : .primary) // was .black
                            }
                            .buttonStyle(.plain)

                            // SCAN
                            Button {
                                selectedTab = 2; goToScan = true
                            } label: {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 24, weight: .regular))
                                    .frame(width: itemWidth, height: barHeight)
                                    .foregroundStyle(selectedTab == 2 ? Color.teal : .primary)
                            }
                            .buttonStyle(.plain)

                            // PROFILE (current)
                            Button {
                                selectedTab = 3
                            } label: {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24, weight: .regular))
                                    .frame(width: itemWidth, height: barHeight)
                                    .foregroundStyle(selectedTab == 3 ? Color.teal : .primary)
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
                            .environment(\.layoutDirection, isAR ? .rightToLeft : .leftToRight)
                ) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.primary) // was .black
                }
            }
        }
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
        // Load from CloudKit when the view appears
        .task {
            await vm.loadAll()
        }
    }
}

// MARK: - Inline card for posts (no new file)
private struct PostCard: View {
    let post: CKPost
    var body: some View {
        VStack(spacing: 8) {
            if let img = post.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .frame(height: 150)
                    .overlay(Image(systemName: "photo"))
            }
            Text(post.title.isEmpty ? "—" : post.title)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
    }
}

#Preview("Profile – EN") {
    let vm = UserVM()
    return NavigationStack {
        ProfileView(vm: vm)
    }
}

#Preview("الملف الشخصي – AR • RTL") {
    let vm = UserVM()
    vm.user.name = "جاسمين"
    return NavigationStack {
        ProfileView(vm: vm)
            .environment(\.layoutDirection, .rightToLeft)
    }
    .preferredColorScheme(.light)
}
