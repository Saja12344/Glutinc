//////
//////  test.swift
//////  Glutinc22
//////
//////  Created by Norah Masoud Aloqayli on 17/06/1447 AH.
//////
////
////import SwiftUI
////
////struct Post: View {
////
////    @StateObject var cloudVM: UserCloudVM
//////    @ObservedObject var ProductM: ProductModel
////
////    // ✅ مدخلات الصفحة
////    @State private var productName = ""
////    @State private var price = ""
////    @State private var location = ""
////    @State private var amount = ""
////    @State private var isGlutenFree = false
////
////
////    var body: some View {
////        VStack(spacing: 20) {
////
////            TextField("Product Name", text: $productName)
////            TextField("Price", text: $amount)
////            TextField("Location", text: $location)
////
////            Toggle("Gluten Free", isOn: $isGlutenFree)
////
////            // ✅ زر النشر الحقيقي
////            Button("Publish") {
////                uploadProductToCloud()
////            }
////        }
////        .padding()
////    }
////
////    // ✅ الدالة الصحيحة للنشر
////    func uploadProductToCloud() {
////
////        let product = ProductModel(
////            id: UUID().uuidString,
////            productName: productName,
////            username: cloudVM.user.name,
////            rating: Double(cloudVM.rating),
////            isGlutenFree: isGlutenFree,
////            price: price,
////            location: location,
////            category: cloudVM.selectedCategory
////        )
////
////
////
////        cloudVM.uploadProduct(product)           // ✅ هذا هو الاستدعاء الصحيح
////    }
////}
////    var body: some View {
////        ZStack {
////            Color("Colorback")
////                .ignoresSafeArea()
////            
////            VStack(alignment: .leading, spacing: 20) {
////                
////                // زر العودة
////                HStack {
////                    ZStack {
////                        Capsule()
////                            .frame(width: 44, height: 44)
////                            .foregroundStyle(Color("GlassColor"))
////                            .glassEffect()
////                        
////                        Button {
////                            // action
////                        } label: {
////                            Image(systemName: "chevron.left")
////                                .foregroundColor(.black)
////                                .font(.system(size: 18.64, weight: .medium))
////                        }
////                    }
////                    Spacer()
////                }
////                .padding(.top, 20)
////                
////                HStack {
////                    Spacer()
////
////                    ZStack {
////                        RoundedRectangle(cornerRadius: 12)
////                            .fill(Color("Colorpost"))
////                            .frame(width: 147, height: 137)
////                        
////                        Button {
////                            // action
////                        } label: {
////                            Image(systemName: "plus")
////                                .foregroundColor(.black)
////                                .font(.system(size: 25, weight: .medium))
////                        }
////                    }
////
////                    Spacer()
////
////                }
////                
////                VStack(alignment: .leading, spacing: 8) {
////                    Text("How was your product?")
////                        .font(.system(size: 18, weight: .bold))
////                        .foregroundColor(.black)
////                    
////                    HStack(spacing: 10) {
////                        ForEach(1...5, id: \.self) { star in
////                            Image(systemName: "star.fill")
////                                .font(.system(size: 30))
////                                .foregroundColor(star <= vm.rating ? .yellow : .gray.opacity(0.4))
////                                .onTapGesture {
////                                    .updateRating(to: star)
////                                }
////                        }
////                    }
////                }
////                
////
////                VStack(alignment: .leading, spacing: 8) {
////                    Text("How much?")
////                        .font(.system(size: 18, weight: .bold))
////                        .foregroundColor(.black)
////                    
////                    TextField("Enter the price", text: $amount)
////                        .font(.system(size: 18))
////                            .padding(.horizontal, 10)
////                            .frame(height: 41)
////                            .background(Color.white)
////                            .cornerRadius(8)
////                            .shadow(radius: 1)
////                }
////                
////                VStack(alignment: .leading, spacing: 8) {
////                    Text("Location")
////                        .font(.system(size: 18, weight: .bold))
////                        .foregroundColor(.black)
////                    
////                    TextField("Enter the price", text: $amount)
////                        .font(.system(size: 18))
////                            .padding(.horizontal, 10)
////                            .frame(height: 41)
////                            .background(Color.white)
////                            .cornerRadius(8)
////                            .shadow(radius: 1)
////                }
////                
////                VStack(alignment: .leading, spacing: 8) {
////                    Text("Location")
////                        .font(.system(size: 18, weight: .bold))
////                        .foregroundColor(.black)
////                    
////                    TextField("Enter the price", text: $amount)
////                        .font(.system(size: 18))
////                            .padding(.horizontal, 10)
////                            .frame(height: 41)
////                            .background(Color.white)
////                            .cornerRadius(8)
////                            .shadow(radius: 1)
////                }
////                
////                VStack(alignment: .leading, spacing: 8) {
////                    Text("Category")
////                        .font(.system(size: 18, weight: .bold))
////                        .foregroundColor(.black)
////                    
////                    Menu {
////                        ForEach(vm.categories, id: \.self) { category in
////                            Button {
////                                vm.selectedCategory = category
////                            } label: {
////                                Text(category)
////                            }
////                        }
////                    } label: {
////                        HStack {
////                            Text(vm.selectedCategory.isEmpty ? "Select Category" : vm.selectedCategory)
////                                .foregroundColor(.gray)
////                            Spacer()
////                            Image(systemName: "chevron.down")
////                                .foregroundColor(.gray)
////                        }
////                        .padding()
////                        .frame(height: 41)
////                        .background(Color.white)
////                        .cornerRadius(8)
////                        .shadow(radius: 1)
////                    }
////                }
////                 
////                Button {
////                    uploadProductToCloud()
////                } label: {
////                    Text("Publish")
////                        .frame(width: 180, height: 42)
////                        .fontWeight(.bold)
////                        .foregroundStyle(Color(uiColor: .label))
////                        .glassEffect(.clear.tint(Color.btn.opacity(0.9)))
////                        .clipShape(RoundedRectangle(cornerRadius: 14))
////                }
////                .frame(maxWidth: .infinity)
////
////                
////                Spacer()
////            }
////            .padding(.horizontal, 20)
////        }
////    }
////
////
////
//import SwiftUI
//
//struct Post: View {
//
//    @ObservedObject var cloudVM: UserCloudVM   // ✅ الصحيح
//
//    // ✅ مدخلات الصفحة
//    @State private var productName = ""
//    @State private var price = ""
//    @State private var location = ""
//    @State private var isGlutenFree = false
//
//    var body: some View {
//        ZStack {
//            Color("Colorback")
//                .ignoresSafeArea()
//
//            VStack(alignment: .leading, spacing: 20) {
//
//                // ✅ زر العودة
//                HStack {
//                    ZStack {
//                        Capsule()
//                            .frame(width: 44, height: 44)
//                            .foregroundStyle(Color("GlassColor"))
//                            .glassEffect()
//
//                        Button {
//                            // dismiss هنا لاحقًا
//                        } label: {
//                            Image(systemName: "chevron.left")
//                                .foregroundColor(.black)
//                                .font(.system(size: 18.64, weight: .medium))
//                        }
//                    }
//                    Spacer()
//                }
//                .padding(.top, 20)
//
//                // ✅ الصورة
//                HStack {
//                    Spacer()
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color("Colorpost"))
//                            .frame(width: 147, height: 137)
//
//                        Button {
//                            // اختيار صورة لاحقًا
//                        } label: {
//                            Image(systemName: "plus")
//                                .foregroundColor(.black)
//                                .font(.system(size: 25, weight: .medium))
//                        }
//                    }
//                    Spacer()
//                }
//
//                // ✅ التقييم
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("How was your product?")
//                        .font(.system(size: 18, weight: .bold))
//
//                    HStack(spacing: 10) {
//                        ForEach(1...5, id: \.self) { star in
//                            Image(systemName: "star.fill")
//                                .font(.system(size: 30))
//                                .foregroundColor(
//                                    star <= cloudVM.rating
//                                    ? .yellow
//                                    : .gray.opacity(0.4)
//                                )
//                                .onTapGesture {
//                                    cloudVM.updateRating(to: star)
//                                    
//                                    
//                                    
//                                }
//                        }
//                    }
//                }
//
//                // ✅ اسم المنتج
//                TextField("Product Name", text: $productName)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(8)
//
//                // ✅ السعر
//                TextField("Enter the price", text: $price)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(8)
//
//                // ✅ الموقع
//                TextField("Location", text: $location)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(8)
//
//                // ✅ التصنيف
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Category")
//                        .font(.system(size: 18, weight: .bold))
//
//                    Menu {
//                        ForEach(cloudVM.categories, id: \.self) { category in
//                            Button {
//                                cloudVM.selectedCategory = category
//                            } label: {
//                                Text(category)
//                            }
//                        }
//                    } label: {
//                        HStack {
//                            Text(
//                                cloudVM.selectedCategory.isEmpty
//                                ? "Select Category"
//                                : cloudVM.selectedCategory
//                            )
//                            .foregroundColor(.gray)
//
//                            Spacer()
//
//                            Image(systemName: "chevron.down")
//                                .foregroundColor(.gray)
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(8)
//                    }
//                }
//
//                // ✅ غلوتن فري
//                Toggle("Gluten Free", isOn: $isGlutenFree)
//
//                // ✅ زر النشر
//                Button {
//                    uploadProductToCloud()
//                } label: {
//                    Text("Publish")
//                        .frame(width: 180, height: 42)
//                        .fontWeight(.bold)
//                        .foregroundStyle(Color(uiColor: .label))
//                        .glassEffect(.clear.tint(Color.btn.opacity(0.9)))
//                        .clipShape(RoundedRectangle(cornerRadius: 14))
//                }
//                .frame(maxWidth: .infinity)
//
//                Spacer()
//            }
//            .padding(.horizontal, 20)
//        }
//    }
//
//    // ✅ الدالة الصحيحة للنشر
//    func uploadProductToCloud() {
//
//        let product = ProductModel(
//            id: UUID().uuidString,
//            productName: productName,
//            username: cloudVM.user.name,
//            rating: Double(cloudVM.rating),
//            isGlutenFree: isGlutenFree,
//            price: price,
//            location: location,
//            category: cloudVM.selectedCategory
//        )
//
//        cloudVM.uploadProduct(product) 
//    }
//}
import SwiftUI
import PhotosUI

