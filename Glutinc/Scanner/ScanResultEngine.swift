import Foundation

enum ScanResultEngine {
    static func analyze(
        text: String,
        source: ScanTextSource,
        observations: [OCRTextObservation] = [],
        ocrConfidence: Double? = nil,
        policy: OCRConfidencePolicy = .standard
    ) -> ScanAnalysisResult {
        let original = text
        let ocrAssess = OCRQualityEvaluator.assess(
            text: original,
            observations: observations,
            source: source,
            policy: policy
        )

        if ocrAssess.skipClassification {
            #if DEBUG
            print("[GlutincScan] OCR gate rejected classification reason=\(ocrAssess.reason)")
            #endif
            return ScanAnalysisResult(
                status: .unreadableIngredients,
                extractedText: original,
                glutenHits: [],
                ambiguousHits: [],
                manufacturerWarnings: [],
                recognizedNonGluten: [],
                ocrConfidence: ocrConfidence,
                originalOCRText: original,
                parsedIngredients: [],
                unknownHits: [],
                possibleOCRHits: [],
                allergenDeclarations: [],
                glutenFreeClaims: [],
                reviewReasons: [],
                scanQuality: .poor,
                ingredientSectionFound: ocrAssess.headerFound,
                tooSmallForOCR: ocrAssess.tooSmall,
                skippedClassification: true
            )
        }

        let statements = LabelStatementDetector.detect(in: original)
        let allergenHits = statements.filter { $0.kind == .allergenDeclaration && $0.mentionsGlutenAllergen }
        let crossContact = statements.filter { $0.kind == .crossContactWarning }
        let claims = statements.filter { $0.kind == .glutenFreeClaim }.map(\.originalText)

        let section = IngredientParser.detectSection(in: original)
        let maskedFull = LabelStatementDetector.maskNonIngredientSpans(original)
        let maskedSection = LabelStatementDetector.maskNonIngredientSpans(section.text)
        let workingText = section.found ? maskedSection : maskedFull

        let parsed = IngredientParser.parse(workingText)
        let classified = parsed.map { item in
            let low = isLowConfidence(item.originalText, observations: observations, policy: policy)
            return IngredientMatcher.classify(item, lowOCRConfidence: low)
        }

        let glutenIngredients = classified.filter { $0.classification == .containsGluten }
        let ambiguous = classified.filter { $0.classification == .ambiguous }
        let unknown = classified.filter { $0.classification == .unknown }
        let knownSafe = classified.filter { $0.classification == .noKnownGluten }
        let possibleOCR = classified.filter { $0.possibleMatch != nil }
        let lowConf = classified.filter(\.lowOCRConfidence)

        let looksLikeList = IngredientParser.looksLikeIngredientList(original) || section.found
        let letterCount = ScanTextNormalizer.letterCount(original)
        let observationQuality = observationScanQuality(observations, policy: policy, source: source)

        let confirmedGluten = !glutenIngredients.isEmpty || !allergenHits.isEmpty

        var reasons: [ScanReviewReason] = []
        if !ambiguous.isEmpty { reasons.append(.ambiguousIngredients) }
        if !unknown.isEmpty { reasons.append(.unknownIngredients) }
        if !lowConf.isEmpty || observationQuality == .poor { reasons.append(.unreadableText) }
        if observationQuality == .partial || ocrAssess.quality == .partial { reasons.append(.partialRead) }
        if !crossContact.isEmpty { reasons.append(.crossContactWarning) }
        if !possibleOCR.isEmpty { reasons.append(.possibleOCRIssue) }
        if classified.contains(where: { $0.category == .oats }) { reasons.append(.oatsNeedVerification) }
        if !section.found && source != .userEdited && letterCount > 40 && !looksLikeList {
            reasons.append(.noIngredientSection)
        }
        if source != .userEdited && !looksLikeList && glutenIngredients.isEmpty && allergenHits.isEmpty {
            reasons.append(.notIdentifiedAsIngredients)
        }

        let quality: ScanQuality
        if source == .userEdited {
            quality = (unknown.isEmpty && lowConf.isEmpty) ? .good : .partial
        } else if ocrAssess.quality == .partial {
            quality = .partial
        } else if observationQuality == .poor || letterCount < 3 {
            quality = .poor
        } else if !section.found && classified.count < 2 && glutenIngredients.isEmpty && allergenHits.isEmpty {
            quality = letterCount < 12 ? .poor : observationQuality
        } else {
            quality = (reasons.contains(.unreadableText) || reasons.contains(.partialRead) || !unknown.isEmpty)
                ? .partial
                : (observationQuality == .good || observations.isEmpty ? .good : observationQuality)
        }

        var status: ScanAnalysisStatus
        if letterCount == 0 {
            status = .unverifiable
        } else if confirmedGluten {
            status = .glutenDetected
        } else if quality == .poor && glutenIngredients.isEmpty && allergenHits.isEmpty && classified.isEmpty {
            status = .unreadableIngredients
        } else if !reasons.isEmpty || quality != .good || classified.isEmpty || !unknown.isEmpty || !ambiguous.isEmpty || !crossContact.isEmpty || !possibleOCR.isEmpty || !lowConf.isEmpty {
            status = .reviewRecommended
        } else if classified.allSatisfy({ $0.classification == .noKnownGluten }) && looksLikeList {
            status = .noneDetected
        } else {
            status = .reviewRecommended
        }

        if ocrAssess.quality == .partial && status == .noneDetected {
            status = .reviewRecommended
        }

        #if DEBUG
        ScanDiagnostics.log(
            original: original,
            section: section,
            classified: classified,
            statements: statements,
            status: status,
            quality: quality
        )
        #endif

        let glutenFromIngredients = canonicalNames(
            from: glutenIngredients.map(\.originalText),
            matching: { $0.classification == .containsGluten }
        )
        let glutenFromAllergens = canonicalNames(
            from: allergenHits.map(\.originalText),
            matching: { $0.classification == .containsGluten }
        )
        let glutenCanonicals = uniqueCanonicals(glutenFromIngredients + glutenFromAllergens)
        let ambiguousCanonicals = uniqueCanonicals(
            canonicalNames(
                from: ambiguous.map(\.originalText),
                matching: { $0.classification == .ambiguous }
            )
        )
        let glutenHits = glutenCanonicals.map { IngredientHit(name: $0, kind: .gluten) }
        let ambiguousHits = ambiguousCanonicals.map { IngredientHit(name: $0, kind: .ambiguous) }
        let unknownHits = uniqueHits(unknown.map(\.originalText), kind: .unknown)
        let warningHits = uniqueHits(crossContact.map(\.originalText), kind: .manufacturerWarning)
        let possibleHits = uniqueHits(
            possibleOCR.map { item in
                "\(item.originalText) → \(item.possibleMatch ?? "")"
            },
            kind: .possibleOCR
        )

        let avgConfidence: Double?
        if !observations.isEmpty {
            avgConfidence = Double(observations.map(\.confidence).reduce(0, +) / Float(observations.count))
        } else {
            avgConfidence = ocrConfidence
        }

        return ScanAnalysisResult(
            status: status,
            extractedText: original,
            glutenHits: glutenHits,
            ambiguousHits: ambiguousHits,
            manufacturerWarnings: warningHits,
            recognizedNonGluten: knownSafe.map(\.originalText),
            ocrConfidence: avgConfidence,
            originalOCRText: original,
            parsedIngredients: classified,
            unknownHits: unknownHits,
            possibleOCRHits: possibleHits,
            allergenDeclarations: uniqueHits(allergenHits.map(\.originalText), kind: .allergenDeclaration),
            glutenFreeClaims: claims,
            reviewReasons: reasons,
            scanQuality: quality,
            ingredientSectionFound: section.found,
            tooSmallForOCR: ocrAssess.tooSmall,
            skippedClassification: false
        )
    }

