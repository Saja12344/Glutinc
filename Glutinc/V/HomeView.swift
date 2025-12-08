//
//import SwiftUI
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
//// ✅ تابّات التاب بار
//enum HomeTab {
//    case wheat
//    case scan
//    case profile
//}
//
//struct HomeView: View {
//    
//    @State private var searchText: String = ""
//    @State private var selectedTab: HomeTab = .scan
//    @Environment(\.colorScheme) private var colorScheme
//    @State private var selectedFilter: String = "All"
//    
//    let filters: [String] = [
//        "All",
//        "Grains & Flours",
//        "Dairy",
//        "Drinks",
//        "Meat & Alternatives",
//        "Others"
//    ]
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
//                // ✅ التنقّل الحقيقي بين الصفحات
//                Group {
//                    switch selectedTab {
//                    case .wheat:
//                        HomeView()          // عدّلي الاسم لو صفحتك اسمها غير هذا
//                        
//                    case .scan:
//                        CameraView()
//
//                    case .profile:
//                        SettingsView(vm: UserVM())   // ✅ صفحة الإعدادات الحقيقية
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                
//                // ✅ التاب بار
//                GlassTabBar(selectedTab: $selectedTab)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 24)
//            }
//            ZStack(alignment: .bottom) {
//                
//                // ✅ الخلفية (لايت + دارك)
//                if colorScheme == .dark {
//                    
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
//                    
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
//                // ✅ الشبكة الصحيحة
//                //
//                let columns = [
//                    GridItem(.flexible())
//                ]
//                
//                
//                
//                
//                
//                
//                // ✅ السيرش بار فوق
//                VStack(spacing: 12) {
//                    Spacer().frame(height: 60)
//                    
//                    // ✅ السيرش بار
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray.opacity(0.7))
//                        
//                        TextField("Search", text: $searchText)
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
//                    // ✅ ✅ ✅ الفلاتر تحت السيرش
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 10) {
//                            ForEach(filters, id: \.self) { filter in
//                                Button {
//                                    selectedFilter = filter
//                                } label: {
//                                    Text(filter)
//                                        .font(.subheadline)
//                                        .padding(.horizontal, 14)
//                                        .padding(.vertical, 8)
//                                        .background(
//                                            Capsule()
//                                                .fill(
//                                                    selectedFilter == filter
//                                                    ? Color("PrimaryBlue").opacity(0.15)
//                                                    : Color.gray.opacity(0.15)
//                                                )
//                                        )
//                                        .foregroundColor(
//                                            selectedFilter == filter
//                                            ? Color("PrimaryBlue")
//                                            : .primary
//                                        )
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 24)
//                        .padding(.bottom,0)
//                        
//                    }
//                    
//                    ScrollView {
//                        LazyVGrid(columns: columns, spacing: 20) {
//                            
//                            ForEach(products) { product in
//                                ProductCardView(
//                                    image: Image(product.imageName),
//                                    productName: product.name,
//                                    username: product.username,
//                                    rating: product.rating,
//                                    isGlutenFree: product.isGlutenFree,
//                                    onBookmarkTap: {
//                                        print("Bookmark tapped")
//                                    }
//                                )
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.top, 140)
//                        .padding(.bottom, 120)
//                    }
//                }
//                
//                // ✅ التاب بار القلاسي
//                GlassTabBar(selectedTab: $selectedTab)
//                    .padding(.horizontal, 40)
//                    .padding(.bottom, 4)
//            }
//        }
//    }
//    
//    // ✅ Glass Tab Bar
//    
//    struct GlassTabBar: View {
//        
//        @Binding var selectedTab: HomeTab
//        
//        var body: some View {
//            HStack(spacing: 0) {
//                tabButton(.wheat, imageName: "wheat")
//                tabButton(.scan, imageName: "scan")
//                tabButton(.profile, imageName: "profile")
//            }
//            .padding(6)
//            .background(
//                RoundedRectangle(cornerRadius: 30)
//                    .fill(.ultraThinMaterial)
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 30)
//                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
//            )
//            .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
//            .frame(width: 260, height: 72)
//        }
//        
//        private func tabButton(_ tab: HomeTab, imageName: String) -> some View {
//            Button {
//                selectedTab = tab
//            } label: {
//                ZStack {
//                    
//                    if selectedTab == tab {
//                        RoundedRectangle(cornerRadius: 26)
//                            .fill(Color.white.opacity(0.95))
//                            .shadow(color: .black.opacity(0.10),
//                                    radius: 12, x: 0, y: 4)
//                            .padding(4)
//                    }
//                    
//                    Image(imageName)
//                        .resizable()
//                        .renderingMode(.template)
//                        .scaledToFit()
//                        .frame(width: 26, height: 26)
//                        .foregroundColor(
//                            selectedTab == tab
//                            ? Color("PrimaryBlue")
//                            : Color.primary.opacity(0.4)
//                        )
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//            .buttonStyle(.plain)
//        }
//    }
//}
//// ✅ المعاينة
//#Preview {
//    HomeView()
//        //.preferredColorScheme(.dark)
//        .preferredColorScheme(.light)
//}
import SwiftUI

