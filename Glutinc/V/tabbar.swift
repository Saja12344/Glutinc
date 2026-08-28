
import SwiftUI
import UIKit

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
        appearance.inlineLayoutAppearance.normal.iconColor = UIColor(AppColors.textSecondary)
        appearance.inlineLayoutAppearance.selected.iconColor = UIColor(AppColors.teal)
        appearance.compactInlineLayoutAppearance.normal.iconColor = UIColor(AppColors.textSecondary)
        appearance.compactInlineLayoutAppearance.selected.iconColor = UIColor(AppColors.teal)
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        tabView
    }

    private var tabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image("wheat")
                    .renderingMode(.template)
            }
            .tag(HomeTab.wheat)

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

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person")
            }
            .tag(HomeTab.profile)
        }
        .modifier(PhoneTabBarOnIPad())
    }
}

private struct PhoneTabBarOnIPad: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.tabViewStyle(.tabBarOnly)
        } else {
            content
        }
    }
}
