struct ProductDetailView: View {

    let post: ProductModel

    var body: some View {
        ScrollView {

            Image(uiImage: post.image)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()

            VStack(alignment: .leading, spacing: 16) {

                Text(post.productName)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(post.isGlutenFree ? "Gluten-Free" : "Contains Gluten")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(post.isGlutenFree ? Color.grn : Color.rd)
                    .cornerRadius(10)

                HStack {
                    Label(post.price, systemImage: "tag")
                    Spacer()
                    Label(post.location, systemImage: "mappin.and.ellipse")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", post.rating))
                }

            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
