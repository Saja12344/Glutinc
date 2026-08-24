import SwiftUI

struct LegalHubView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(spacing: 12) {
                    NavigationLink { PrivacyPolicyView() } label: {
                        SettingRowContent(icon: "hand.raised.fill", title: L10n.t("Privacy Policy", ar: "سياسة الخصوصية"))
                    }.buttonStyle(.plain)

                    NavigationLink { TermsOfUseView() } label: {
                        SettingRowContent(icon: "doc.text", title: L10n.t("Terms of Use", ar: "شروط الاستخدام"))
                    }.buttonStyle(.plain)

                    NavigationLink { HealthDisclaimerView() } label: {
                        SettingRowContent(icon: "heart.text.clipboard", title: L10n.t("Health Information", ar: "معلومات صحية"))
                    }.buttonStyle(.plain)

                    NavigationLink { CommunityGuidelinesView() } label: {
                        SettingRowContent(icon: "person.3", title: L10n.t("Community Guidelines", ar: "إرشادات المجتمع"))
                    }.buttonStyle(.plain)

                    NavigationLink { SupportView() } label: {
                        SettingRowContent(icon: "envelope", title: L10n.t("Contact / Support", ar: "التواصل والدعم"))
                    }.buttonStyle(.plain)
                }
                .padding()
            }
        }
        .navigationTitle(L10n.t("Legal", ar: "قانوني"))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        legalScroll(title: L10n.t("Privacy Policy", ar: "سياسة الخصوصية")) {
            legalBlock(L10n.t(
                "Glutinc (قلوتنك) is operated by Team 3 Apple Academy. Contact: glutinc.sa@gmail.com. Last updated 24 August 2026.",
                ar: "قلوتنك (Glutinc) تشغّله تيم 3 آبل أكاديمي. للتواصل: glutinc.sa@gmail.com. آخر تحديث 24 أغسطس 2026."
            ))
            legalBlock(L10n.t(
                "Glutinc is an informational ingredient-review and community app for people who follow a gluten-free diet or want help reviewing gluten-related ingredient information. It does not provide medical advice, diagnosis, or treatment.",
                ar: "قلوتنك تطبيق معلوماتي لمراجعة المكونات ومجتمع للأشخاص الذين يتبعون نظامًا غذائيًا خاليًا من الغلوتين أو يحتاجون مساعدة في مراجعة معلومات المكونات المتعلقة بالغلوتين. لا يقدم استشارة طبية أو تشخيصًا أو علاجًا."
            ))
            legalBlock(L10n.t(
                "Data we store when you use an account: Sign in with Apple user identifier, display name if provided, email if Apple shares it, profile photo if you add one, community posts (product name, photo, notes, location, category, rating, scanned ingredient flags), saved post IDs, blocked user IDs, and reports you submit. Scanner images are processed on device for text recognition. Posted photos are stored in iCloud via CloudKit if you publish a community post.",
                ar: "البيانات التي نحتفظ بها عند استخدام حساب: معرّف تسجيل الدخول بـ Apple، الاسم إن وُجد، البريد إن شاركته Apple، صورة الملف إن أضفتها، منشورات المجتمع، المنشورات المحفوظة، المستخدمون المحظورون، والبلاغات. تُعالَج صور الماسح على الجهاز للتعرّف على النص. تُحفظ صور المنشورات في iCloud عبر CloudKit إذا نشرت في المجتمع."
            ))
            legalBlock(L10n.t(
                "On-device processing: the camera and Photo Library are used to capture or select ingredient labels and community photos. We do not use advertising SDKs. Push notification permission is not requested on launch. Crash and analytics SDKs are not bundled in this build. CloudKit / iCloud is provided by Apple and subject to Apple’s privacy terms.",
                ar: "المعالجة على الجهاز: تُستخدم الكاميرا ومكتبة الصور لالتقاط أو اختيار ملصقات المكونات وصور المجتمع. لا نستخدم حزم إعلانات. لا يُطلب إذن الإشعارات عند الفتح. لا تتضمن هذه النسخة حزم تحليلات أو أعطال. CloudKit / iCloud خدمة من Apple وتخضع لسياسة خصوصيتها."
            ))
            legalBlock(L10n.t(
                "Retention: account data is kept while the account exists. Deleting your account removes your private CloudKit profile, saved items, and block list, and anonymizes your public posts (username becomes “Deleted account”). Reports may be retained for safety review. We do not sell personal data.",
                ar: "الاحتفاظ: تبقى بيانات الحساب طالما الحساب موجود. حذف الحساب يزيل الملف الخاص والعناصر المحفوظة وقائمة الحظر، ويُجهَّل منشوراتك العامة (يصبح الاسم «حساب محذوف»). قد تُحفظ البلاغات لمراجعة السلامة. لا نبيع البيانات الشخصية."
            ))
            legalBlock(L10n.t(
                "You can delete your account in Settings.",
                ar: "يمكنك حذف حسابك من الإعدادات."
            ))
            if let url = AppConfig.privacyPolicyURL {
                Link(L10n.t("Open full privacy policy", ar: "فتح سياسة الخصوصية الكاملة"), destination: url)
                    .foregroundStyle(AppColors.teal)
            }
        }
    }
}

