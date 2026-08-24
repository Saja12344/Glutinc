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

    private var isAR: Bool {
        Locale.preferredLanguages.first?.hasPrefix("ar") == true
    }

    var body: some View {
        ZStack {

            BackgroundView()

            VStack(spacing: 20) {

                // الاسم
                Text(vm.user.name)
                    .foregroundStyle(.primary)
                    .font(.title2).fontWeight(.semibold)
                    .padding(.bottom, 40)

                // Segmented Control
                HStack(spacing: 150) {

                    segmentButton(
                        icon: "text.justify",
                        isSelected: selectedSegment == 1
                    ) {
                        withAnimation(.spring()) { selectedSegment = 1 }
                    }

                    segmentButton(
                        icon: "bookmark.fill",
                        isSelected: selectedSegment == 2
                    ) {
                        withAnimation(.spring()) { selectedSegment = 2 }
                    }
                }

                if selectedSegment == 1 {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 20
                    ) {
                        ForEach(vm.myPosts, id: \.id) { post in
                            Image(uiImage: post.image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipped()
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 20
                    ) {
                        ForEach(vm.savedProducts) { post in
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

                    if vm.savedProducts.isEmpty {
                        Text(L10n.t("Saved posts appear here after you sign in and bookmark them.", ar: "تظهر المنشورات المحفوظة هنا بعد تسجيل الدخول وحفظها."))
                            .font(.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                            .padding()
                    }
                }

                Spacer()
            }
          
            .navigationTitle(NSLocalizedString("Profile", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
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

    // زر السيجمنت
    private func segmentButton(
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color.orng : .gray.opacity(0.6))

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.orng)
                    .frame(width: isSelected ? 40 : 0, height: 3)
            }
        }
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
