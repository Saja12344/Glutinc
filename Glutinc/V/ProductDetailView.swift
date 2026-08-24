import SwiftUI

struct ProductDetailView: View {

    let post: ProductModel

    var body: some View {
        ScrollView(showsIndicators: false) {

            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Image
                Image(uiImage: post.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .padding(.horizontal)
                    .padding(.top, 12)

                // MARK: - Header
                VStack(alignment: .leading, spacing: 10) {

                    Text(post.productName)
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        Label(
                            post.isGlutenFree ? "Gluten-Free" : "Contains Gluten",
                            systemImage: post.isGlutenFree
                                ? "checkmark.seal.fill"
                                : "exclamationmark.triangle.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(post.isGlutenFree ? Color.grn : Color.rd)
                        .clipShape(Capsule())

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", post.rating))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        Label(post.price, systemImage: "tag")
                        Spacer()
                        Label(post.location, systemImage: "mappin.and.ellipse")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)
                    .onAppear {
                        print("🧪 detectedIngredients:", post.detectedIngredients)
                        print("🧪 notes:", post.notes ?? "nil")
                        print("🧪 productURL:", post.productURL ?? "nil")
                    }

                // MARK: - Detected Ingredients
                if !post.detectedIngredients.isEmpty {
                    sectionContainer(title: "Detected Ingredients", icon: "leaf") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(post.detectedIngredients, id: \.self) { ingredient in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(post.isGlutenFree ? Color.grn : Color.rd)
                                        .frame(width: 6, height: 6)

                                    Text(ingredient)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }


                // MARK: - Notes
                if let notes = post.notes, !notes.isEmpty {
                    sectionContainer(title: "Notes", icon: "note.text") {
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                }

                // MARK: - Product Link
                if let link = post.productURL,
                   let url = URL(string: link) {

                    sectionContainer(title: "Product Link", icon: "link") {
                        Link(link, destination: url)
                            .font(.body)
                            .foregroundStyle(.blue)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Section Container
    @ViewBuilder
    private func sectionContainer<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.primary)

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}
