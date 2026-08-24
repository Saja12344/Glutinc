
import SwiftUI
import PhotosUI
import MapKit   // لو حابة تطوريه لاحقًا للبحث الحقيقي

struct Post: View {
    
    @EnvironmentObject var cloudVM: UserCloudVM
    @Binding var selectedTab: HomeTab   // ⬅️
    @Environment(\.dismiss) private var dismiss

    // ✅ القيمة الجاية من ResultView
    let isGlutenFree: Bool
    
    // ✅ مدخلات الصفحة (required)
    @State private var productName = ""
    @State private var price = ""
    @State private var location = ""
    @State private var selectedCategory: String = ""
    
    // ✅ اختياري (optional)
    @State private var notes = ""
    @State private var productURL = ""
    
    // ✅ الصورة من PhotosPicker
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    // ✅ حالة الفاليديشن / النشر
    @State private var showValidation = false
    @State private var isSubmitting = false
    
    // ✅ شاشة اختيار اللوكيشن (لو حبيتي تطوريها لاحقًا)
    @State private var showLocationSearch = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var showImageOptions = false
    @State private var showCamera = false
    // ✅ كل الحقول المطلوبة
    private var isFormValid: Bool {
        selectedImage != nil &&
        !productName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !price.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedCategory.isEmpty &&
        cloudVM.rating > 0
    }
//    let ingredients: [GlutenIngredient]
    var detectedIngredientNames: [String]

