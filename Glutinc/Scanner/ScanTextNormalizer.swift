import Foundation

enum ScanTextNormalizer {

    /// Matching key only. Do not show this string as OCR output.
    static func matchingKey(_ text: String) -> String {
        collapseWhitespace(normalizeArabicLetters(text.lowercased()))
    }

    static func tokens(_ text: String) -> [String] {
        let key = matchingKey(text)
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "’", with: "")
            .replacingOccurrences(of: "ʻ", with: "")
            .replacingOccurrences(of: "[()\\[\\]{}（）]", with: " ", options: .regularExpression)
        let parts = key.split { ch in
            ch.isWhitespace || ch == "," || ch == "،" || ch == ";" || ch == "؛" || ch == ":" || ch == "："
        }
        return parts.map { stripArabicArticle(String($0)) }.filter { !$0.isEmpty }
    }

    /// Arabic matching normalization. Display text must stay original.
    static func normalizeArabic(_ text: String) -> String {
        normalizeArabicLetters(text)
    }

    /// Light English cleanup used by packaging heuristics. Matching uses `tokens`.
    static func normalizeEnglish(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "[()\\[\\]{}]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "[^a-z0-9,\\s-]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func collapseWhitespace(_ text: String) -> String {
        text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func letterCount(_ text: String) -> Int {
        text.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
    }

    static func containsArabic(_ text: String) -> Bool {
        text.unicodeScalars.contains { CharacterSet(charactersIn: "\u{0600}"..."\u{06FF}").contains($0) }
    }

    static func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr), b = Array(bStr)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                dist[i][j] = min(
                    dist[i - 1][j] + 1,
                    dist[i][j - 1] + 1,
                    dist[i - 1][j - 1] + cost
                )
            }
        }
        return dist[a.count][b.count]
    }

    private static func normalizeArabicLetters(_ text: String) -> String {
        var scalars: [Unicode.Scalar] = []
        scalars.reserveCapacity(text.unicodeScalars.count)
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 0x064B...0x0652, 0x0670, 0x0640, 0x0610...0x061A, 0x06D6...0x06ED:
                continue
            case 0x0622, 0x0623, 0x0625, 0x0671:
                scalars.append(Unicode.Scalar(0x0627)!)
            case 0x0649:
                scalars.append(Unicode.Scalar(0x064A)!)
            case 0x0629:
                scalars.append(Unicode.Scalar(0x0647)!)
            default:
                scalars.append(scalar)
            }
        }
        return String(String.UnicodeScalarView(scalars))
    }

    private static func stripArabicArticle(_ token: String) -> String {
        if token.hasPrefix("ال") && token.count > 3 {
            return String(token.dropFirst(2))
        }
        return token
    }
}
