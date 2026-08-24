import SwiftUI

struct AdminModerationView: View {
    @EnvironmentObject var vm: UserCloudVM
    @State private var tab = 0

    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                Picker("", selection: $tab) {
                    Text(L10n.t("Pending", ar: "معلق")).tag(0)
                    Text(L10n.t("Reports", ar: "البلاغات")).tag(1)
                    Text(L10n.t("Reviewed", ar: "مراجع")).tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                if tab == 0 {
                    productList(vm.products.filter { $0.verificationStatus == .pending || $0.verificationStatus == .needsReview })
                } else if tab == 1 {
                    reportList(vm.reports.filter { $0.status == "pending" })
                } else {
                    reportList(vm.reports.filter { $0.status != "pending" })
                }
            }
        }
        .navigationTitle(L10n.t("Reports", ar: "البلاغات"))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            vm.loadProductsFromCloud()
            vm.refreshReports()
        }
    }

    private func productList(_ items: [ProductModel]) -> some View {
        List {
            if items.isEmpty {
                Text(L10n.t("No products awaiting verification", ar: "لا توجد منتجات بانتظار التوثيق"))
                    .foregroundStyle(AppColors.textSecondary)
            }
            ForEach(items) { product in
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.productName).font(.headline)
                    Text(product.verificationStatus.title + " · " + product.glutenAnalysisStatus.cardLabel)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    HStack {
                        Button(L10n.t("Verify", ar: "توثيق")) {
                            vm.moderateProduct(product, verification: .verified)
                        }
                        Button(L10n.t("Needs review", ar: "يحتاج مراجعة")) {
                            vm.moderateProduct(product, verification: .needsReview)
                        }
                        Button(L10n.t("Reject", ar: "رفض")) {
                            vm.moderateProduct(product, verification: .rejected)
                        }
                    }
                    .font(.caption)
                }
                .listRowBackground(AppColors.card)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func reportList(_ items: [ModerationReport]) -> some View {
        List {
            if items.isEmpty {
                Text(L10n.t("No reports", ar: "لا توجد بلاغات"))
                    .foregroundStyle(AppColors.textSecondary)
            }
            ForEach(items) { report in
                VStack(alignment: .leading, spacing: 6) {
                    Text(report.contentType.capitalized + " · " + report.reason)
                        .font(.headline)
                    if !report.additionalDetails.isEmpty {
                        Text(report.additionalDetails).font(.subheadline)
                    }
                    Text(report.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(L10n.t("Reporter ID is hidden from public views.", ar: "معرّف المبلِّغ مخفي عن العرض العام."))
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                    HStack {
                        Button(L10n.t("Dismiss", ar: "تجاهل")) {
                            vm.setReportStatus(report, status: "dismissed") { _ in }
                        }
                        Button(L10n.t("Resolved", ar: "تم الحل")) {
                            vm.setReportStatus(report, status: "resolved") { _ in }
                        }
                    }
                    .font(.caption)
                }
                .listRowBackground(AppColors.card)
            }
        }
        .scrollContentBackground(.hidden)
    }
}