    var body: some View {
        NavigationStack {
            ZStack {
                // ✅ الخلفية المتفق عليها
                Color(colorScheme == .dark ? .black : .white)
                    .ignoresSafeArea()
                
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.48, blue: 0.95)
                            .opacity(colorScheme == .dark ? 0.35 : 0.55),
                        Color.clear
                    ],
                    startPoint: .topTrailing,
                    endPoint: .center
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - صورة المنتج
                        // MARK: - صورة المنتج (من الألبوم فقط)
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .frame(height: 200)

                                if let selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                } else {
                                    VStack(spacing: 10) {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.system(size: 30, weight: .medium))
                                        Text("Add product photo")
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            guard let newItem else { return }
                            Task {
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image
                                }
                            }
                        }

                        
                        
                        // MARK: - Rating
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How was your product?")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 10) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(
                                            star <= cloudVM.rating
                                            ? .yellow
                                            : .gray.opacity(0.3)
                                        )
                                        .onTapGesture {
                                            cloudVM.updateRating(to: star)
                                        }
                                }
                            }
                            
                            if showValidation && cloudVM.rating == 0 {
                                Text("Please rate the product.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // MARK: - Product Name
                        glassTextField("Product Name", text: $productName)
                            .foregroundColor(.primary)
                            .formField(
                                isInvalid: showValidation && productName.trimmingCharacters(in: .whitespaces).isEmpty,
                                isEditing: !productName.isEmpty
                            )
                        
                        
                        // MARK: - Price
                        glassTextField("Enter the price", text: $price, keyboardType: .decimalPad)
                            .foregroundColor(.primary)
                            .formField(
                                isInvalid: showValidation && price.trimmingCharacters(in: .whitespaces).isEmpty,
                                isEditing: !price.isEmpty
                            )
                        
                        
                        // MARK: - Location (بحث يشبه لوكت/سناب)
                        Button {
                            showLocationSearch = true
                        } label: {
                            HStack {
                                Text(location.isEmpty ? "Search location" : location)
                                    .font(.body)
                                    .foregroundColor(location.isEmpty ? .secondary : .primary)
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                        .formField(
                            isInvalid: showValidation && location.trimmingCharacters(in: .whitespaces).isEmpty,
                            isEditing: !location.isEmpty
                        )
                        
                        
                        
                        // MARK: - Category
                        VStack(alignment: .leading, spacing: 8) {
                            
                            
                            Menu {
                                ForEach(cloudVM.categories, id: \.self) { category in
                                    Button {
                                        selectedCategory = category
                                        cloudVM.selectedCategory = category
                                    } label: {
                                        Text(category)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCategory.isEmpty ? "Select Category" : selectedCategory)
                                        .foregroundColor(selectedCategory.isEmpty ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            }
                            
                            if showValidation && selectedCategory.isEmpty {
                                validationText("Category is required.")
                            }
                        }
                        
                        // MARK: - Optional: Notes
                        TextField(
                            "Add any extra notes here…",
                            text: $notes,
                            axis: .vertical
                        )
                        .lineLimit(2...4)
                        .font(.body)
                        .foregroundColor(.primary)
                        .formField(
                            isInvalid: false,
                            isEditing: !notes.isEmpty
                        )
                        
                        
                        
                        
                        // MARK: - Optional: Product URL
                        VStack(alignment: .leading, spacing: 4) {
                            glassTextField("Product link (optional)", text: $productURL, keyboardType: .URL)
                        }
                        
                        // MARK: - Publish Button
                        Button {
                            showValidation = true
                            guard isFormValid else { return }
                            
                            isSubmitting = true
                            
                            uploadProductToCloud { success in
                                isSubmitting = false
                                
                                if success {
                                    selectedTab = .wheat   // ✅ يروح للهوم
                                } else {
                                    print("❌ فشل حفظ المنتج")
                                }
                            }
                            
                        } label: {
                            Text(isSubmitting ? "Publishing..." : "Publish")
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(isFormValid ? Color.accentColor : Color.gray.opacity(0.4))
                                )
                        }
                        .disabled(!isFormValid || isSubmitting)
                        .padding(.top, 8)
                        
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLocationSearch) {
                // شاشة بسيطة مؤقتًا – تقدري تطوريها لاحقًا للبحث الحقيقي
                SimpleLocationSearchView(selectedLocation: $location)
            }
            .sheet(isPresented: $showCamera) {   // 🟢🟢🟢 هنا بالضبط
                         CameraView(
                             cloudVM: cloudVM,
                             selectedTab: $selectedTab
                         )
                     }
                 }   // 🔚 نهاية NavigationStack
        
        
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)

            
        
    }
    
    // MARK: - TextField بنفس ثيم النظام
    @ViewBuilder
    private func glassTextField(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .padding()
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
    }
    
    // MARK: - نص الفاليديشن
    private func validationText(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.red)
    }
    
    // MARK: - النشر (أضفت notes + productURL لو حبيتي)
    func uploadProductToCloud(completion: @escaping (Bool) -> Void) {
        guard let ownerID = cloudVM.userRecordID else {
            print("❌ No userRecordID – cannot upload product")
            completion(false)
            return
        }


        print("🆔 Uploading with ownerID:", ownerID)

        guard let image = selectedImage else {
            print("❌ Image is required")
            completion(false)
            return
        }

        let product = ProductModel(
            id: UUID().uuidString,
            productName: productName,
            username: cloudVM.user.name,
            rating: Double(cloudVM.rating),
            isGlutenFree: isGlutenFree,
            price: price,
            location: location,
            category: selectedCategory,
            detectedIngredients: detectedIngredientNames,
            notes: notes.isEmpty ? nil : notes,
            productURL: productURL.isEmpty ? nil : productURL,
            image: image,
            ownerAppleID: ownerID
        )


        cloudVM.uploadProduct(product, completion: completion)
    }


    //}
    struct SimpleLocationSearchView: View {
        @Environment(\.dismiss) private var dismiss
        @Binding var selectedLocation: String
        @State private var query: String = ""
        
        var body: some View {
            NavigationStack {
                VStack {
                    TextField("Search location…", text: $query)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .padding()
                    
                    // مؤقت: لما يضغط Save نخلي القيمة اللي كتبها هي اللوكيشن
                    Spacer()
                    
                    Button {
                        if !query.trimmingCharacters(in: .whitespaces).isEmpty {
                            selectedLocation = query
                        }
                        dismiss()
                    } label: {
                        Text("Save location")
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.accentColor)
                            )
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .navigationTitle("Location")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
}
extension View {
    func formField(isInvalid: Bool, isEditing: Bool) -> some View {
        self.modifier(FormFieldStyle(isInvalid: isInvalid, isEditing: isEditing))
    }
}
struct FormFieldStyle: ViewModifier {

    let isInvalid: Bool
    let isEditing: Bool

    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.5)
            )
    }

    private var borderColor: Color {
        if isInvalid {
            return .red
        }
        if isEditing {
            return .yellow
        }
        return Color.white.opacity(0.2)
    }
}