struct TermsOfUseView: View {
    var body: some View {
        legalScroll(title: L10n.t("Terms of Use", ar: "شروط الاستخدام")) {
            legalBlock(L10n.t(
                "Glutinc provides informational tools to review ingredient text and share community observations. Scanner results are not a guarantee that a product is gluten-free and must not replace reading the current package label or manufacturer information.",
                ar: "يوفر Glutinc أدوات معلوماتية لمراجعة نص المكونات ومشاركة ملاحظات المجتمع. نتائج الماسح ليست ضمانًا بأن المنتج خالٍ من الغلوتين ولا تغني عن قراءة الملصق الحالي أو معلومات الشركة المصنعة."
            ))
            legalBlock(L10n.t(
                "You are responsible for content you post. Do not present community posts as professional medical advice. We may remove content that violates Community Guidelines.",
                ar: "أنت مسؤول عن المحتوى الذي تنشره. لا تعرض منشورات المجتمع كاستشارة طبية مهنية. قد نزيل المحتوى الذي يخالف إرشادات المجتمع."
            ))
        }
    }
}

struct HealthDisclaimerView: View {
    var body: some View {
        legalScroll(title: L10n.t("Health Information", ar: "معلومات صحية")) {
            legalBlock(L10n.t(
                "Glutinc provides informational tools to help users review food ingredients and gluten-related information. Glutinc does not provide medical advice, diagnosis, or treatment and should not replace professional medical advice.",
                ar: "يوفر Glutinc أدوات ومعلومات تساعد المستخدم على مراجعة مكونات المنتجات والمعلومات المتعلقة بالغلوتين. لا يقدم Glutinc استشارة طبية أو تشخيصًا أو علاجًا، ولا يُعد بديلًا عن استشارة المختصين الصحيين."
            ))
            legalBlock(L10n.t(
                "Celiac disease, wheat allergy, and non-celiac gluten sensitivity are different conditions. Glutinc does not diagnose any medical condition. Green scanner results mean no known gluten-containing ingredients were identified in the available text — not that the product is safe to eat.",
                ar: "مرض السيلياك وحساسية القمح والحساسية غير السيلياكية للغلوتين حالات مختلفة. لا يشخص Glutinc أي حالة طبية. النتيجة الخضراء تعني أنه لم يُتعرف على مكونات معروفة باحتوائها على الغلوتين في النص المتاح — وليست إعلانًا بأن المنتج آمن للأكل."
            ))
            legalBlock(L10n.t(
                "For people who follow a gluten-free diet or need help reviewing gluten-related ingredient information.",
                ar: "للأشخاص الذين يتبعون نظامًا غذائيًا خاليًا من الغلوتين أو يحتاجون إلى المساعدة في مراجعة معلومات المكونات المتعلقة بالغلوتين."
            ))
            if let url = AppConfig.healthDisclaimerURL {
                Link(L10n.t("Open full health disclaimer", ar: "فتح إخلاء المسؤولية الصحية الكامل"), destination: url)
                    .foregroundStyle(AppColors.teal)
            }
        }
    }
}

struct CommunityGuidelinesView: View {
    var body: some View {
        legalScroll(title: L10n.t("Community Guidelines", ar: "إرشادات المجتمع")) {
            legalBlock(L10n.t(
                "Do not post harassment, hate speech, spam, illegal content, dangerous misinformation, content encouraging unsafe medical behavior, false claims presented as professional medical advice, or personal information about others without permission.",
                ar: "لا تنشر تحرشًا أو خطاب كراهية أو رسائل مزعجة أو محتوى غير قانوني أو معلومات مضللة خطرة أو محتوى يشجع سلوكًا طبيًا غير آمن أو ادعاءات كاذبة تُعرض كاستشارة طبية مهنية أو معلومات شخصية عن الآخرين دون إذن."
            ))
            legalBlock(L10n.t(
                "Community content is shared by users and is not medical advice. Use Report and Block if you see content that breaks these rules.",
                ar: "محتوى المجتمع يشاركه المستخدمون ولا يُعد استشارة طبية. استخدم الإبلاغ والحظر إذا رأيت محتوى يخالف هذه القواعد."
            ))
            if let url = AppConfig.communityGuidelinesURL {
                Link(L10n.t("Open full community guidelines", ar: "فتح إرشادات المجتمع الكاملة"), destination: url)
                    .foregroundStyle(AppColors.teal)
            }
        }
    }
}

