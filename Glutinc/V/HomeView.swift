//
//  HomeView.swift
//  Glutinc22
//
//  Created by dana on 16/06/1447 AH.
//

import SwiftUI
import CloudKit

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

    // ✅ فيد المجتمع (iCloud Public DB)
    @StateObject private var feedVM = FeedVM()
    @State private var goToScan = false
    @State private var goToProfile = false

    // ✅ صار CKPost بدل Post
    var filteredPosts: [CKPost] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return feedVM.posts }
        return feedVM.posts.filter { post in
            // عدل الحقول حسب Model لو احتجت
            post.content.localizedCaseInsensitiveContains(q) ||
            post.title.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        NavigationStack {
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
                            // ممكن تضيف فويس سيرش لاحقًا
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

                    // ===== مكان الكروت (تم تفعيله بالفيد الحقيقي) =====
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(Array(filteredPosts.enumerated()), id: \.element.id) { index, post in
                                PostRow(post: post)
                                    .onAppear {
                                        // تحميل المزيد عند الاقتراب من آخر عنصر
                                        if index >= filteredPosts.count - 3 {
                                            Task { await feedVM.loadMore() }
                                        }
                                    }
                            }

                            // زر تحميل المزيد إذا رغبت يدويًا
                            if !filteredPosts.isEmpty {
                                Button(action: { Task { await feedVM.loadMore() } }) {
                                    Text("Load more")
                                        .font(.footnote)
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                .padding(.top, 6)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .refreshable {
                        await feedVM.load()
                    }

                    Spacer().frame(height: 80)  // مساحة للتاب بار
                }

                // التاب بار القلاسي
                GlassTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                    .onChange(of: selectedTab) { _, newValue in
                        // تنقل بسيط حسب التاب
                        switch newValue {
                        case .scan:    goToScan = true
                        case .profile: goToProfile = true
                        case .wheat:   break // صفحة المجتمع الحالية
                        }
                    }

                // روابط تنقل مخفية
                NavigationLink("", isActive: $goToScan) {
                    CameraView().navigationBarHidden(true)
                }.hidden()

                NavigationLink("", isActive: $goToProfile) {
                    // استبدله بصفحتك الحقيقية
                    Text("Profile").navigationTitle("Profile")
                }.hidden()
            }
            .navigationBarHidden(true)
            .task {
                // تحميل أولي للفيد
                await feedVM.load()
            }
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

// ===== واجهة عنصر الفيد =====
// ✅ تستخدم CKPost الآن (image + content/title)

private struct PostRow: View {
    let post: CKPost

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let img = post.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(16)
            }

            Text(post.content.isEmpty ? post.title : post.content)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
    //.preferredColorScheme(.dark)
}