struct Post: View {

    @ObservedObject var cloudVM: UserCloudVM
    @Environment(\.dismiss) private var dismiss

    // ✅ القيم القادمة من ResultView
    let isGlutenFree: Bool   // ✅ جاية جاهزة بدون اختيار المستخدم

    // ✅ مدخلات الصفحة
    @State private var productName = ""
    @State private var price = ""
    @State private var location = ""

    // ✅ الصورة من الكاميرا
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        ZStack {
            Color("Colorback")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {

                // ✅ زر الرجوع
                HStack {
                    ZStack {
                        Capsule()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(Color("GlassColor"))
                            .glassEffect()

                        Button {
                            // dismiss لاحقًا إذا حبيتي
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white) // ✅ أبيض
                                .font(.system(size: 18.64, weight: .medium))
                        }
                    }
                    Spacer()
                }
                .padding(.top, 20)

                // ✅ مربع الصورة (كاميرا)
                HStack {
                    Spacer()

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 1.2) // ✅ ستروك أبيض
                                .frame(width: 147, height: 137)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color("Colorpost"))
                                )

                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 147, height: 137)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                Image(systemName: "camera.fill") // ✅ كاميرا بدل +
                                    .foregroundColor(.white)
                                    .font(.system(size: 26, weight: .medium))
                            }
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                    }

                    Spacer()
                }

                // ✅ التقييم
                VStack(alignment: .leading, spacing: 8) {
                    Text("How was your product?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: "star.fill")
                                .font(.system(size: 30))
                                .foregroundColor(
                                    star <= cloudVM.rating
                                    ? .yellow
                                    : .gray.opacity(0.4)
                                )
                                .onTapGesture {
                                    cloudVM.updateRating(to: star)
                                }
                        }
                    }
                }

                // ✅ حقول الإدخال (بستروك أبيض)
                glassTextField("Product Name", text: $productName)
                glassTextField("Enter the price", text: $price)
                glassTextField("Location", text: $location)

                // ✅ Category
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Menu {
                        ForEach(cloudVM.categories, id: \.self) { category in
                            Button {
                                cloudVM.selectedCategory = category
                            } label: {
                                Text(category)
                            }
                        }
                    } label: {
                        HStack {
                            Text(
                                cloudVM.selectedCategory.isEmpty
                                ? "Select Category"
                                : cloudVM.selectedCategory
                            )
                            .foregroundColor(.white.opacity(0.7))

                            Spacer()

                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 1.2)
                        )
                    }
                }

                // ✅ زر النشر
                Button {
                    uploadProductToCloud()
                    dismiss()   // ✅ يرجّعك تلقائيًا لصفحة المين (Home)
                } label: {
                    Text("Publish")
                        .frame(width: 180, height: 42)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .glassEffect(.clear.tint(Color.btn.opacity(0.9)))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .frame(maxWidth: .infinity)


                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    // ✅ TextField بنفس ثيمكم
    @ViewBuilder
    private func glassTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 1.2)
            )
    }

    // ✅ الدالة النهائية للنشر (تستخدم isGlutenFree الجاية من ResultView)
    func uploadProductToCloud() {

        let product = ProductModel(
            id: UUID().uuidString,
            productName: productName,
            username: cloudVM.user.name,
            rating: Double(cloudVM.rating),
            isGlutenFree: isGlutenFree,   // ✅ جاية من الريزولت
            price: price,
            location: location,
            category: cloudVM.selectedCategory
        )

        cloudVM.uploadProduct(product)
    }
}
