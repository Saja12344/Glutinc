import SwiftUI

struct GlutenResultView: View {
    let image: UIImage
    let ingredients: [GlutenIngredient]
    let extractedText: String

    var body: some View {
        VStack(spacing: 0) {

            // الصورة اللي تم التقاطها
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)

            Divider()

            // صندوق النتائج
            VStack(alignment: .leading, spacing: 10) {
                Text("نتيجة المسح")
                    .font(.title2.bold())

                if ingredients.isEmpty {
                    Text("✔️ لا يوجد جلوتين")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Text("⚠️ يحتوي على جلوتين")
                        .font(.headline)
                        .foregroundColor(.red)

                    ForEach(ingredients, id: \.name) { item in
                        Text("• \(item.name)")
                            .foregroundColor(.red)
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                Text("النص المستخرج:")
                    .font(.headline)

                ScrollView {
                    Text(extractedText)
                        .font(.body)
                        .padding(.bottom)
                }

            }
            .padding()
            .background(Color(.secondarySystemBackground))
        }
        .navigationTitle("نتيجة المسح")
        .navigationBarTitleDisplayMode(.inline)
    }
}
