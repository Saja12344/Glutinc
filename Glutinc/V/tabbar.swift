
import SwiftUI
import UIKit   // مهم عشان UIColor و UIBlurEffect

enum HomeTab {
    case wheat
    case scan
    case profile
}

struct MainTabContainer: View {
//    @State private var selectedTab: HomeTab = .scan
    @StateObject var userVM = UserCloudVM()
    @State private var selectedTab: HomeTab = .wheat


    init() {
        let appearance = UITabBarAppearance()
        
        // نبدأ بخلفية افتراضية
        appearance.configureWithDefaultBackground()
        
        // نحط البلور (قلاس إفكت)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        // نضيف لون خفيف فوق البلور (اختياري)
        appearance.backgroundColor = UIColor.btn.withAlphaComponent(0.12)

        UITabBar.appearance().standardAppearance = appearance
        
        // مهم للـ scroll edge في iOS 15+
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView (selection: $selectedTab){
            // Home
            NavigationStack {
                      HomeView()
                  }
                  .tabItem {
                      Image("wheat")
                          .renderingMode(.template)
                  }
                  .tag(HomeTab.wheat)

                  // 📷 Scan
                  CameraView(
                    cloudVM: userVM,
                    selectedTab: $selectedTab
                  )
                  .toolbar(.hidden, for: .tabBar) 
                  .tabItem {
                      Image(systemName: "camera")
                  }
                  .tag(HomeTab.scan)

                  // 👤 Profile
                  NavigationStack {
                      ProfileView()
                  }
                  .tabItem {
                      Image(systemName: "person")
                  }
                  .tag(HomeTab.profile)
              }        }
    }

