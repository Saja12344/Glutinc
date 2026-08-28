import SwiftUI

struct ProductDetailView: View {
    let post: ProductModel
    @EnvironmentObject var vm: UserCloudVM
    @Environment(\.dismiss) private var dismiss

    @State private var showSignIn = false
    @State private var showReport = false
    @State private var showCorrection = false
    @State private var showBlockConfirm = false
    @State private var showDeleteConfirm = false
    @State private var selectedReportReason: ReportReason = .other
    @State private var selectedCorrection: ProductCorrectionReason = .other
    @State private var detailsText = ""
    @State private var feedback: String?
    @State private var showProductInfo = false
    @State private var showWhyThisResult = false
    @ObservedObject private var languageStore = LanguageStore.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                ProductPhotoFrame(image: post.image, ratio: 4 / 3, cornerRadius: 22)
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .accessibilityLabel(post.productName)

                VStack(alignment: .leading, spacing: 10) {
                    Text(post.productName)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    if post.verificationStatus == .verified {
                        Label(L10n.t("Verified Product", ar: "منتج موثّق"), systemImage: "checkmark.seal.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.teal)
                            .accessibilityLabel(L10n.t("Verified Product", ar: "منتج موثّق"))
                    }

                    Label(post.isCertifiedGlutenFree
                          ? L10n.t("Certified Gluten-Free", ar: "معتمد كمنتج خالٍ من الغلوتين")
                          : post.glutenAnalysisStatus.fullLabel,
                          systemImage: post.glutenAnalysisStatus.iconName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .accessibilityLabel(post.glutenAnalysisStatus.fullLabel)

                    if post.glutenAnalysisStatus == .noGlutenDetected {
                        Text(L10n.t(
                            "This result is based on the available ingredient information and is not a guarantee that the product is gluten-free. Always check the current product label and manufacturer information.",
                            ar: "تعتمد هذه النتيجة على معلومات المكونات المتاحة ولا تضمن أن المنتج خالٍ من الغلوتين. تحقق دائمًا من ملصق المنتج الحالي ومعلومات الشركة المصنعة."
                        ))
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal)

                productInfoSection
                whyThisResult
                manufacturerSection
            }
            .padding(.bottom, 32)
            .glutincContentWidth()
        }
        .background(BackgroundView())
        .navigationTitle(L10n.t("Details", ar: "التفاصيل"))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        guard vm.isSignedIn else {
                            _ = vm.requireSignIn(for: .report)
                            showSignIn = true
                            return
                        }
                        showCorrection = true
                    } label: {
                        Label(L10n.t("Report incorrect information", ar: "الإبلاغ عن معلومات غير صحيحة"), systemImage: "flag")
                    }
                    Button {
                        guard vm.isSignedIn else {
                            _ = vm.requireSignIn(for: .report)
                            showSignIn = true
                            return
                        }
                        showReport = true
                    } label: {
                        Label(L10n.t("Report user / community content", ar: "الإبلاغ عن مستخدم أو محتوى مجتمع"), systemImage: "exclamationmark.bubble")
                    }
                    if vm.owns(post) {
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Label(L10n.t("Delete post", ar: "حذف المنشور"), systemImage: "xmark.circle")
                        }
                    } else if !post.ownerAppleID.isEmpty, post.ownerAppleID != vm.signedUser?.id {
                        Button(role: .destructive) {
                            guard vm.isSignedIn else {
                                showSignIn = true
                                return
                            }
                            showBlockConfirm = true
                        } label: {
                            Label(L10n.t("Block user", ar: "حظر المستخدم"), systemImage: "hand.raised")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel(L10n.t("More actions", ar: "المزيد"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if vm.isSignedIn {
                        vm.toggleSave(productID: post.id)
                    } else {
                        _ = vm.requireSignIn(for: .save(productID: post.id))
                        showSignIn = true
                    }
                } label: {
                    Image(systemName: vm.isSaved(post.id) ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(L10n.t("Save post", ar: "حفظ المنشور"))
            }
        }
        .sheet(isPresented: $showSignIn) { signInSheet }
        .sheet(isPresented: $showReport) { reportSheet }
        .sheet(isPresented: $showCorrection) { correctionSheet }
        .confirmationDialog(
            L10n.t("Block this user?", ar: "حظر هذا المستخدم؟"),
            isPresented: $showBlockConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.t("Block", ar: "حظر"), role: .destructive) {
                vm.blockUser(userId: post.ownerAppleID)
                dismiss()
            }
            Button(L10n.t("Cancel", ar: "إلغاء"), role: .cancel) {}
        }
        .confirmationDialog(
            L10n.t("Delete this post?", ar: "حذف هذا المنشور؟"),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.t("Delete", ar: "حذف"), role: .destructive) {
                vm.deleteMyPost(post) { ok in
                    if ok { dismiss() }
                }
            }
            Button(L10n.t("Cancel", ar: "إلغاء"), role: .cancel) {}
        } message: {
            Text(L10n.t(
                "This removes the post from Explore and your profile.",
                ar: "سيُزال المنشور من الاستكشاف ومن ملفك."
            ))
        }
        .onChange(of: vm.isSignedIn) { signedIn in
            if signedIn, case .save(let id) = vm.pendingAuthAction, id == post.id {
                vm.pendingAuthAction = nil
                showSignIn = false
                vm.toggleSave(productID: id)
            }
        }
    }

    private var glutenHitsToShow: [String] {
        let wantArabic = languageStore.isArabic
        var seen = Set<String>()
        return post.detectedIngredients.compactMap { name -> String? in
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count >= 2 else { return nil }
            let lower = trimmed.lowercased()
            guard !lower.contains("nutrition")
                && !lower.contains("حقائق")
                && !lower.contains("servings")
                && !lower.contains("calories") else { return nil }
            guard let visible = IngredientLanguage.display(trimmed, arabic: wantArabic) else { return nil }
            guard visible.count <= 80 else { return nil }
            let key = visible.lowercased()
            guard seen.insert(key).inserted else { return nil }
            return visible
        }
    }

    private var whyThisResult: some View {
        collapsibleSection(
            title: L10n.t("Why this result?", ar: "لماذا ظهرت هذه النتيجة؟"),
            icon: "text.magnifyingglass",
            isExpanded: $showWhyThisResult
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if post.ingredientCount > 0 {
                    Text("\(post.ingredientCount) " + L10n.t("ingredients analyzed", ar: "مكوّنًا تم تحليلها"))
                }
                Text(post.glutenAnalysisStatus.fullLabel)
                if post.glutenAnalysisStatus == .containsGluten, !glutenHitsToShow.isEmpty {
                    Text(L10n.t("Gluten-containing ingredients detected:", ar: "مكونات تحتوي على الغلوتين:"))
                    ForEach(glutenHitsToShow, id: \.self) { item in
                        Text("• \(item)")
                    }
                } else if post.glutenAnalysisStatus == .uncertain {
                    Text(L10n.t("Some ingredients could not be confidently classified.", ar: "تعذر تصنيف بعض المكونات بشكل مؤكد."))
                }
            }
            .font(.subheadline)
            .foregroundStyle(AppColors.textPrimary)
        }
    }

    @ViewBuilder
    private var manufacturerSection: some View {
        let warnings = post.manufacturerWarnings.compactMap {
            IngredientLanguage.display($0, arabic: languageStore.isArabic)
        }
        if !warnings.isEmpty {
            sectionContainer(title: L10n.t("Manufacturer warnings", ar: "تحذيرات الشركة المصنعة"), icon: "exclamationmark.triangle") {
                Text(L10n.t(
                    "These warnings are separate from ingredient detection. Missing warnings do not prove the product is free from cross-contact.",
                    ar: "هذه التحذيرات منفصلة عن تحليل المكونات. غيابها لا يثبت خلو المنتج من التلوث التبادلي."
                ))
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                ForEach(warnings, id: \.self) { warning in
                    Text("• \(warning)").foregroundStyle(AppColors.warning)
                }
            }
        }
    }

    private var productInfoSection: some View {
        collapsibleSection(
            title: L10n.t("Product information", ar: "معلومات المنتج"),
            icon: "info.circle",
            isExpanded: $showProductInfo
        ) {
            labeledRow(L10n.t("Contributor", ar: "المساهم"), "@\(post.username)")
            labeledRow(L10n.t("Data source", ar: "مصدر البيانات"), localizedDataSource)
            labeledRow(L10n.t("Category", ar: "التصنيف"), post.category)
            if !post.price.trimmingCharacters(in: .whitespaces).isEmpty {
                labeledRow(L10n.t("Price", ar: "السعر"), post.price)
            }
            if post.rating > 0 {
                labeledRow(L10n.t("Contributor rating", ar: "تقييم المساهم"), String(format: "%.0f / 5", post.rating))
            }
            if !post.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                labeledRow(L10n.t("Found at", ar: "تم العثور عليه في"), post.location)
            }
            if let notes = post.notes, !notes.isEmpty {
                labeledRow(L10n.t("Community note", ar: "ملاحظة من المجتمع"), notes)
            }
        }
    }

    private var localizedDataSource: String {
        switch post.dataSource.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "community", "":
            return L10n.t("Community", ar: "المجتمع")
        default:
            return post.dataSource
        }
    }

    private func labeledRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundStyle(AppColors.textSecondary)
            Text(value).foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }
    private var signInSheet: some View {
        ZStack {
            AppColors.navy.ignoresSafeArea()
            SignInPromptView().environmentObject(vm)
        }
        .preferredColorScheme(.dark)
    }

    private var reportSheet: some View {
        NavigationStack {
            Form {
                Picker(L10n.t("Reason", ar: "السبب"), selection: $selectedReportReason) {
                    ForEach(ReportReason.allCases) { reason in
                        Text(reason.title).tag(reason)
                    }
                }
                TextField(L10n.t("Additional details", ar: "تفاصيل إضافية"), text: $detailsText, axis: .vertical)
                Button(L10n.t("Submit report", ar: "إرسال البلاغ")) {
                    let draft = ContentReportDraft(
                        reporterUserId: vm.signedUser?.id ?? "",
                        reportedUserId: post.ownerAppleID,
                        contentId: post.id,
                        contentType: .post,
                        reason: selectedReportReason,
                        additionalDetails: detailsText
                    )
                    vm.reportContent(draft) { ok in
                        feedback = ok
                            ? L10n.t("Report submitted for review.", ar: "تم إرسال البلاغ للمراجعة.")
                            : L10n.t("Could not submit the report.", ar: "تعذر إرسال البلاغ.")
                        showReport = false
                        detailsText = ""
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.navy)
            .navigationTitle(L10n.t("Report post", ar: "الإبلاغ عن المنشور"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("Cancel", ar: "إلغاء")) { showReport = false }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var correctionSheet: some View {
        NavigationStack {
            Form {
                Picker(L10n.t("Reason", ar: "السبب"), selection: $selectedCorrection) {
                    ForEach(ProductCorrectionReason.allCases) { reason in
                        Text(reason.title).tag(reason)
                    }
                }
                TextField(L10n.t("Additional details", ar: "تفاصيل إضافية"), text: $detailsText, axis: .vertical)
                Button(L10n.t("Submit", ar: "إرسال")) {
                    vm.reportIncorrectProduct(productID: post.id, reason: selectedCorrection, details: detailsText) { ok in
                        feedback = ok
                            ? L10n.t("Thanks. This will be reviewed and will not change trusted data automatically.", ar: "شكرًا. ستُراجع المعلومات ولن تُحدَّث البيانات المعتمدة تلقائيًا.")
                            : L10n.t("Could not submit.", ar: "تعذر الإرسال.")
                        showCorrection = false
                        detailsText = ""
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.navy)
            .navigationTitle(L10n.t("Report incorrect information", ar: "الإبلاغ عن معلومات غير صحيحة"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.t("Cancel", ar: "إلغاء")) { showCorrection = false }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var statusColor: Color {
        switch post.scanStatus {
        case .glutenDetected: return AppColors.danger
        case .reviewRecommended: return AppColors.warning
        case .noneDetected: return AppColors.teal
        case .unverifiable, .unreadableIngredients: return AppColors.textSecondary
        }
    }

    @ViewBuilder
    private func sectionContainer<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.card)
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private func collapsibleSection<Content: View>(
        title: String,
        icon: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        DetailDisclosureCard(
            title: title,
            icon: icon,
            isExpanded: isExpanded,
            content: content()
        )
    }
}

private struct DetailDisclosureCard<Content: View>: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let content: Content

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            content
                .padding(.top, 8)
        } label: {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
        }
        .tint(AppColors.teal)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.card)
        )
        .padding(.horizontal)
    }
}
