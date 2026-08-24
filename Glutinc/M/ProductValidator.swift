import Foundation
import UIKit
import Vision

struct ProductEvidence {
    var barcode: String?
    var extractedText: String
    var hasIngredientList: Bool
    var hasNutritionLabel: Bool
    var hasPackagingKeywords: Bool
    var recognizedIngredientCount: Int

    var isLikelyFoodProduct: Bool {
        if barcode != nil { return true }
        if hasIngredientList { return true }
        if hasNutritionLabel { return true }
        return hasPackagingKeywords && recognizedIngredientCount >= 2
    }

    var isStrongEvidence: Bool {
        barcode != nil || (hasIngredientList && recognizedIngredientCount >= 3)
    }

    var rejectionMessage: String {
        L10n.t(
            "We couldn't identify a food product in this image.\n\nPlease upload a clear photo of the product packaging, barcode, or ingredient label.",
            ar: "تعذر التعرّف على منتج غذائي في هذه الصورة.\n\nيرجى رفع صورة واضحة لعبوة المنتج أو الباركود أو قائمة المكونات."
        )
    }
}

enum ProductValidator {
    static func detectBarcodes(in image: UIImage) -> [String] {
        guard let cgImage = image.cgImage else { return [] }
        let orientation = image.imageOrientation.glutincCGImageOrientation
        let request = VNDetectBarcodesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        try? handler.perform([request])
        let payloads = (request.results ?? []).compactMap { $0.payloadStringValue }
        return Array(Set(payloads.filter { $0.count >= 6 }))
    }

    static func evidence(
        image: UIImage,
        extractedText: String,
        analysis: ScanAnalysisResult,
        knownBarcodes: [String] = []
    ) -> ProductEvidence {
        let barcodes = knownBarcodes.isEmpty ? detectBarcodes(in: image) : knownBarcodes
        let en = ScanAnalyzer.normalizeEnglish(extractedText)
        let ar = ScanAnalyzer.normalizeArabic(extractedText)

        let hasIngredients = analysis.ingredientSectionFound
            || en.contains("ingredient")
            || ar.contains("مكون")
        let recognized = analysis.parsedIngredients.count
        let hasNutrition = en.contains("nutrition")
            || en.contains("calories")
            || en.contains("kcal")
            || en.contains("serving size")
            || ar.contains("تغذ")
            || ar.contains("سعرات")
        let hasPackaging = en.contains("net wt")
            || en.contains("best before")
            || en.contains("expir")
            || en.contains("barcode")
            || ar.contains("وزن صافي")
            || ar.contains("تاريخ")
            || extractedText.range(of: #"\d{8,14}"#, options: .regularExpression) != nil

        return ProductEvidence(
            barcode: barcodes.first,
            extractedText: extractedText,
            hasIngredientList: hasIngredients,
            hasNutritionLabel: hasNutrition,
            hasPackagingKeywords: hasPackaging,
            recognizedIngredientCount: recognized
        )
    }

    static func normalizedName(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\u0600-\\u06FF]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func existingMatch(
        barcode: String?,
        name: String,
        in products: [ProductModel]
    ) -> ProductModel? {
        if let barcode, !barcode.isEmpty {
            if let match = products.first(where: { $0.barcode == barcode }) {
                return match
            }
        }
        let target = normalizedName(name)
        guard target.count >= 4 else { return nil }
        return products.first { normalizedName($0.productName) == target }
    }
}
