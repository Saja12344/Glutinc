////
////  GlutenResultView.swift
////  Glutinc
////
////  Created by saja khalid on 11/06/1447 AH.
////
//
//
//import SwiftUI
//
//struct GlutenResultView: View {
//    let image: UIImage
//    let ingredients: [GlutenIngredient]
//    let extractedText: String
//
//    var body: some View {
//        VStack(spacing: 0) {
//
//            // الصورة اللي تم التقاطها
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFit()
//                .frame(maxHeight: 350)
//
//            Divider()
//
//            // صندوق النتائج
//            VStack(alignment: .leading, spacing: 10) {
//                Text("نتيجة المسح")
//                    .font(.title2.bold())
//
//                if ingredients.isEmpty {
//                    Text("✔️ لا يوجد جلوتين")
//                        .font(.headline)
//                        .foregroundColor(.green)
//                } else {
//                    Text("⚠️ يحتوي على جلوتين")
//                        .font(.headline)
//                        .foregroundColor(.red)
//
//                    ForEach(ingredients, id: \.name) { item in
//                        Text("• \(item.name)")
//                            .foregroundColor(.red)
//                    }
//                }
//
//                Divider()
//                    .padding(.vertical, 8)
//
//                Text("النص المستخرج:")
//                    .font(.headline)
//
//                ScrollView {
//                    Text(extractedText)
//                        .font(.body)
//                        .padding(.bottom)
//                }
//
//            }
//            .padding()
//            .background(Color(.secondarySystemBackground))
//        }
//        .navigationTitle("نتيجة المسح")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
import SwiftUI

struct ResultView: View {
    let image: UIImage
    let ingredients: [GlutenIngredient]
//    @Binding var ingredients: [GlutenIngredient]
 
    var body: some View {
        VStack(spacing: 20) {

            // الصورة
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 350,height:300)
                .cornerRadius(12)
                .padding()

            // النتائج
            if ingredients.isEmpty {
                Text("Free gluten ✔️")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.top)
            } else {
                
                Text("Conatins gluten ⚠️")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)

                // قسم مكونات الغلوتين المكتشفة
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ingredients that were detected:")
                        .font(.headline)
                        .foregroundColor(.red)

                    ForEach(Array(Set(ingredients.map { $0.name })).prefix(3), id: \.self) { name in
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text(name.capitalized)
                                .font(.body)
                        }
                    }




                    
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Result")
    }
}
//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView(
//            image: UIImage(systemName: "photo")!, // صورة افتراضية من SF Symbols
//                     ingredients: [
//                         GlutenIngredient(name: "Wheat"),
//                         GlutenIngredient(name: "Barley")
//                     ]
//        )
//    }
//}

