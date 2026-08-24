
import SwiftUI
import PhotosUI
import MapKit   // لو حابة تطوريه لاحقًا للبحث الحقيقي

struct Post: View {
    
    @EnvironmentObject var cloudVM: UserCloudVM
    @Binding var selectedTab: HomeTab   // ⬅️
    @Environment(\.dismiss) private var dismiss

    // ✅ القيمة الجاية من ResultView
    let isGlutenFree: Bool
    var detectedIngredientNames: [String]
    var analysisStatus: ScanAnalysisStatus = .noneDetected
    var manufacturerWarnings: [String] = []
    var initialImage: UIImage? = nil
    var barcode: String? = nil
    var ingredientText: String = ""
    var evidence: ProductEvidence? = nil
    
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
    @State private var submitMessage: String?
    @State private var existingMatch: ProductModel?
    
    // ✅ شاشة اختيار اللوكيشن (لو حبيتي تطوريها لاحقًا)
    @State private var showLocationSearch = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var showImageOptions = false
    @State private var showCamera = false
    // ✅ كل الحقول المطلوبة
    private var isFormValid: Bool {
        selectedImage != nil &&
        !productName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedCategory.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
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
                                Text(location.isEmpty ? L10n.t("Found at (optional)", ar: "تم العثور عليه في (اختياري)") : location)
                                    .font(.body)
                                    .foregroundColor(location.isEmpty ? .secondary : .primary)
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                        .formField(
                            isInvalid: false,
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
                        
                        Text(L10n.t(
                            "Community content is shared by users and is not medical advice.",
                            ar: "محتوى المجتمع يشاركه المستخدمون ولا يُعد استشارة طبية."
                        ))
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)

                        // MARK: - Publish Button
                        Button {
                            showValidation = true
                            guard isFormValid else { return }
                            
                            isSubmitting = true
                            
                            uploadProductToCloud { success in
                                isSubmitting = false
                                if success {
                                    selectedTab = .wheat
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

                        Text(L10n.t(
                            "Submissions start as pending. Explore only shows verified products with no gluten ingredients detected.",
                            ar: "تبدأ الطلبات بحالة انتظار. تظهر في Explore فقط المنتجات الموثّقة التي لم يُكتشف فيها غلوتين."
                        ))
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)

                        if let submitMessage {
                            Text(submitMessage)
                                .font(.footnote)
                                .foregroundStyle(AppColors.warning)
                        }
                        
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
        
        
            .onAppear {
                if selectedImage == nil {
                    selectedImage = initialImage
                }
            }

            
        
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
            completion(false)
            return
        }
        guard let image = selectedImage else {
            completion(false)
            return
        }

        let evidence = self.evidence ?? ProductValidator.evidence(
            image: image,
            extractedText: ingredientText,
            analysis: ScanAnalyzer.analyze(text: ingredientText, ocrConfidence: nil),
            knownBarcodes: barcode.map { [$0] } ?? []
        )

        guard evidence.isLikelyFoodProduct else {
            submitMessage = evidence.rejectionMessage
            completion(false)
            return
        }

        if let match = ProductValidator.existingMatch(
            barcode: evidence.barcode ?? barcode,
            name: productName,
            in: cloudVM.products
        ) {
            existingMatch = match
            submitMessage = L10n.t(
                "This product already exists. A duplicate listing was not created.",
                ar: "هذا المنتج موجود مسبقًا. لم يُنشأ سجل مكرر."
            )
            completion(false)
            return
        }

        let gluten = analysisStatus.catalogGlutenStatus
        var verification: VerificationStatus = .pending
        var verifiedBy: String? = nil
        var verifiedAt: Date? = nil
        if evidence.isStrongEvidence && gluten == .noGlutenDetected {
            verification = .verified
            verifiedBy = "auto"
            verifiedAt = Date()
        } else if gluten == .noGlutenDetected {
            verification = .needsReview
        }

        let product = ProductModel(
            id: UUID().uuidString,
            productName: productName,
            username: cloudVM.user.name,
            rating: Double(cloudVM.rating),
            isGlutenFree: gluten == .noGlutenDetected,
            price: price,
            location: location,
            category: selectedCategory,
            detectedIngredients: detectedIngredientNames,
            notes: notes.isEmpty ? nil : notes,
            productURL: productURL.isEmpty ? nil : productURL,
            image: image,
            ownerAppleID: ownerID,
            analysisStatusRaw: analysisStatus.rawValue,
            createdAt: Date(),
            dataSource: "community",
            manufacturerWarnings: manufacturerWarnings,
            lastVerifiedAt: verifiedAt,
            barcode: evidence.barcode ?? barcode,
            ingredientText: ingredientText.isEmpty ? nil : ingredientText,
            verificationStatusRaw: verification.rawValue,
            glutenAnalysisStatusRaw: gluten.rawValue,
            verifiedBy: verifiedBy,
            ingredientCount: evidence.recognizedIngredientCount
        )

        cloudVM.submitCatalogProduct(product) { success, message in
            if let message {
                submitMessage = message
            }
            completion(success)
        }
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
