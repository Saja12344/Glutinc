import SwiftUI
struct ProfileView: View {

    @EnvironmentObject var vm: UserCloudVM

    var body: some View {
        Group {
            if vm.signedUser == nil {
                SignInGateView()
            } else {
                ProfileContentView()
            }
        }
    }
}
struct ProfileContentView: View {

    @EnvironmentObject var vm: UserCloudVM
    @State private var selectedSegment: Int = 1

    private var isAR: Bool { L10n.isArabic }

    var body: some View {
        ZStack {

            BackgroundView()

            VStack(spacing: 16) {

                Text(vm.user.name)
                    .foregroundStyle(.primary)
                    .font(.title2).fontWeight(.semibold)
                    .padding(.bottom, 8)

                HStack(spacing: 40) {
                    segmentButton(
                        icon: "square.grid.2x2",
                        title: L10n.t("Posts", ar: "المنشورات"),
                        isSelected: selectedSegment == 1
                    ) {
                        withAnimation(.spring()) { selectedSegment = 1 }
                    }

                    segmentButton(
                        icon: "bookmark.fill",
                        title: L10n.t("Saved", ar: "المحفوظات"),
                        isSelected: selectedSegment == 2
                    ) {
                        withAnimation(.spring()) { selectedSegment = 2 }
                    }
                }
                .frame(maxWidth: .infinity)

                ScrollView {
                    if selectedSegment == 1 {
                        postsGrid(items: vm.myPosts, emptyText: L10n.t(
                            "Posts you publish from this account appear here.",
                            ar: "تظهر هنا المنشورات التي تنشرها من هذا الحساب."
                        ))
                    } else {
                        postsGrid(items: vm.savedProducts, emptyText: L10n.t(
                            "Saved posts appear here after you bookmark them.",
                            ar: "تظهر المنشورات المحفوظة هنا بعد حفظها."
                        ))
                    }
                }
            }
          
            .navigationTitle(L10n.t("Profile", ar: "الملف الشخصي"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            vm.loadExploreProducts()
            vm.loadModerationState()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView()
                        .environment(\.layoutDirection, isAR ? .rightToLeft : .leftToRight)
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    @ViewBuilder
    private func postsGrid(items: [ProductModel], emptyText: String) -> some View {
        if items.isEmpty {
            Text(emptyText)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 48)
                .padding(.horizontal)
        } else {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 16
            ) {
                ForEach(items) { post in
                    NavigationLink {
                        ProductDetailView(post: post)
                    } label: {
                        Image(uiImage: post.image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .clipped()
                            .cornerRadius(14)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    // زر السيجمنت
    private func segmentButton(
        icon: String,
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.orng : .gray.opacity(0.6))
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.orng)
                    .frame(width: isSelected ? 40 : 0, height: 3)
            }
        }
        .accessibilityLabel(title)
    }
}
import AuthenticationServices


struct SignInGateView: View {

    @EnvironmentObject var vm: UserCloudVM

    var body: some View {
        ZStack {
            BackgroundView()

            SignInPromptView(
                title: L10n.t("Sign in to access your profile", ar: "سجّل الدخول للوصول إلى ملفك"),
                message: L10n.t(
                    "Saving posts and managing your account requires Sign in with Apple.",
                    ar: "حفظ المنشورات وإدارة حسابك يتطلبان تسجيل الدخول باستخدام Apple."
                )
            )
        }
        .preferredColorScheme(.dark)
    }
}



//// ✅ Preview
#Preview("Profile – EN") {
    let vm = UserCloudVM()
    return NavigationStack {
        ProfileView()
    }
}