// ✅ مودل المنتج
struct Product: Identifiable {
    let id = UUID()
    let imageName: String
    let name: String
    let username: String
    let rating: Double
    let isGlutenFree: Bool
}



struct HomeView: View {
    @State private var selectedTab: HomeTab = .wheat
    @State private var searchText: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedFilter: String = "All"
    @State private var username: String? = nil

    
    let filters: [String] = [
        "All",
        "Grains & Flours",
        "Dairy",
        "Drinks",
        "Meat & Alternatives",
        "Others"
    ]
    
    // ✅ بيانات تجريبية
    let products: [Product] = [
        Product(imageName: "sampleProduct2", name: "Chocolate Cookie", username: "sweet.bakes", rating: 3.9, isGlutenFree: false),
        Product(imageName: "sampleProduct2", name: "Vanilla Cake", username: "bake.house", rating: 4.5, isGlutenFree: true),
        Product(imageName: "sampleProduct2", name: "Brownie", username: "choco.bar", rating: 4.1, isGlutenFree: false),
        Product(imageName: "sampleProduct2", name: "Donut", username: "sweet.life", rating: 4.0, isGlutenFree: true)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                // ✅ الخلفية
                if colorScheme == .dark {
                    Color("BackgroundMain")
                        .ignoresSafeArea()
                } else {
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color("GradientEnd"),
                            Color("GradientStart"),
                            Color("GradientMiddle")
                        ]),
                        center: .topTrailing,
                        startRadius: 40,
                        endRadius: 600
                    )
                    .ignoresSafeArea()
                }
                
                
                homeContent
                
            }
        }
    }
    private var homeContent: some View {
        let columns = [GridItem(.flexible())]

        return VStack(alignment: .leading, spacing: 16) {

            // ✅ ✅ ✅ الترحيب
            VStack(alignment: .leading, spacing: 2) {

                // ✅ Hi (صغير)
                Text("Hi")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryBlue").opacity(0.7))

                // ✅ Guest أو اسم المستخدم (كبير)
                Text(username == nil ? "Guest 👋" : "\(username!) 👋")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("PrimaryBlue"))

            }
            .padding(.horizontal)
            .padding(.top, 10)


            // ✅ السيرش الديفولت
            Color.clear
                .frame(height: 0)
                .searchable(text: $searchText, prompt: "Search")

            // ✅ الفلاتر
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filters, id: \.self) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Text(filter)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(
                                        selectedFilter == filter
                                        ? Color("PrimaryBlue").opacity(0.2)
                                        : Color.gray.opacity(0.2)
                                    )
                                )
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // ✅ الكروت
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(products) { product in
                        ProductCardView(
                            image: Image(product.imageName),
                            productName: product.name,
                            username: product.username,
                            rating: product.rating,
                            isGlutenFree: product.isGlutenFree,
                            onBookmarkTap: {}
                        )
                    }
                }
                .padding()
                .padding(.bottom, 120)
            }
        }
    }
}



// ✅ المعاينة
#Preview {
    HomeView()
        .preferredColorScheme(.light)
}
