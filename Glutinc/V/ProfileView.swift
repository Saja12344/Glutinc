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
    @State private var postToDelete: ProductModel?

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
                        postsGrid(
                            items: vm.myPosts,
                            emptyText: L10n.t(
                                "Posts you publish from this account appear here.",
                                ar: "تظهر هنا المنشورات التي تنشرها من هذا الحساب."
                            ),
                            allowsDelete: true
                        )
                    } else {
                        postsGrid(
                            items: vm.savedProducts,
                            emptyText: L10n.t(
                                "Saved posts appear here after you bookmark them.",
                                ar: "تظهر المنشورات المحفوظة هنا بعد حفظها."
                            ),
                            allowsDelete: false
                        )
                    }
                }
            }
            .glutincContentWidth()
          
            .navigationTitle(L10n.t("Profile", ar: "الملف الشخصي"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            vm.loadExploreProducts()
            vm.loadModerationState()
        }
        .confirmationDialog(
            L10n.t("Delete this post?", ar: "حذف هذا المنشور؟"),
            isPresented: Binding(
                get: { postToDelete != nil },
                set: { if !$0 { postToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(L10n.t("Delete", ar: "حذف"), role: .destructive) {
                if let post = postToDelete {
                    vm.deleteMyPost(post)
                }
                postToDelete = nil
            }
            Button(L10n.t("Cancel", ar: "إلغاء"), role: .cancel) {
                postToDelete = nil
            }
        } message: {
            Text(L10n.t(
                "This removes the post from Explore and your profile.",
                ar: "سيُزال المنشور من الاستكشاف ومن ملفك."
            ))
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
    private func postsGrid(items: [ProductModel], emptyText: String, allowsDelete: Bool) -> some View {
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
                columns: [GridItem(.adaptive(minimum: 160), spacing: 12)],
                spacing: 12
            ) {
                ForEach(items) { post in
                    ZStack(alignment: .topTrailing) {
                        NavigationLink {
                            ProductDetailView(post: post)
                        } label: {
                            ProductPhotoFrame(image: post.image, ratio: 1, cornerRadius: 16)
                        }
                        .buttonStyle(.plain)

                        if allowsDelete {
                            Button {
                                postToDelete = post
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.textPrimary)
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .strokeBorder(AppColors.border, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.borderless)
                            .padding(8)
                            .accessibilityLabel(L10n.t("Delete post", ar: "حذف المنشور"))
                        }
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
