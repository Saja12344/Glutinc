import SwiftUI
import AuthenticationServices

struct SignInPromptView: View {
    @EnvironmentObject var vm: UserCloudVM
    @Environment(\.dismiss) private var dismiss
    var title: String = L10n.t("Sign in to continue", ar: "سجّل الدخول للمتابعة")
    var message: String = L10n.t(
        "Saving posts and reporting content requires an account.",
        ar: "حفظ المنشورات والإبلاغ عن المحتوى يتطلب حسابًا."
    )
    var showsCloseButton: Bool = false

    var body: some View {
        VStack(spacing: 18) {
            if showsCloseButton {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(L10n.t("Close", ar: "إغلاق"))
                    Spacer()
                }
            }

            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.teal)
                .accessibilityHidden(true)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                vm.handleSignIn(result: result)
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityLabel(L10n.t("Sign in with Apple", ar: "تسجيل الدخول باستخدام Apple"))

            if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(AppColors.danger)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppColors.navy2)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
}
