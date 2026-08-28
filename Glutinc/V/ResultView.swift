import SwiftUI

struct ResultView: View {
    @Environment(\.layoutDirection) var layoutDirection
    @EnvironmentObject var vm: UserCloudVM
    @Binding var selectedTab: HomeTab
    @Binding var capturedImage: UIImage?
    @Binding var analysis: ScanAnalysisResult

    let image: UIImage
    let evidence: ProductEvidence
    var onScanAgain: () -> Void
    var onChooseAnotherPhoto: () -> Void
    var onSelectIngredientArea: (() -> Void)? = nil
    var onPublished: () -> Void = {}

    @State private var goToPost = false
    @State private var showSignIn = false
    @State private var showScannedDetails = false
    @ObservedObject private var languageStore = LanguageStore.shared

    var body: some View {
        VStack(spacing: 12) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    imageBlock
                    statusCard
                    if analysis.status == .unreadableIngredients {
                        unreadableSection
                    } else {
                        glutenSection
                        reviewIngredientsSection
                        manufacturerSection
                        scannedDetailsSection
                    }
                    disclaimer
                    if analysis.status == .unreadableIngredients {
                        unreadableActions
                    } else if !evidence.isLikelyFoodProduct {
                        rejectionCard
                    } else if analysis.status != .unverifiable {
                        nextButton
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .background(AppColors.navy2)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .sheet(isPresented: $showSignIn) {
            ZStack {
                AppColors.navy.ignoresSafeArea()
                SignInPromptView(
                    message: L10n.t(
                        "Sign in to share this scan with the community.",
                        ar: "سجّل الدخول لمشاركة هذا المسح مع المجتمع."
                    )
                )
                .environmentObject(vm)
            }
            .preferredColorScheme(.dark)
        }
        .onChange(of: vm.isSignedIn) { signedIn in
            if signedIn, vm.pendingAuthAction == .post {
                vm.pendingAuthAction = nil
                showSignIn = false
                goToPost = true
            }
        }
        .background(
            NavigationLink(
                destination: Post(
                    selectedTab: $selectedTab,
                    isGlutenFree: analysis.status.legacyIsGlutenFreeFlag,
                    detectedIngredientNames: analysis.flaggedNames,
                    analysisStatus: analysis.status,
                    manufacturerWarnings: analysis.manufacturerWarnings.map(\.name),
                    initialImage: image,
                    barcode: evidence.barcode,
                    ingredientText: analysis.extractedText,
                    evidence: evidence,
                    onPublished: onPublished
                ),
                isActive: $goToPost
            ) { EmptyView() }
        )
    }

    private var header: some View {
        HStack {
            if layoutDirection == .rightToLeft { Spacer() }
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { capturedImage = nil }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(AppColors.card))
            }
            .accessibilityLabel(L10n.t("Close result", ar: "إغلاق النتيجة"))
            if layoutDirection != .rightToLeft { Spacer() }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var imageBlock: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(18)
            .padding(.horizontal)
            .accessibilityLabel(L10n.t("Scanned ingredient label", ar: "ملصق المكونات الممسوح"))
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: analysis.status.iconName)
                    .font(.title2)
                    .foregroundStyle(statusColor)
                Text(analysis.status.accessibilityName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(statusColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(analysis.explanation)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if analysis.status == .unreadableIngredients {
                Text(L10n.t(
                    "OCR could not read the ingredient list clearly.",
                    ar: "تعذر على التعرّف البصري قراءة قائمة المكونات بوضوح."
                ))
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(statusColor.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(analysis.status.accessibilityName). \(analysis.explanation)")
    }

    @ViewBuilder
    private var unreadableSection: some View {
        #if DEBUG
        DisclosureGroup {
            Text(analysis.originalOCRText.isEmpty ? "—" : analysis.originalOCRText)
                .font(.caption.monospaced())
                .foregroundStyle(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Text("DEBUG OCR text")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.teal)
        }
        .padding()
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
        #endif
    }

    @ViewBuilder
    private var unreadableActions: some View {
        VStack(spacing: 10) {
            Button(action: onScanAgain) {
                Text(L10n.t("Scan Again", ar: "إعادة المسح"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(AppColors.navy)
                    .background(AppColors.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            Button(action: onChooseAnotherPhoto) {
                Text(L10n.t("Choose Another Photo", ar: "اختيار صورة أخرى"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(AppColors.textPrimary)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            if let onSelectIngredientArea {
                Button(action: onSelectIngredientArea) {
                    Text(L10n.t("Select Ingredient Area", ar: "تحديد منطقة المكونات"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundStyle(AppColors.teal)
                        .background(AppColors.navy3)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .padding(.horizontal)
    }

    private func hitsForAppLanguage(_ hits: [IngredientHit]) -> [IngredientHit] {
        hits.compactMap { hit in
            guard let name = IngredientLanguage.display(hit.name, arabic: languageStore.isArabic) else {
                return nil
            }
            return IngredientHit(name: name, kind: hit.kind)
        }
    }

    @ViewBuilder
    private var glutenSection: some View {
        let hits = hitsForAppLanguage(analysis.glutenHits)
        if !hits.isEmpty {
            card(title: L10n.t("Ingredients that triggered this result", ar: "المكونات التي أدت إلى هذه النتيجة")) {
                ForEach(hits) { hit in
                    ingredientRow(hit.name, color: AppColors.danger)
                }
            }
        }
    }

    @ViewBuilder
    private var reviewIngredientsSection: some View {
        let hits = hitsForAppLanguage(analysis.ambiguousHits)
        if !hits.isEmpty {
            card(title: L10n.t("Ingredients that need review", ar: "مكونات تحتاج إلى مراجعة")) {
                ForEach(hits) { hit in
                    ingredientRow(hit.name, color: AppColors.warning)
                }
            }
        }
    }

    @ViewBuilder
    private var scannedDetailsSection: some View {
        let raw = analysis.originalOCRText.isEmpty ? analysis.extractedText : analysis.originalOCRText
        let hasDetails = !raw.isEmpty
            || !analysis.unknownHits.isEmpty
            || !analysis.possibleOCRHits.isEmpty
            || analysis.scanQuality != .good
        if hasDetails {
            DisclosureGroup(isExpanded: $showScannedDetails) {
                VStack(alignment: .leading, spacing: 10) {
                    if analysis.scanQuality != .good {
                        Text(analysis.scanQuality == .poor
                             ? L10n.t("The scan quality is too low to confirm ingredients.", ar: "جودة المسح منخفضة جدًا لتأكيد المكونات.")
                             : L10n.t("Part of the label may be incomplete or low confidence.", ar: "قد يكون جزء من الملصق غير مكتمل أو منخفض الثقة."))
                            .font(.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    if !analysis.unknownHits.isEmpty {
                        Text(L10n.t("Text we couldn't identify", ar: "نصوص تعذر التعرّف عليها"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        ForEach(hitsForAppLanguage(analysis.unknownHits)) { hit in
                            ingredientRow(hit.name, color: AppColors.textSecondary)
                        }
                    }
                    if !analysis.possibleOCRHits.isEmpty {
                        Text(L10n.t("Possible OCR issue detected", ar: "تم اكتشاف مشكلة محتملة في قراءة النص"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        ForEach(hitsForAppLanguage(analysis.possibleOCRHits)) { hit in
                            ingredientRow(hit.name, color: AppColors.warning)
                        }
                    }
                    if let visibleRaw = IngredientLanguage.display(raw, arabic: languageStore.isArabic),
                       !visibleRaw.isEmpty {
                        Text(L10n.t("Full scanned text", ar: "النص الكامل من المسح"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        Text(visibleRaw)
                            .font(.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, 8)
            } label: {
                Text(L10n.t("More scan details", ar: "تفاصيل إضافية للمسح"))
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
            }
            .tint(AppColors.teal)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var manufacturerSection: some View {
        let warnings = hitsForAppLanguage(analysis.manufacturerWarnings)
        if !warnings.isEmpty {
            card(title: L10n.t("Manufacturer warnings", ar: "تحذيرات الشركة المصنعة")) {
                Text(L10n.t(
                    "These warnings come from the label text and are separate from ingredient detection. Their absence does not mean the product is free from cross-contact.",
                    ar: "هذه التحذيرات من نص الملصق وهي منفصلة عن تحليل المكونات. غيابها لا يعني أن المنتج خالٍ من التلوث التبادلي."
                ))
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                ForEach(warnings) { warning in
                    ingredientRow(warning.name, color: AppColors.warning)
                }
            }
        }
    }

    private var disclaimer: some View {
        Text(ScanAnalysisResult.scannerDisclaimer)
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.navy3)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
            .accessibilityLabel(L10n.t("Important disclaimer", ar: "تنبيه مهم") + ". " + ScanAnalysisResult.scannerDisclaimer)
    }

    private var rejectionCard: some View {
        Text(evidence.rejectionMessage)
            .font(.subheadline)
            .foregroundStyle(AppColors.textPrimary)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.warning.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
            .accessibilityLabel(evidence.rejectionMessage)
    }

    private var nextButton: some View {
        Button {
            if vm.requireSignIn(for: .post) {
                goToPost = true
            } else {
                showSignIn = true
            }
        } label: {
            Text(L10n.t("Share with community", ar: "مشاركة مع المجتمع"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(AppColors.navy)
                .background(AppColors.teal)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(.horizontal)
        .accessibilityHint(L10n.t("Opens the community post form", ar: "يفتح نموذج منشور المجتمع"))
    }

    private func card(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    private func ingredientRow(_ name: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 7))
                .foregroundStyle(color)
            Text(name)
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    private var statusColor: Color {
        switch analysis.status.tint {
        case .red: return AppColors.danger
        case .orange: return AppColors.warning
        case .teal: return AppColors.teal
        case .gray: return AppColors.textSecondary
        }
    }
}