    private static func isLowConfidence(
        _ ingredient: String,
        observations: [OCRTextObservation],
        policy: OCRConfidencePolicy
    ) -> Bool {
        guard !observations.isEmpty else { return false }
        let key = ScanTextNormalizer.matchingKey(ingredient)
        let related = observations.filter {
            key.contains(ScanTextNormalizer.matchingKey($0.text))
                || ScanTextNormalizer.matchingKey($0.text).contains(key)
        }
        let pool = related.isEmpty ? observations : related
        return pool.contains { $0.confidence < policy.reviewThreshold }
    }

    private static func observationScanQuality(
        _ observations: [OCRTextObservation],
        policy: OCRConfidencePolicy,
        source: ScanTextSource
    ) -> ScanQuality {
        if source == .userEdited || source == .providedText { return .good }
        guard !observations.isEmpty else { return .partial }
        let region = IngredientRegionDetector.observationsInIngredientRegion(observations)
        let pool = region.isEmpty ? observations : region
        let mean = pool.map(\.confidence).reduce(0, +) / Float(pool.count)
        let lowCount = pool.filter { $0.confidence < policy.reviewThreshold }.count
        if mean < policy.reviewThreshold || lowCount * 2 >= observations.count { return .poor }
        if mean < policy.confidentThreshold || lowCount > 0 { return .partial }
        return .good
    }

