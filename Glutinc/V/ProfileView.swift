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

                // المحتوى
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 20
                ) {
                    if selectedSegment == 1 {
                        // Posts
                        ForEach(vm.myPosts, id: \.id) { post in
                            Image(uiImage: post.image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipped()
                                .cornerRadius(14)
                        }
                    } else {
                        // Saved
                        ForEach(vm.user.savedImages, id: \.self) { img in
                            Image(img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipped()
                                .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal)

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

            // خلفية خفيفة بدل السواد الثقيل
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Text("Sign in to access your profile")
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: vm.handleSignIn
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(12)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.horizontal, 24)
        }
    }
}



//// ✅ Preview
#Preview("Profile – EN") {
    let vm = UserCloudVM()
    return NavigationStack {
        ProfileView()
    }
}