struct SupportView: View {
    var body: some View {
        legalScroll(title: L10n.t("Contact / Support", ar: "التواصل والدعم")) {
            legalBlock(L10n.t(
                "Operated by Team 3 Apple Academy. Country: Saudi Arabia.",
                ar: "تشغّله تيم 3 آبل أكاديمي. الدولة: المملكة العربية السعودية."
            ))
            if let email = AppConfig.supportEmail, let url = URL(string: "mailto:\(email)") {
                Link(email, destination: url)
                    .font(.headline)
                    .foregroundStyle(AppColors.teal)
            }
            if let url = AppConfig.supportURL {
                Link(url.absoluteString, destination: url)
            }
        }
    }
}

struct AboutGlutincView: View {
    var body: some View {
        legalScroll(title: L10n.t("About", ar: "حول التطبيق")) {
            legalBlock(L10n.t(
                "For people who follow a gluten-free diet or need help reviewing gluten-related ingredient information.",
                ar: "للأشخاص الذين يتبعون نظامًا غذائيًا خاليًا من الغلوتين أو يحتاجون إلى المساعدة في مراجعة معلومات المكونات المتعلقة بالغلوتين."
            ))
            NavigationLink { HealthDisclaimerView() } label: {
                SettingRowContent(icon: "heart.text.clipboard", title: L10n.t("Health Information", ar: "معلومات صحية"))
            }.buttonStyle(.plain)
            NavigationLink { LegalHubView() } label: {
                SettingRowContent(icon: "building.columns", title: L10n.t("Legal", ar: "قانوني"))
            }.buttonStyle(.plain)
        }
    }
}

struct DeleteAccountView: View {
    @EnvironmentObject var vm: UserCloudVM
    @Environment(\.dismiss) private var dismiss
    @State private var typedConfirm = ""
    @State private var isWorking = false

    private var confirmWord: String { L10n.isArabic ? "حذف" : "DELETE" }

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.t("Delete Account", ar: "حذف الحساب"))
                        .font(.title2.bold())
                    legalBlock(L10n.t(
                        "This permanently deletes your Glutinc account. We will remove your private profile, saved posts, and block list. Your public community posts will be anonymized (username becomes “Deleted account”) so threads stay intact without your personal details.",
                        ar: "سيُحذف حساب Glutinc نهائيًا. نزيل الملف الخاص والمنشورات المحفوظة وقائمة الحظر. تُجهَّل منشوراتك العامة (يصبح الاسم «حساب محذوف») دون بياناتك الشخصية."
                    ))
                    legalBlock(L10n.t(
                        "Safety reports you already submitted may be kept, without showing your identity in the app, for moderation. Sign in with Apple cannot be fully revoked from this device without a server token-revoke endpoint — after deletion, remove Glutinc from your Apple ID settings if you want to disconnect Apple Sign In.",
                        ar: "قد تُحفظ البلاغات السابقة لأغراض الإشراف دون إظهار هويتك في التطبيق. لا يمكن إلغاء ارتباط Sign in with Apple بالكامل من الجهاز دون خادم. بعد الحذف، أزل Glutinc من إعدادات Apple ID إذا أردت فصل تسجيل الدخول."
                    ))

                    TextField(confirmWord, text: $typedConfirm)
                        .textInputAutocapitalization(.characters)
                        .padding()
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        isWorking = true
                        vm.deleteAccount { _ in
                            isWorking = false
                            dismiss()
                        }
                    } label: {
                        Text(isWorking
                             ? L10n.t("Deleting…", ar: "جارٍ الحذف…")
                             : L10n.t("Delete my account", ar: "احذف حسابي"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .background(typedConfirm == confirmWord ? AppColors.danger : AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(typedConfirm != confirmWord || isWorking)
                    .accessibilityLabel(L10n.t("Delete my account", ar: "احذف حسابي"))
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

private func legalScroll<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    ZStack {
        BackgroundView()
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.textPrimary)
                content()
            }
            .padding()
        }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .preferredColorScheme(.dark)
}

private func legalBlock(_ text: String) -> some View {
    Text(text)
        .font(.body)
        .foregroundStyle(AppColors.textSecondary)
        .fixedSize(horizontal: false, vertical: true)
}

/// Backward-compatible name used by Settings.
struct PrivacyView: View {
    var body: some View { PrivacyPolicyView() }
}
