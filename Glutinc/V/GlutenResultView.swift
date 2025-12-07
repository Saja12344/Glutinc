////
////  GlutenResultView.swift
////  Glutinc
////
////  Created by saja khalid on 11/06/1447 AH.
////

//
import SwiftUI


struct ResultView: View {
    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.colorScheme) var colorScheme

    let image: UIImage
    let ingredients: [GlutenIngredient]
    let status: GlutenStatus

    var onClose: () -> Void
    var onPost: () -> Void

    var containsGluten: Bool {
        !ingredients.isEmpty
    }
    enum GlutenStatus {
        case contains
        case possible
        case safe
        case unknown
    }




    var body: some View {
        VStack(spacing: 12) {

            HStack {
                if layoutDirection == .rightToLeft {
                    Spacer()
                }

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(.ultraThickMaterial.opacity(0.7))
                                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4) // ✅ الظل هنا فقط
                        )
                }


                if layoutDirection != .rightToLeft {
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.top, 22)
            .padding(.bottom, 12)




            // ✅ المحتوى
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // ✅ الصورة
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(16)

//                    // ✅ العنوان
//                    Text(containsGluten ? "Contains Gluten ⚠️" : "Gluten-Free ✅")
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundColor(containsGluten ? .rd : .grn)
//
//                    // ✅ الوصف
//                    Text(containsGluten
//                         ? "This product contains ingredients associated with gluten."
//                         : "No gluten-related ingredients were detected.")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.center)
//
//                    // ✅ المكونات
//                    if containsGluten {
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text("Detected Gluten Ingredients")
//                                .font(.headline)
//                                .foregroundColor(.rd.opacity(0.85))
//
//                            ForEach(uniqueIngredients.prefix(4), id: \.self) { name in
//                                HStack {
//                                    Circle()
//                                        .fill(Color.rd)
//                                        .frame(width: 10, height: 10)
//
//                                    Text(name.capitalized)
//                                }
//                            }
//                        }
//                        .padding()
//                        .background(Color.red.opacity(0.08))
//                        .cornerRadius(14)
                    VStack(spacing: 12) {

                        // ✅ العنوان الرئيسي
                        Text(
                            status == .contains ? "Contains Gluten ❌" :
                            status == .possible ? "May Contain Gluten ⚠️" :
                            status == .safe ? "Gluten-Free ✅" :
                            "Unknown ❓"
                        )
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(
                            status == .contains ? .rd :
                            status == .possible ? .orng :
                            status == .safe ? .grn :
                            .gry
                        )

                        // ✅ الوصف
                        Text(
                            status == .contains
                            ? "This product contains ingredients associated with gluten."
                            : status == .possible
                            ? "This product may contain gluten due to uncertain ingredients."
                            : status == .safe
                            ? "No gluten-related ingredients were detected."
                            : "The ingredients could not be identified with certainty."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                        // ✅ صندوق المكونات (يظهر فقط في حالتين)
                        if status == .contains || status == .possible {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(status == .contains
                                     ? "Detected Gluten Ingredients"
                                     : "Possibly Risky Ingredients")
                                    .font(.headline)
                                    .foregroundColor(
                                        status == .contains ? .rd.opacity(0.85) : .orng
                                    )

                                ForEach(uniqueIngredients.prefix(4), id: \.self) { name in
                                    HStack {
                                        Circle()
                                            .fill(status == .contains ? Color.rd : Color.orng)
                                            .frame(width: 10, height: 10)

                                        Text(name.capitalized)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                status == .contains
                                ? Color.rd.opacity(0.08)
                                : Color.orng.opacity(0.08)
                            )
                            .cornerRadius(14)
                        }

                        // ✅ رسالة تطمين للحالات الآمنة
                        if status == .safe {
                            Text("This product is safe for a gluten-free diet.")
                                .font(.footnote)
                                .foregroundColor(.grn.opacity(0.85))
                        }

                        // ✅ رسالة تحذير للحالة غير المعروفة
                        if status == .unknown {
                            Text("Please double-check the ingredients manually.")
                                .font(.footnote)
                                .foregroundColor(.gry)
                        }
                    }

                    
                    Button(action: onPost) {
                        Text("Post Result")
                            .frame(width: 180, height: 42)  // أعرض شوي
                            .fontWeight(.bold)
                            .foregroundStyle(Color(uiColor: .label))
                            .glassEffect(.clear.tint(Color.btn.opacity(0.9))) // ✅ نفس أسلوبك تمامًا
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.top, 12)
         
                }
                .padding(.horizontal)
                Spacer(minLength: 0) // ✅ فقط مسافة خفيفة قبل نهاية الكارد


            }

        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    var uniqueIngredients: [String] {
        Array(Set(ingredients.map { $0.name }))
    }
}
//#Preview("Contains Gluten") {
//    ResultView(
//        image: UIImage(systemName: "photo")!,
//        ingredients: [
//            GlutenIngredient(name: "wheat"),
//            GlutenIngredient(name: "barley"),
//            GlutenIngredient(name: "malt")
//        ],
//        status: .contains,
//        onClose: {},
//        onPost: {},
//    )
//}
//
//#Preview("Possible Gluten") {
//    ResultView(
//        image: UIImage(systemName: "photo")!,
//        ingredients: [
//            GlutenIngredient(name: "oats"),
//            GlutenIngredient(name: "soy sauce"),
//            GlutenIngredient(name: "modified starch")
//        ],
//        status: .possible,
//        onClose: {},
//        onPost: {},
//    )
//}
//
#Preview("Safe") {
    ResultView(
        image: UIImage(systemName: "photo")!,
        ingredients: [],
        status: .safe,
        onClose: {},
        onPost: {},
    )
}
//#Preview("Unknown") {
//    ResultView(
//        image: UIImage(systemName: "photo")!,
//        ingredients: [
//            GlutenIngredient(name: "sodium bicarbonate"),
//            GlutenIngredient(name: "citric acid"),
//            GlutenIngredient(name: "water")
//        ],
//        status: .unknown,
//        onClose: {},
//        onPost: {}
//    )
//}


