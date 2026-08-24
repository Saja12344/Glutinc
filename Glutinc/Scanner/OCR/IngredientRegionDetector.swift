import Foundation
import CoreGraphics

/// Locates the ingredient declaration and drops unrelated packaging / browser chrome.
enum IngredientRegionDetector {
    static let englishHeaders = [
        "ingredients:", "ingredients", "ingredient:", "ingredient",
        "ingredlents", "lngredients", "ingredents"
    ]

    static let arabicHeaders = [
        "المكونات:", "المكونات", "مكونات:", "مكونات",
        "المقادير:", "المقادير", "مقادير:", "مقادير"
    ]

    static func detect(in text: String) -> IngredientSection {
        IngredientParser.detectSection(in: text)
    }

    static func observationsInIngredientRegion(
        _ observations: [OCRTextObservation]
    ) -> [OCRTextObservation] {
        guard !observations.isEmpty else { return [] }
        if let header = observations.first(where: { isIngredientHeader($0.text) }) {
            let minY = header.boundingBox.minY - 0.02
            return observations.filter { obs in
                obs.boundingBox.midY <= header.boundingBox.midY + 0.55
                    && obs.boundingBox.maxY >= minY
                    && !isPackagingNoise(obs.text)
            }
        }
        return observations.filter { !isPackagingNoise($0.text) }
    }

    static func isIngredientHeader(_ text: String) -> Bool {
        let key = ScanTextNormalizer.matchingKey(text)
        for header in englishHeaders + arabicHeaders {
            let needle = ScanTextNormalizer.matchingKey(header)
            if key == needle || key.hasPrefix(needle) { return true }
            if ScanTextNormalizer.levenshtein(key, needle) == 1 && needle.count >= 8 {
                return true
            }
        }
        return false
    }

    static func isPackagingNoise(_ text: String) -> Bool {
        let key = ScanTextNormalizer.matchingKey(text)
        let noise = [
            "nutrition facts", "nutrition declaration", "nutritional information",
            "calories", "energy drink", "best served", "barcode",
            "directions", "warning", "distributed by", "net wt", "ml",
            "vitalizes", "body and mind", "google", "search", "add to cart",
            "price", "sar", "usd", "share", "follow"
        ]
        if noise.contains(where: { key == ScanTextNormalizer.matchingKey($0) || key.hasPrefix(ScanTextNormalizer.matchingKey($0)) }) {
            return true
        }
        if key.allSatisfy(\.isNumber) && key.count >= 8 { return true }
        return false
    }
}
