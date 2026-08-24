////
////  ProductCardView.swift
////  Glutinc22
////
////  Created by saja khalid on 17/06/1447 AH.
////
//
//
//import SwiftUI
//
//struct ProductCardView: View {
//    let image: Image
//    let productName: String
//    let username: String
//    let rating: Double
//    let isGlutenFree: Bool
//    let onBookmarkTap: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            
//            // ✅ الديتيلز فوق
//            VStack(alignment: .leading, spacing: 6) {
//                HStack(spacing: 4) {
//                    
//                    // اسم المنتج
//                    Text(productName)
//                        .font(.headline)
//                        .lineLimit(1)
//                    Spacer()
//                    
//                    // ✅ زر البوك مارك (فوق يمين)
//                    Button(action: onBookmarkTap) {
//                        Image(systemName: "bookmark")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                            .padding(6)
//                            .background(.ultraThinMaterial)
//                            .clipShape(Circle())
//                    }}
//                .padding(6)
//                
//                // الحساب + التقييم
//                HStack(spacing: 8) {
//                    Text("@\(username)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .lineLimit(1)
//                    Spacer()
//                    
//                    
//                    HStack(spacing: 4) {
//                        Image(systemName: "star.fill")
//                            .font(.system(size: 12))
//                            .foregroundColor(.yellow)
//                        Text(String(format: "%.1f", rating))
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//            .padding(.horizontal, 10)
//            .padding(.top, 10)
//            
//            // ✅ الصورة صغيرة تحت (≈ 60)
//            ZStack(alignment: .topTrailing) {
//                
//                // ✅ خلفية رمادي (مؤقتًا بدل الصورة)
//                Rectangle()
//                    .fill(Color.gray.opacity(0.25))
//                    .frame(height: 120)
//                    .overlay(
//                        LinearGradient(
//                            colors: [.black.opacity(0.1), .clear],
//                            startPoint: .top,
//                            endPoint: .center
//                        )
//                    )
//                
//                
//                
//                // ✅ وسم الغلوتن (تحت يمين فوق الصورة)
//                VStack {
//                    Spacer()
//                    
//                    HStack {
//                        Spacer()
//                        
//                        Text(isGlutenFree
//                             ? L10n.t("No gluten ingredients flagged", ar: "لم تُرصد مكونات غلوتين")
//                             : L10n.t("Gluten ingredient flagged", ar: "تم رصد مكوّن غلوتين"))
//                            .font(.caption2)
//                            .fontWeight(.semibold)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 3)
//                            .background(
//                                Capsule()
//                                    .fill(isGlutenFree
//                                          ? Color.green.opacity(0.9)
//                                          : Color.red.opacity(0.9))
//                            )
//                            .foregroundColor(.white)
//                            .padding(6)
//                    }
//                }
//            }
//            
//            Spacer(minLength: 4)
//        }
//        .background(
//            RoundedRectangle(cornerRadius: 18)
//                .fill(.ultraThinMaterial)
//                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
//        )
//        .clipShape(RoundedRectangle(cornerRadius: 18))
//    }
//    
//    ForEach(vm.products) { product in
//        ProductCardView(
//            image: Image(systemName: "photo"),
//            productName: product.productName,
//            username: product.username,
//            rating: product.rating,
//            isGlutenFree: product.isGlutenFree,
//            onBookmarkTap: {
//                print("Bookmark tapped")
//            }
//        )
//    }
//
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

            // ✅ الديتيلز فوق
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {

                    // اسم المنتج
                    Text(productName)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    // ✅ زر البوك مارك
                    Button(action: onBookmarkTap) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(6)

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
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)

            // ✅ الصورة
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 120)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        Text(isGlutenFree
                             ? L10n.t("No gluten ingredients flagged", ar: "لم تُرصد مكونات غلوتين")
                             : L10n.t("Gluten ingredient flagged", ar: "تم رصد مكوّن غلوتين"))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(isGlutenFree
                                          ? Color.green.opacity(0.9)
                                          : Color.red.opacity(0.9))
                            )
                            .foregroundColor(.white)
                            .padding(6)
                    }
                }
            }

            Spacer(minLength: 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
