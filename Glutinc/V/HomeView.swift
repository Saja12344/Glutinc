////
//<<<<<<< HEAD
////import SwiftUI
//=======
////  HomeView.swift
////  Glutinc22
//>>>>>>> main
////
////// ✅ مودل المنتج
////struct Product: Identifiable {
////    let id = UUID()
////    let imageName: String
////    let name: String
////    let username: String
////    let rating: Double
////    let isGlutenFree: Bool
////}
////
//<<<<<<< HEAD
////// ✅ تابّات التاب بار
////enum HomeTab {
////    case wheat
////    case scan
////    case profile
////}
////
////struct HomeView: View {
////    
////    @State private var searchText: String = ""
////    @State private var selectedTab: HomeTab = .scan
////    @Environment(\.colorScheme) private var colorScheme
////    @State private var selectedFilter: String = "All"
////    
////    let filters: [String] = [
////        "All",
////        "Grains & Flours",
////        "Dairy",
////        "Drinks",
////        "Meat & Alternatives",
////        "Others"
////    ]
////    // ✅ بيانات تجريبية
////    let products: [Product] = [
////        Product(imageName: "sampleProduct2", name: "Chocolate Cookie", username: "sweet.bakes", rating: 3.9, isGlutenFree: false),
////        Product(imageName: "sampleProduct2", name: "Vanilla Cake", username: "bake.house", rating: 4.5, isGlutenFree: true),
////        Product(imageName: "sampleProduct2", name: "Brownie", username: "choco.bar", rating: 4.1, isGlutenFree: false),
////        Product(imageName: "sampleProduct2", name: "Donut", username: "sweet.life", rating: 4.0, isGlutenFree: true)
////    ]
////    
////    var body: some View {
////        NavigationStack {
////            ZStack(alignment: .bottom) {
////                
////                // ✅ التنقّل الحقيقي بين الصفحات
////                Group {
////                    switch selectedTab {
////                    case .wheat:
////                        HomeView()          // عدّلي الاسم لو صفحتك اسمها غير هذا
////                        
////                    case .scan:
////                        CameraView()
////
////                    case .profile:
////                        SettingsView(vm: UserVM())   // ✅ صفحة الإعدادات الحقيقية
////                    }
////                }
////                .frame(maxWidth: .infinity, maxHeight: .infinity)
////                
////                // ✅ التاب بار
////                GlassTabBar(selectedTab: $selectedTab)
////                    .padding(.horizontal, 40)
////                    .padding(.bottom, 24)
////            }
////            ZStack(alignment: .bottom) {
////                
////                // ✅ الخلفية (لايت + دارك)
////                if colorScheme == .dark {
////                    
////                    Color("BackgroundMain")
////                        .ignoresSafeArea()
////                    
////                    RadialGradient(
////                        gradient: Gradient(colors: [
////                            Color("GradientEnd"),
////                            Color("GradientStart"),
////                            .clear
////                        ]),
////                        center: .topTrailing,
////                        startRadius: 40,
////                        endRadius: 600
////                    )
////                    .opacity(0.9)
////                    .ignoresSafeArea()
////                    
////                } else {
////                    
////                    RadialGradient(
////                        gradient: Gradient(colors: [
////                            Color("GradientEnd"),
////                            Color("GradientStart"),
////                            Color("GradientMiddle")
////                        ]),
////                        center: .topTrailing,
////                        startRadius: 40,
////                        endRadius: 600
////                    )
////                    .ignoresSafeArea()
////                }
////                
////                // ✅ الشبكة الصحيحة
////                //
////                let columns = [
////                    GridItem(.flexible())
////                ]
////                
////                
////                
////                
////                
////                
////                // ✅ السيرش بار فوق
////                VStack(spacing: 12) {
////                    Spacer().frame(height: 60)
////                    
////                    // ✅ السيرش بار
////                    HStack {
////                        Image(systemName: "magnifyingglass")
////                            .foregroundColor(.gray.opacity(0.7))
////                        
////                        TextField("Search", text: $searchText)
////                        
////                        Button { } label: {
////                            Image(systemName: "mic.fill")
////                                .foregroundColor(.gray.opacity(0.7))
////                        }
////                    }
////                    .padding(.horizontal, 14)
////                    .padding(.vertical, 10)
////                    .background(
////                        RoundedRectangle(cornerRadius: 18)
////                            .fill(Color.white.opacity(0.9))
////                    )
////                    .padding(.horizontal, 24)
////                    
////                    // ✅ ✅ ✅ الفلاتر تحت السيرش
////                    ScrollView(.horizontal, showsIndicators: false) {
////                        HStack(spacing: 10) {
////                            ForEach(filters, id: \.self) { filter in
////                                Button {
////                                    selectedFilter = filter
////                                } label: {
////                                    Text(filter)
////                                        .font(.subheadline)
////                                        .padding(.horizontal, 14)
////                                        .padding(.vertical, 8)
////                                        .background(
////                                            Capsule()
////                                                .fill(
////                                                    selectedFilter == filter
////                                                    ? Color("PrimaryBlue").opacity(0.15)
////                                                    : Color.gray.opacity(0.15)
////                                                )
////                                        )
////                                        .foregroundColor(
////                                            selectedFilter == filter
////                                            ? Color("PrimaryBlue")
////                                            : .primary
////                                        )
////                                }
////                            }
////                        }
////                        .padding(.horizontal, 24)
////                        .padding(.bottom,0)
////                        
////                    }
////                    
////                    ScrollView {
////                        LazyVGrid(columns: columns, spacing: 20) {
////                            
////                            ForEach(products) { product in
////                                ProductCardView(
////                                    image: Image(product.imageName),
////                                    productName: product.name,
////                                    username: product.username,
////                                    rating: product.rating,
////                                    isGlutenFree: product.isGlutenFree,
////                                    onBookmarkTap: {
////                                        print("Bookmark tapped")
////                                    }
////                                )
////                            }
////                        }
////                        .padding(.horizontal)
////                        .padding(.top, 140)
////                        .padding(.bottom, 120)
////                    }
////                }
////                
////                // ✅ التاب بار القلاسي
////                GlassTabBar(selectedTab: $selectedTab)
////                    .padding(.horizontal, 40)
////                    .padding(.bottom, 4)
////            }
////        }
////    }
////    
////    // ✅ Glass Tab Bar
////    
////    struct GlassTabBar: View {
////        
////        @Binding var selectedTab: HomeTab
////        
////        var body: some View {
////            HStack(spacing: 0) {
////                tabButton(.wheat, imageName: "wheat")
////                tabButton(.scan, imageName: "scan")
////                tabButton(.profile, imageName: "profile")
////            }
////            .padding(6)
////            .background(
////                RoundedRectangle(cornerRadius: 30)
////                    .fill(.ultraThinMaterial)
////            )
////            .overlay(
////                RoundedRectangle(cornerRadius: 30)
////                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
////            )
////            .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
////            .frame(width: 260, height: 72)
////        }
////        
////        private func tabButton(_ tab: HomeTab, imageName: String) -> some View {
////            Button {
////                selectedTab = tab
////            } label: {
////                ZStack {
////                    
////                    if selectedTab == tab {
////                        RoundedRectangle(cornerRadius: 26)
////                            .fill(Color.white.opacity(0.95))
////                            .shadow(color: .black.opacity(0.10),
////                                    radius: 12, x: 0, y: 4)
////                            .padding(4)
////                    }
////                    
////                    Image(imageName)
////                        .resizable()
////                        .renderingMode(.template)
////                        .scaledToFit()
////                        .frame(width: 26, height: 26)
////                        .foregroundColor(
////                            selectedTab == tab
////                            ? Color("PrimaryBlue")
////                            : Color.primary.opacity(0.4)
////                        )
////                }
////                .frame(maxWidth: .infinity, maxHeight: .infinity)
////            }
////            .buttonStyle(.plain)
////        }
////    }
////}
////// ✅ المعاينة
////#Preview {
////    HomeView()
////        //.preferredColorScheme(.dark)
////        .preferredColorScheme(.light)
////}
//=======
//
//>>>>>>> main
//import SwiftUI
//import CloudKit
//
//// ✅ مودل المنتج
//struct Product: Identifiable {
//    let id = UUID()
//    let imageName: String
//    let name: String
//    let username: String
//    let rating: Double
//    let isGlutenFree: Bool
//}
//
//
//
//struct HomeView: View {
//    @State private var selectedTab: HomeTab = .wheat
//    @State private var searchText: String = ""
//    @Environment(\.colorScheme) private var colorScheme
//    @State private var selectedFilter: String = "All"
//    @State private var username: String? = nil
//
//<<<<<<< HEAD
//    
//    let filters: [String] = [
//        "All",
//        "Grains & Flours",
//        "Dairy",
//        "Drinks",
//        "Meat & Alternatives",
//        "Others"
//    ]
//    
//    // ✅ بيانات تجريبية
//    let products: [Product] = [
//        Product(imageName: "sampleProduct2", name: "Chocolate Cookie", username: "sweet.bakes", rating: 3.9, isGlutenFree: false),
//        Product(imageName: "sampleProduct2", name: "Vanilla Cake", username: "bake.house", rating: 4.5, isGlutenFree: true),
//        Product(imageName: "sampleProduct2", name: "Brownie", username: "choco.bar", rating: 4.1, isGlutenFree: false),
//        Product(imageName: "sampleProduct2", name: "Donut", username: "sweet.life", rating: 4.0, isGlutenFree: true)
//    ]
//    
//    var body: some View {
//        NavigationStack {
//            ZStack(alignment: .bottom) {
//                
//                // ✅ الخلفية
//                if colorScheme == .dark {
//                    Color("BackgroundMain")
//                        .ignoresSafeArea()
//                } else {
//                    RadialGradient(
//                        gradient: Gradient(colors: [
//                            Color("GradientEnd"),
//                            Color("GradientStart"),
//                            Color("GradientMiddle")
//=======
//    // ✅ فيد المجتمع (iCloud Public DB)
//    @StateObject private var feedVM = FeedVM()
//    @State private var goToScan = false
//    @State private var goToProfile = false
//
//    // ✅ صار CKPost بدل Post
//    var filteredPosts: [CKPost] {
//        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !q.isEmpty else { return feedVM.posts }
//        return feedVM.posts.filter { post in
//            // عدل الحقول حسب Model لو احتجت
//            post.content.localizedCaseInsensitiveContains(q) ||
//            post.title.localizedCaseInsensitiveContains(q)
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack(alignment: .bottom) {
//
//                // - الخلفية (لايت + دارك)
//                if colorScheme == .dark {
//                    // دارك مود: خلفية غامقة + Radial خفيف فوقها
//                    Color("BackgroundMain")
//                        .ignoresSafeArea()
//
//                    RadialGradient(
//                        gradient: Gradient(colors: [
//                            Color("GradientEnd"),    // الأزرق
//                            Color("GradientStart"),  // الأبيض الخفيف
//                            .clear
//>>>>>>> main
//                        ]),
//                        center: .topTrailing,
//                        startRadius: 40,
//                        endRadius: 600
//                    )
//<<<<<<< HEAD
//                    .ignoresSafeArea()
//                }
//                
//                
//                homeContent
//                
//            }
//        }
//    }
//    private var homeContent: some View {
//        let columns = [GridItem(.flexible())]
//
//        return VStack(alignment: .leading, spacing: 16) {
//
//            // ✅ ✅ ✅ الترحيب
//            VStack(alignment: .leading, spacing: 2) {
//
//                // ✅ Hi (صغير)
//                Text("Hi")
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(Color("PrimaryBlue").opacity(0.7))
//
//                // ✅ Guest أو اسم المستخدم (كبير)
//                Text(username == nil ? "Guest 👋" : "\(username!) 👋")
//                    .font(.system(size: 28, weight: .bold))
//                    .foregroundColor(Color("PrimaryBlue"))
//
//            }
//            .padding(.horizontal)
//            .padding(.top, 10)
//
//=======
//                    .opacity(0.9)
//                    .ignoresSafeArea()
//                } else {
//                    // لايت مود: نفس الـ Radial
//                    RadialGradient(
//                        gradient: Gradient(colors: [
//                            Color("GradientEnd"),    // الأزرق 2274A5 – من الزاوية
//                            Color("GradientStart"),  // الأبيض FCFCFC – بالنص
//                            Color("GradientMiddle")  // الأخضر CEEDE7 – يغطي تحت
//                        ]),
//                        center: .topTrailing,
//                        startRadius: 40,
//                        endRadius: 600
//                    )
//                    .ignoresSafeArea()
//                }
//
//                // - المحتوى
//                VStack {
//                    Spacer().frame(height: 60)  // مسافة من فوق
//
//                    //  السيرتش (نفسه في اللايت والدارك)
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray.opacity(0.7))
//
//                        TextField("Search", text: $searchText)
//                            .textFieldStyle(.plain)
//
//                        Button {
//                            // ممكن تضيف فويس سيرش لاحقًا
//                        } label: {
//                            Image(systemName: "mic.fill")
//                                .foregroundColor(.gray.opacity(0.7))
//                        }
//                    }
//                    .padding(.horizontal, 14)
//                    .padding(.vertical, 10)
//                    .background(
//                        RoundedRectangle(cornerRadius: 18, style: .continuous)
//                            .fill(Color.white.opacity(0.9))
//                    )
//                    .padding(.horizontal, 24)
//
//                    // ===== مكان الكروت (تم تفعيله بالفيد الحقيقي) =====
//                    ScrollView {
//                        LazyVStack(spacing: 14) {
//                            ForEach(Array(filteredPosts.enumerated()), id: \.element.id) { index, post in
//                                PostRow(post: post)
//                                    .onAppear {
//                                        // تحميل المزيد عند الاقتراب من آخر عنصر
//                                        if index >= filteredPosts.count - 3 {
//                                            Task { await feedVM.loadMore() }
//                                        }
//                                    }
//                            }
//
//                            // زر تحميل المزيد إذا رغبت يدويًا
//                            if !filteredPosts.isEmpty {
//                                Button(action: { Task { await feedVM.loadMore() } }) {
//                                    Text("Load more")
//                                        .font(.footnote)
//                                        .foregroundStyle(.primary)
//                                        .padding(.horizontal, 14).padding(.vertical, 8)
//                                        .background(.ultraThinMaterial, in: Capsule())
//                                }
//                                .padding(.top, 6)
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    }
//                    .refreshable {
//                        await feedVM.load()
//                    }
//
//                    Spacer().frame(height: 80)  // مساحة للتاب بار
//                }
//
//                // التاب بار القلاسي
//                GlassTabBar(selectedTab: $selectedTab)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 24)
//                    .onChange(of: selectedTab) { _, newValue in
//                        // تنقل بسيط حسب التاب
//                        switch newValue {
//                        case .scan:    goToScan = true
//                        case .profile: goToProfile = true
//                        case .wheat:   break // صفحة المجتمع الحالية
//                        }
//                    }
//
//                // روابط تنقل مخفية
//                NavigationLink("", isActive: $goToScan) {
//                    CameraView().navigationBarHidden(true)
//                }.hidden()
//
//                NavigationLink("", isActive: $goToProfile) {
//                    // استبدله بصفحتك الحقيقية
//                    Text("Profile").navigationTitle("Profile")
//                }.hidden()
//            }
//            .navigationBarHidden(true)
//            .task {
//                // تحميل أولي للفيد
//                await feedVM.load()
//            }
//        }
//    }
//}
//
////- Glass Tab Bar
//
//struct GlassTabBar: View {
//    @Binding var selectedTab: HomeTab
//>>>>>>> main
//
//            // ✅ السيرش الديفولت
//            Color.clear
//                .frame(height: 0)
//                .searchable(text: $searchText, prompt: "Search")
//
//            // ✅ الفلاتر
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 10) {
//                    ForEach(filters, id: \.self) { filter in
//                        Button {
//                            selectedFilter = filter
//                        } label: {
//                            Text(filter)
//                                .font(.subheadline)
//                                .padding(.horizontal, 14)
//                                .padding(.vertical, 8)
//                                .background(
//                                    Capsule().fill(
//                                        selectedFilter == filter
//                                        ? Color("PrimaryBlue").opacity(0.2)
//                                        : Color.gray.opacity(0.2)
//                                    )
//                                )
//                                .foregroundColor(.primary)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
//
//            // ✅ الكروت
//            ScrollView {
//                LazyVGrid(columns: columns, spacing: 20) {
//                    ForEach(products) { product in
//                        ProductCardView(
//                            image: Image(product.imageName),
//                            productName: product.name,
//                            username: product.username,
//                            rating: product.rating,
//                            isGlutenFree: product.isGlutenFree,
//                            onBookmarkTap: {}
//                        )
//                    }
//                }
//                .padding()
//                .padding(.bottom, 120)
//            }
//        }
//    }
//}
//
//<<<<<<< HEAD
//
//
//// ✅ المعاينة
//#Preview {
//    HomeView()
//        .preferredColorScheme(.light)
//=======
//// ===== واجهة عنصر الفيد =====
//// ✅ تستخدم CKPost الآن (image + content/title)
//
//private struct PostRow: View {
//    let post: CKPost
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            if let img = post.image {
//                Image(uiImage: img)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 220)
//                    .clipped()
//                    .cornerRadius(16)
//            }
//
//            Text(post.content.isEmpty ? post.title : post.content)
//                .font(.body)
//                .foregroundStyle(.primary)
//                .lineLimit(3)
//                .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(14)
//        .background(
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .fill(.ultraThinMaterial)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .stroke(Color.white.opacity(0.25), lineWidth: 1)
//        )
//    }
//}
//
//#Preview {
//    HomeView()
//    //.preferredColorScheme(.dark)
//>>>>>>> main
//}
//import SwiftUI
//import CloudKit
//
//struct HomeView: View {
//
//    // MARK: - UI States
//    @State private var searchText: String = ""
//
//    // MARK: - Environment
//    @Environment(\.colorScheme) private var colorScheme
//
//    // ✅ ViewModel الفيد
//    @StateObject private var feedVM = FeedVM()
//    @StateObject private var cloudVM = UserCloudVM()
//
//
//    // ✅ فلترة البحث
//    var filteredPosts: [ProductModel] {
//        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !q.isEmpty else { return feedVM.posts }
//        return cloudVM.posts.filter {
//            $0.title.localizedCaseInsensitiveContains(q) ||
//            $0.content.localizedCaseInsensitiveContains(q)
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//
//                // ✅ الخلفية (دارك + لايت)
//                if colorScheme == .dark {
//                    Color("BackgroundMain")
//                        .ignoresSafeArea()
//
//                    RadialGradient(
//                        gradient: Gradient(colors: [
//                            Color("GradientEnd"),
//                            Color("GradientStart"),
//                            .clear
//                        ]),
//                        center: .topTrailing,
//                        startRadius: 40,
//                        endRadius: 600
//                    )
//                    .opacity(0.9)
//                    .ignoresSafeArea()
//
//                } else {
//                    RadialGradient(
//                        gradient: Gradient(colors: [
//                            Color("GradientEnd"),
//                            Color("GradientStart"),
//                            Color("GradientMiddle")
//                        ]),
//                        center: .topTrailing,
//                        startRadius: 40,
//                        endRadius: 600
//                    )
//                    .ignoresSafeArea()
//                }
//
//                // ✅ المحتوى
//                VStack {
//                    Spacer().frame(height: 60)
//
//                    // ✅ السيرش
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray.opacity(0.7))
//
//                        TextField("Search", text: $searchText)
//                            .textFieldStyle(.plain)
//
//                        Button { } label: {
//                            Image(systemName: "mic.fill")
//                                .foregroundColor(.gray.opacity(0.7))
//                        }
//                    }
//                    .padding(.horizontal, 14)
//                    .padding(.vertical, 10)
//                    .background(
//                        RoundedRectangle(cornerRadius: 18)
//                            .fill(Color.white.opacity(0.9))
//                    )
//                    .padding(.horizontal, 24)
//
//                    // ✅ فيد البوستات
//                    ScrollView {
//                        LazyVStack(spacing: 14) {
//                            ForEach(Array(filteredPosts.enumerated()), id: \.element.id) { index, post in
//
//                                PostRow(post: post)   // ✅ الآن يستقبل ProductModel
//
//                                    .onAppear {
//                                        if index >= filteredPosts.count - 3 {
//                                            Task {
//                                                await feedVM.loadMore()   // ✅ تحميل المزيد
//                                            }
//                                        }
//                                    }
//                            }
//                        
//                    
//
//
//                            if !filteredPosts.isEmpty {
//                                Button {
//                                    Task { await feedVM.loadMore() }
//                                } label: {
//                                    Text("Load more")
//                                        .font(.footnote)
//                                        .foregroundStyle(.primary)
//                                        .padding(.horizontal, 14)
//                                        .padding(.vertical, 8)
//                                        .background(.ultraThinMaterial, in: Capsule())
//                                }
//                                .padding(.top, 8)
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    }
//                    .refreshable {
//                        await feedVM.load()
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//            .task {
//                await feedVM.load()
//            }
//        }
//    }
//}
//
//// MARK: - ✅ عنصر البوست من CloudKit
//private struct PostRow: View {
//
//    let post: ProductModel   // ✅ بدل CKPost
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//
//            // ✅ صورة المنتج (مؤقتًا System Image)
//            ZStack {
//                Rectangle()
//                    .fill(Color.gray.opacity(0.25))
//                    .frame(height: 220)
//                    .cornerRadius(16)
//
//                Image(systemName: "photo")
//                    .font(.system(size: 40))
//                    .foregroundColor(.gray.opacity(0.6))
//            }
//
//            // ✅ اسم المنتج
//            Text(post.productName)
//                .font(.headline)
//                .foregroundStyle(.primary)
//                .lineLimit(2)
//
//            // ✅ اسم المستخدم + التقييم
//            HStack {
//                Text("@\(post.username)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//
//                Spacer()
//
//                HStack(spacing: 4) {
//                    Image(systemName: "star.fill")
//                        .font(.system(size: 12))
//                        .foregroundColor(.yellow)
//
//                    Text(String(format: "%.1f", post.rating))
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//            }
//
//            // ✅ السعر + الموقع
//            HStack {
//                Text("💰 \(post.price)")
//                Spacer()
//                Text("📍 \(post.location)")
//            }
//            .font(.caption)
//            .foregroundColor(.secondary)
//
//            // ✅ وسم الغلوتن
//            HStack {
//                Spacer()
//
//                Text(post.isGlutenFree ? "Gluten-Free" : "Contains Gluten")
//                    .font(.caption2)
//                    .fontWeight(.semibold)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 3)
//                    .background(
//                        Capsule()
//                            .fill(post.isGlutenFree
//                                  ? Color.green.opacity(0.9)
//                                  : Color.red.opacity(0.9))
//                    )
//                    .foregroundColor(.white)
//            }
//        }
//        .padding(14)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(Color.white.opacity(0.25), lineWidth: 1)
//        )
//    }
//}
//
//
//#Preview {
//    HomeView()
//}
import SwiftUI

