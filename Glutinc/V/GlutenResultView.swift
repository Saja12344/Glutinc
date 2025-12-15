
import SwiftUI

struct ResultView: View {

    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.colorScheme) var colorScheme

    @State private var goToPost = false

    @ObservedObject var vm: UserCloudVM
    @Binding var selectedTab: HomeTab
//    let isGlutenFree: Bool
    @Binding var capturedImage: UIImage?

    let image: UIImage
    let ingredients: [GlutenIngredient]
    let status: GlutenStatus

    enum GlutenStatus {
        case contains
        case possible
        case safe
        case unknown
    }

    var body: some View {
        VStack(spacing: 12) {

            // ❌ زر الإغلاق
            HStack {
                // RTL support
                if layoutDirection == .rightToLeft { Spacer() }

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        capturedImage = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)

                if layoutDirection != .rightToLeft { Spacer() }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)


            // 📦 المحتوى
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    ZStack(alignment: .bottomLeading) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipped()

                        // Overlay خفيف
                        LinearGradient(
                            colors: [.black.opacity(0.45), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    }
                    .cornerRadius(18)
                    .padding(.horizontal)

                    // 🧠 النتيجة
                    VStack(spacing: 12) {

                        Text(titleText)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(titleColor)

                        if status == .contains || status == .possible {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(listTitle)
                                    .font(.headline)
                                    .foregroundColor(titleColor)

                                ForEach(uniqueIngredients.prefix(4), id: \.self) { name in
                                    HStack {
                                        Circle()
                                            .fill(titleColor)
                                            .frame(width: 8, height: 8)

                                        Text(name.capitalized)
                                    }
                                }
                            }
                            .padding()
                            .background(titleColor.opacity(0.08))
                            .cornerRadius(14)
                        }

                        if status == .safe {
                            Text("This product is safe for a gluten-free diet.")
                                .font(.footnote)
                                .foregroundColor(.grn.opacity(0.85))
                        }

                        if status == .unknown {
                            Text("Please double-check the ingredients manually.")
                                .font(.footnote)
                                .foregroundColor(.gry)
                        }
                    }
                    .padding()
//                    .background(.ultraThinMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // ▶️ Next (ما يظهر في unknown)
                    if status != .unknown {
                        Button {
                            goToPost = true
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .frame(width: 150, height: 52)
                                .foregroundStyle(Color.primary) // أبيض دارك / أسود لايت
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(.ultraThinMaterial)   // قلاسي
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    



                        NavigationLink(
                            destination: Post(
                                cloudVM: vm,
                                selectedTab: $selectedTab,
                                isGlutenFree: status == .safe
                            ),
                            isActive: $goToPost
                        ) {
                            EmptyView()
                        }
                    }


                        NavigationLink(
                            destination: Post(
                                cloudVM: vm,
                                selectedTab: $selectedTab,   // ✅ هذا هو الحل
                                isGlutenFree: status == .safe
                            ),
                            isActive: $goToPost
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
        
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    // MARK: - Helpers

    var uniqueIngredients: [String] {
        Array(Set(ingredients.map { $0.name.lowercased() }))
    }

    var titleText: String {
        switch status {
        case .contains: return "Contains Gluten ❌"
        case .possible: return "May Contain Gluten ⚠️"
        case .safe: return "Gluten-Free ✅"
        case .unknown: return "Unknown ❓"
        }
    }

    var descriptionText: String {
        switch status {
        case .contains:
            return "This product contains ingredients associated with gluten."
        case .possible:
            return "This product may contain gluten due to uncertain ingredients."
        case .safe:
            return "No gluten-related ingredients were detected."
        case .unknown:
            return "The ingredients could not be identified with certainty."
        }
    }

    var listTitle: String {
        status == .contains
        ? "Detected Gluten Ingredients"
        : "Possibly Risky Ingredients"
    }

    var titleColor: Color {
        switch status {
        case .contains: return .rd
        case .possible: return .orng
        case .safe: return .grn
        case .unknown: return .gry
        }
    }
}