    private static func canonicalNames(
        from texts: [String],
        matching include: (IngredientRule) -> Bool
    ) -> [String] {
        var names: [String] = []
        for text in texts {
            for rule in IngredientMatcher.matchedRules(in: text) where include(rule) {
                names.append(rule.canonicalName)
            }
        }
        return names
    }

    private static func uniqueCanonicals(_ names: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for name in names {
            let key = ScanTextNormalizer.matchingKey(name)
            guard !key.isEmpty, IngredientLexicon.isSafeDisplayKeyword(name), seen.insert(key).inserted else {
                continue
            }
            result.append(name)
        }
        return result
    }

    private static func uniqueHits(_ names: [String], kind: IngredientHit.Kind) -> [IngredientHit] {
        var seen = Set<String>()
        var result: [IngredientHit] = []
        for name in names {
            let key = ScanTextNormalizer.matchingKey(name)
            guard !key.isEmpty, !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(IngredientHit(name: name, kind: kind))
        }
        return result
    }
}

enum ScanReviewReason: String, Hashable {
    case unknownIngredients
    case ambiguousIngredients
    case unreadableText
    case partialRead
    case crossContactWarning
    case possibleOCRIssue
    case oatsNeedVerification
    case noIngredientSection
    case notIdentifiedAsIngredients

    var localizedMessage: String {
        switch self {
        case .unknownIngredients:
            return L10n.t("Some ingredients could not be identified.", ar: "تعذر التعرّف على بعض المكونات.")
        case .ambiguousIngredients:
            return L10n.t("Some ingredients require additional verification.", ar: "بعض المكونات تحتاج إلى تحقق إضافي.")
        case .unreadableText:
            return L10n.t("The ingredient list was not completely readable.", ar: "تعذر قراءة قائمة المكونات بالكامل.")
        case .partialRead:
            return L10n.t("Part of the ingredient list could not be read with high confidence.", ar: "تعذر قراءة جزء من قائمة المكونات بثقة كافية.")
        case .crossContactWarning:
            return L10n.t("A manufacturer cross-contact warning was detected.", ar: "تم العثور على تحذير من احتمال التلامس أثناء التصنيع.")
        case .possibleOCRIssue:
            return L10n.t("Possible OCR issue detected.", ar: "تم اكتشاف مشكلة محتملة في قراءة النص.")
        case .oatsNeedVerification:
            return L10n.t("Oats require additional verification and are not treated as certified gluten-free from the label alone.", ar: "الشوفان يحتاج تحققًا إضافيًا ولا يُعد معتمدًا خاليًا من الغلوتين من الملصق وحده.")
        case .noIngredientSection:
            return L10n.t("An ingredient list could not be confidently identified.", ar: "تعذر تحديد قائمة المكونات بشكل مؤكد.")
        case .notIdentifiedAsIngredients:
            return L10n.t("The scanned text could not be confidently identified as an ingredient list.", ar: "تعذر التأكد من أن النص الممسوح هو قائمة مكونات.")
        }
    }
}

#if DEBUG
enum ScanDiagnostics {
    static func log(
        original: String,
        section: IngredientSection,
        classified: [ClassifiedIngredient],
        statements: [LabelStatement],
        status: ScanAnalysisStatus,
        quality: ScanQuality
    ) {
        print("[GlutincScan] status=\(status.rawValue) quality=\(quality.rawValue) section=\(section.found)")
        print("[GlutincScan] ingredients=\(classified.map { "\($0.originalText):\($0.classification.rawValue)" })")
        print("[GlutincScan] statements=\(statements.map { "\($0.kind.rawValue):\($0.originalText)" })")
        _ = original
    }
}
#endif