struct HomeView: View {

    @StateObject private var cloudVM = UserCloudVM()
    @State private var searchText: String = ""

    @Environment(\.colorScheme) private var colorScheme

    // ✅ فلترة صحيحة 100% على ProductModel
    var filteredProducts: [ProductModel] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !q.isEmpty else {
            return cloudVM.products
        }

        return cloudVM.products.filter { product in
            product.productName.localizedCaseInsensitiveContains(q) ||
            product.username.localizedCaseInsensitiveContains(q) ||
            product.location.localizedCaseInsensitiveContains(q) ||
            product.category.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {

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

                VStack {
                    Spacer().frame(height: 40)

                    // ✅ Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                    )
                    .padding(.horizontal)

                    // ✅ Feed
                    ScrollView {
                        LazyVStack(spacing: 14) {

                            ForEach(filteredProducts) { product in
                                PostRow(post: product)
                            }

                            if filteredProducts.isEmpty {
                                Text("No products yet")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal)
                    }

                   
                }
            }
            .navigationBarHidden(true)
            .task {
                await cloudVM.loadProducts()
            }
        }
    }
}
private struct PostRow: View {

    let post: ProductModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 180)
                    .cornerRadius(16)

                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }

            Text(post.productName)
                .font(.headline)

            HStack {
                Text("@\(post.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)

                    Text(String(format: "%.1f", post.rating))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Text("💰 \(post.price)")
                Spacer()
                Text("📍 \(post.location)")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            HStack {
                Spacer()

                Text(post.isGlutenFree ? "Gluten-Free" : "Contains Gluten")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(post.isGlutenFree ? .green : .red)
                    )
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        )
    }
}
#Preview {
    HomeView()
}
