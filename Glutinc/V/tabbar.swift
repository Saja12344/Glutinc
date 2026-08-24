
import SwiftUI
import UIKit   // مهم عشان UIColor و UIBlurEffect

enum HomeTab {
    case wheat
    case scan
    case profile
}

struct MainTabContainer: View {
    @EnvironmentObject var userVM: UserCloudVM
    @State private var selectedTab: HomeTab = .wheat

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.navy2)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.textSecondary)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.teal)
        UITabBar.appearance().standardAppearance = appearance
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
                  .environmentObject(userVM)
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

