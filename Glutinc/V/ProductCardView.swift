import SwiftUI

struct ProductCardView: View {
    let image: Image
    let productName: String
    let username: String
    let rating: Double
    let isGlutenFree: Bool
    let onBookmarkTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // الصورة + البوك مارك (٨٠٪ تقريبًا من الكارد)
            ZStack(alignment: .topTrailing) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180) // تقريبًا ٨٠٪ لو الكارد 230–240
                    .clipped()
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.black.opacity(0.15), .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    )
                
                Button(action: onBookmarkTap) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                        .padding(8)
                }
            }
            
            // البيانات تحت الصورة
            VStack(alignment: .leading, spacing: 6) {
                // اسم المنتج
                Text(productName)
                    .font(.headline)
                    .lineLimit(1)
                
                // الحساب + التقييم
                HStack(spacing: 8) {
                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // حالة الغلوتين
                HStack {
                    Text(isGlutenFree ? "Gluten-Free" : "Contains Gluten")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(isGlutenFree ? Color.green.opacity(0.12)
                                                   : Color.red.opacity(0.12))
                        )
                        .foregroundColor(isGlutenFree ? .green : .red)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
