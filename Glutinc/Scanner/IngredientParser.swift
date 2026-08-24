import Foundation

struct ParsedIngredient: Hashable {
    let originalText: String
    let isNested: Bool
}

struct IngredientSection {
    let found: Bool
    let header: String?
    let text: String
}

enum IngredientParser {
    static func detectSection(in text: String) -> IngredientSection {
        let collapsed = text.replacingOccurrences(of: "\r\n", with: "\n")
        let englishHeaders = IngredientRegionDetector.englishHeaders
        let arabicHeaders = IngredientRegionDetector.arabicHeaders

        let lower = collapsed.lowercased()
        for header in englishHeaders {
            if let range = lower.range(of: header) {
                var body = String(collapsed[range.upperBound...])
                if let stop = firstStopIndex(in: body) {
                    body = String(body[..<stop])
                }
                return IngredientSection(
                    found: true,
                    header: header,
                    text: body.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        }

        let arabicKey = ScanTextNormalizer.matchingKey(collapsed)
        for header in arabicHeaders {
            let needle = ScanTextNormalizer.matchingKey(header)
            if let range = arabicKey.range(of: needle) {
                var body = String(arabicKey[range.upperBound...])
                if let stop = firstStopIndex(in: body) {
                    body = String(body[..<stop])
                }
                return IngredientSection(
                    found: true,
                    header: header,
                    text: body.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            if let range = collapsed.range(of: header) {
                var body = String(collapsed[range.upperBound...])
                if let stop = firstStopIndex(in: body) {
                    body = String(body[..<stop])
                }
                return IngredientSection(
                    found: true,
                    header: header,
                    text: body.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        }

        return IngredientSection(found: false, header: nil, text: collapsed)
    }

    static func looksLikeIngredientList(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return false }
        if detectSection(in: trimmed).found { return true }
        let separators = trimmed.filter { $0 == "," || $0 == "،" }.count
        if separators >= 1 { return true }
        let tokens = ScanTextNormalizer.tokens(trimmed)
        return tokens.count >= 1 && ScanTextNormalizer.letterCount(trimmed) >= 3
    }

    static func parse(_ text: String) -> [ParsedIngredient] {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return [] }

        var topLevel: [String] = []
        var current = ""
        var depth = 0
        for ch in cleaned {
            if ch == "(" || ch == "[" || ch == "{" || ch == "（" {
                depth += 1
                current.append(ch)
            } else if ch == ")" || ch == "]" || ch == "}" || ch == "）" {
                depth = max(0, depth - 1)
                current.append(ch)
            } else if depth == 0 && (ch == "," || ch == "،" || ch == ";" || ch == "؛") {
                let piece = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !piece.isEmpty { topLevel.append(piece) }
                current = ""
            } else {
                current.append(ch)
            }
        }
        let last = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !last.isEmpty { topLevel.append(last) }

        var result: [ParsedIngredient] = []
        for item in topLevel {
            result.append(ParsedIngredient(originalText: stripTrailingPeriod(item), isNested: false))
            for nested in nestedPieces(in: item) {
                result.append(ParsedIngredient(originalText: nested, isNested: true))
            }
        }
        return result.filter { ScanTextNormalizer.letterCount($0.originalText) >= 2 }
    }

    private static func nestedPieces(in text: String) -> [String] {
        var pieces: [String] = []
        var rest = text
        while let start = rest.firstIndex(where: { $0 == "(" || $0 == "[" || $0 == "{" }) {
            let open = rest[start]
            let close: Character = open == "(" ? ")" : open == "[" ? "]" : "}"
            guard let end = rest[start...].firstIndex(of: close) else { break }
            let innerStart = rest.index(after: start)
            if innerStart < end {
                let inner = String(rest[innerStart..<end])
                pieces.append(contentsOf: parse(inner).map(\.originalText))
            }
            rest = String(rest[rest.index(after: end)...])
        }
        return pieces
    }

    private static func stripTrailingPeriod(_ text: String) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        while t.last == "." || t.last == ":" { t.removeLast() }
        return t.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func firstStopIndex(in body: String) -> String.Index? {
        let lower = body.lowercased()
        let arabic = ScanTextNormalizer.normalizeArabic(body)
        let stops = [
            "nutrition facts", "nutrition declaration", "nutritional information",
            "calories", "energy drink", "serving size", "protein:", "allergen information",
            "best served", "directions", "storage", "distributed by"
        ]
        var best: String.Index?
        for stop in stops {
            if let r = lower.range(of: stop) {
                if best == nil || r.lowerBound < best! { best = r.lowerBound }
            }
        }
        let arStops = ["حقائق تغذ", "القيمة الغذائية", "سعرات", "الطاقة"]
        for stop in arStops {
            if let r = arabic.range(of: ScanTextNormalizer.normalizeArabic(stop)) {
                let idx = body.index(body.startIndex, offsetBy: arabic.distance(from: arabic.startIndex, to: r.lowerBound))
                if best == nil || idx < best! { best = idx }
            }
        }
        return best
    }
}
