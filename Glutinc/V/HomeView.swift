import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cloudVM: UserCloudVM
    @State private var searchText: String = ""
    @State private var selectedCategory: ProductCategory? = nil
    @State private var showSignIn = false
    @Environment(\.layoutDirection) private var layoutDirection

    var filteredProducts: [ProductModel] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return cloudVM.exploreProducts.filter { product in
            let matchesSearch =
                q.isEmpty ||
                product.productName.localizedCaseInsensitiveContains(q) ||
                product.username.localizedCaseInsensitiveContains(q) ||
                product.location.localizedCaseInsensitiveContains(q) ||
                product.category.localizedCaseInsensitiveContains(q)
            let matchesCategory =
                selectedCategory == nil ||
                product.category == selectedCategory?.rawValue
            return matchesSearch && matchesCategory
        }
    }

    enum ProductCategory: String, CaseIterable, Identifiable {
        case grains = "Grains & Flours"
        case dairy = "Dairy"
        case drinks = "Drinks"
        case meat = "Meat & Alternatives"
        case others = "Others"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                VStack(spacing: 0) {
                    Text(L10n.t(
                        "Community content is shared by users and is not medical advice.",
                        ar: "محتوى المجتمع يشاركه المستخدمون ولا يُعد استشارة طبية."
                    ))
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            categoryChip(L10n.t("All", ar: "الكل"), selected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(ProductCategory.allCases) { category in
                                categoryChip(category.rawValue, selected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredProducts) { post in
                                NavigationLink {
                                    ProductDetailView(post: post)
                                } label: {
                                    PostRow(post: post, onSave: handleSave)
                                }
                                .buttonStyle(.plain)
                            }

                            if filteredProducts.isEmpty {
                                VStack(spacing: 8) {
                                    Text(L10n.t("No Explore products", ar: "لا توجد منتجات في الاستكشاف"))
                                        .font(.headline)
                                        .foregroundStyle(AppColors.textSecondary)
                                    Text(L10n.t(
                                        "Only verified products with no gluten ingredients detected appear here.",
                                        ar: "تظهر هنا فقط المنتجات الموثّقة التي لم يُكتشف فيها مكونات غلوتين."
                                    ))
                                    .font(.footnote)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                                }
                                .padding(.top, 40)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle(L10n.t("Explore", ar: "استكشف"))
            .searchable(text: $searchText, prompt: L10n.t("Search", ar: "بحث"))
            .onAppear { cloudVM.loadExploreProducts() }
            .sheet(isPresented: $showSignIn) {
                ZStack {
                    AppColors.navy.ignoresSafeArea()
                    SignInPromptView(
                        message: L10n.t(
                            "Sign in to save posts to your profile.",
                            ar: "سجّل الدخول لحفظ المنشورات في ملفك."
                        )
                    )
                    .environmentObject(cloudVM)
                }
                .preferredColorScheme(.dark)
            }
            .onChange(of: cloudVM.isSignedIn) { signedIn in
                if signedIn, case .save(let id) = cloudVM.pendingAuthAction {
                    cloudVM.pendingAuthAction = nil
                    showSignIn = false
                    cloudVM.toggleSave(productID: id)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func handleSave(productID: String) {
        if cloudVM.isSignedIn {
            cloudVM.toggleSave(productID: productID)
        } else {
            _ = cloudVM.requireSignIn(for: .save(productID: productID))
            showSignIn = true
        }
    }

    private func categoryChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(selected ? AppColors.teal : AppColors.card)
                .foregroundStyle(selected ? AppColors.navy : AppColors.textPrimary)
                .cornerRadius(12)
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct PostRow: View {
    let post: ProductModel
    var onSave: (String) -> Void
    @EnvironmentObject var cloudVM: UserCloudVM

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: post.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(16)

                Button {
                    onSave(post.id)
                } label: {
                    Image(systemName: cloudVM.isSaved(post.id) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.borderless)
                .padding(10)
                .accessibilityLabel(
                    cloudVM.isSaved(post.id)
                    ? L10n.t("Remove from saved", ar: "إزالة من المحفوظات")
                    : L10n.t("Save post", ar: "حفظ المنشور")
                )
            }

            Text(post.productName)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: 8) {
                if post.verificationStatus == .verified {
                    Label(L10n.t("Verified Product", ar: "منتج موثّق"), systemImage: "checkmark.seal.fill")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.teal)
                        .accessibilityLabel(L10n.t("Verified Product", ar: "منتج موثّق"))
                }
                Text(post.glutenCardLabel)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.teal.opacity(0.18))
                    .clipShape(Capsule())
                    .accessibilityLabel(post.glutenAnalysisStatus.fullLabel)
            }

            if !post.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.t("Found at", ar: "تم العثور عليه في"))
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(post.location)
                        .font(.caption)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.card)
        )
    }
}
