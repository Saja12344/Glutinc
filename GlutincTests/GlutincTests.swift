import Foundation
import Testing
@testable import Glutincc

struct ScanAnalyzerTests {
    private func analyze(_ text: String) -> ScanAnalysisResult {
        ScanAnalyzer.analyze(text: text, ocrConfidence: nil)
    }

    // MARK: English gluten

    @Test func wheatFlourContainsGluten() {
        #expect(analyze("Wheat Flour").status == .glutenDetected)
    }

    @Test func barleyMaltContainsGluten() {
        #expect(analyze("Barley Malt").status == .glutenDetected)
    }

    @Test func ryeFlourContainsGluten() {
        #expect(analyze("Rye Flour").status == .glutenDetected)
    }

    @Test func nestedChocolateWheatFlourContainsGluten() {
        let result = analyze("Ingredients: Chocolate coating (Sugar, Cocoa, Wheat Flour), Milk")
        #expect(result.status == .glutenDetected)
    }

    // MARK: Substring false positives

    @Test func buckwheatDoesNotMatchWheat() {
        let result = analyze("Buckwheat")
        #expect(result.status != .glutenDetected)
        #expect(result.glutenHits.isEmpty)
    }

    @Test func maltodextrinDoesNotMatchMalt() {
        let result = analyze("Maltodextrin")
        #expect(result.status != .glutenDetected)
        #expect(result.glutenHits.isEmpty)
    }

    // MARK: Unknown and ambiguous block green

    @Test func fullyRecognizedSimpleListCanBeGreen() {
        let result = analyze("Rice, Salt, Olive Oil")
        #expect(result.status == .noneDetected)
        #expect(result.unknownHits.isEmpty)
    }

    @Test func unknownIngredientBlocksGreen() {
        let result = analyze("Rice, Salt, UnknownXYZ")
        #expect(result.status == .reviewRecommended)
        #expect(!result.unknownHits.isEmpty)
    }

    @Test func flavouringIsReview() {
        let result = analyze("Water, Sugar, Flavouring")
        #expect(result.status == .reviewRecommended)
        #expect(!result.ambiguousHits.isEmpty)
    }

    @Test func redBullMalformedOCRIsReview() {
        let result = analyze("Ingredients: Water, Sugar, Flavourings, Tourine, Acion Raulabs, Sodium Caronor")
        #expect(result.status == .reviewRecommended)
        #expect(!result.ambiguousHits.isEmpty)
        #expect(!result.unknownHits.isEmpty)
        #expect(result.reviewReasons.contains(.ambiguousIngredients))
        #expect(result.reviewReasons.contains(.unknownIngredients))
    }

    // MARK: Statements

    @Test func containsWheatIsGluten() {
        #expect(analyze("Contains wheat").status == .glutenDetected)
        #expect(!analyze("Contains wheat").allergenDeclarations.isEmpty)
    }

    @Test func mayContainWheatIsReviewNotIngredientRed() {
        let result = analyze("May contain wheat")
        #expect(result.status == .reviewRecommended)
        #expect(!result.manufacturerWarnings.isEmpty)
        #expect(result.glutenHits.isEmpty)
    }

    @Test func glutenFreeClaimIsNotRed() {
        let result = analyze("Gluten-Free")
        #expect(result.status != .glutenDetected)
    }

    // MARK: OCR typos

    @Test func wheatTyposAreReviewNotGreen() {
        #expect(analyze("wneat").status == .reviewRecommended)
        #expect(analyze("wheal").status == .reviewRecommended)
        #expect(analyze("bariey").status == .reviewRecommended)
        #expect(analyze("mait").status == .reviewRecommended)
        #expect(analyze("wneat").status != .noneDetected)
        #expect(!analyze("wneat").possibleOCRHits.isEmpty)
    }

    // MARK: Arabic

    @Test func arabicWheatFlourContainsGluten() {
        #expect(analyze("المكونات: ماء، سكر، دقيق القمح").status == .glutenDetected)
    }

    @Test func arabicBarleyContainsGluten() {
        #expect(analyze("المكونات: ماء، سكر، شعير").status == .glutenDetected)
    }

    @Test func arabicRyeContainsGluten() {
        #expect(analyze("المكونات: ماء، سكر، جاودار").status == .glutenDetected)
    }

    @Test func arabicSemolinaContainsGluten() {
        #expect(analyze("المكونات: ماء، سميد").status == .glutenDetected)
    }

    @Test func arabicBulgurContainsGluten() {
        #expect(analyze("المكونات: ماء، برغل").status == .glutenDetected)
    }

    @Test func arabicCouscousContainsGluten() {
        #expect(analyze("المكونات: ماء، كسكس").status == .glutenDetected)
    }

    @Test func arabicFlavoringIsReview() {
        #expect(analyze("المكونات: ماء، سكر، منكهات").status == .reviewRecommended)
    }

    @Test func arabicUnknownBlocksGreen() {
        let result = analyze("المكونات: ماء، سكر، مكونغيرمعروف")
        #expect(result.status == .reviewRecommended)
        #expect(!result.unknownHits.isEmpty)
    }

    @Test func arabicCrossContactIsReview() {
        let result = analyze("قد يحتوي على آثار من القمح")
        #expect(result.status == .reviewRecommended)
        #expect(!result.manufacturerWarnings.isEmpty)
        #expect(result.status != .glutenDetected)
    }

    @Test func arabicContainsWheatIsGluten() {
        #expect(analyze("يحتوي على القمح").status == .glutenDetected)
    }

    @Test func arabicGlutenFreeClaimIsNotRed() {
        #expect(analyze("خالٍ من الغلوتين").status != .glutenDetected)
        #expect(analyze("بدون جلوتين").status != .glutenDetected)
    }

    @Test func arabicWheatNormalization() {
        #expect(analyze("قمح").status == .glutenDetected)
        #expect(analyze("قَمْح").status == .glutenDetected)
        #expect(analyze("القمح").status == .glutenDetected)
    }

    @Test func arabicOnlyKnownListCanBeGreen() {
        let result = analyze("المكونات: ماء، سكر، ملح")
        #expect(result.status == .noneDetected)
    }

    @Test func arabicNestedWheatFlourContainsGluten() {
        #expect(analyze("المكونات: شوكولاتة (سكر، كاكاو، دقيق القمح)، حليب").status == .glutenDetected)
    }

    // MARK: Mixed language

    @Test func mixedArabicEnglishWheatFlour() {
        #expect(analyze("المكونات: ماء، Sugar، Wheat Flour، حليب").status == .glutenDetected)
    }

    @Test func mixedEnglishArabicBarley() {
        #expect(analyze("Ingredients: Water, سكر, شعير, Cocoa").status == .glutenDetected)
    }

    @Test func mixedFlavouringIsReview() {
        #expect(analyze("Ingredients: Water, سكر, Flavouring").status == .reviewRecommended)
    }

    @Test func unknownNeverAllowsGreen() {
        let result = analyze("Ingredients: Water, Acion Raulabs")
        #expect(result.status != .noneDetected)
        #expect(!result.unknownHits.isEmpty)
    }

    // MARK: OCR quality gate

    @Test func arabicIngredientListWithFlavoringIsReviewNotUnreadable() {
        let result = analyze("المكونات: ماء، سكر، حمض الستريك، تورين، كافيين، فيتامينات، منكهات")
        #expect(result.ingredientSectionFound)
        #expect(result.status == .reviewRecommended)
        #expect(!result.ambiguousHits.isEmpty)
        #expect(result.status != .unreadableIngredients)
        #expect(result.skippedClassification == false)
    }

    @Test func arabicWheatFlourListContainsGluten() {
        let result = analyze("المكونات: ماء، سكر، دقيق القمح، حليب")
        #expect(result.status == .glutenDetected)
        #expect(result.skippedClassification == false)
    }

    @Test func gibberishOCRIsUnreadableNotReviewOrGreen() {
        let result = analyze("""
        plco
        Vermnls
        Asrugo
        2T Ple rV
        Z-A pliègelu
        """)
        #expect(result.status == .unreadableIngredients)
        #expect(result.skippedClassification)
        #expect(result.glutenHits.isEmpty)
        #expect(result.ambiguousHits.isEmpty)
        #expect(result.unknownHits.isEmpty)
        #expect(result.status != .reviewRecommended)
        #expect(result.status != .noneDetected)
    }

    @Test func englishFlavouringsListIsReview() {
        let result = analyze("Ingredients: Water, Sucrose, Glucose, Citric Acid, Taurine, Flavourings")
        #expect(result.status == .reviewRecommended)
        #expect(!result.ambiguousHits.isEmpty)
        #expect(result.status != .unreadableIngredients)
    }

    @Test func englishWheatFlourListContainsGluten() {
        #expect(analyze("Ingredients: Water, Sugar, Wheat Flour, Cocoa").status == .glutenDetected)
    }

    @Test func packagingSloganIsUnreadableNotGreen() {
        let result = analyze("""
        VITALIZES BODY AND MIND
        ENERGY DRINK
        250 ML
        BEST SERVED COLD
        """)
        #expect(result.status == .unreadableIngredients)
        #expect(result.skippedClassification)
        #expect(result.status != .noneDetected)
        #expect(result.glutenHits.isEmpty)
    }

    @Test func gibberishCannotReachNoGlutenDetected() {
        let texts = [
            "plco Vermnls Asrugo",
            "ENERGY DRINK 250 ML",
            "qzx wlp nrm vtb"
        ]
        for text in texts {
            let result = analyze(text)
            #expect(result.status != .noneDetected)
            #expect(result.catalogNeverGreen)
        }
    }
}

extension ScanAnalysisResult {
    var catalogNeverGreen: Bool {
        status != .noneDetected
    }
}

struct ScanTextNormalizerTests {
    @Test func diacriticsAndAlefCollapse() {
        #expect(ScanTextNormalizer.matchingKey("قَمْح") == ScanTextNormalizer.matchingKey("قمح"))
        #expect(ScanTextNormalizer.tokens("القمح") == ["قمح"])
        #expect(ScanTextNormalizer.tokens("دقيق   القمح") == ["دقيق", "قمح"])
    }
}

struct IngredientParserTests {
    @Test func nestedEnglishAndArabicSeparators() {
        let parsed = IngredientParser.parse("Chocolate coating (Sugar, Cocoa, Wheat Flour), Milk")
        #expect(parsed.contains(where: { $0.originalText.localizedCaseInsensitiveContains("Wheat Flour") }))
        let arabic = IngredientParser.parse("شوكولاتة (سكر، كاكاو، دقيق القمح)، حليب")
        #expect(arabic.contains(where: { $0.originalText.contains("دقيق القمح") }))
    }

    @Test func arabicIngredientSectionAndCommaParsing() {
        let section = IngredientParser.detectSection(in: "المكونات: ماء، سكر، حمض الستريك، تورين")
        #expect(section.found)
        let parsed = IngredientParser.parse(section.text)
        #expect(parsed.count >= 4)
        #expect(parsed.contains(where: { $0.originalText.contains("ماء") }))
        #expect(parsed.contains(where: { $0.originalText.contains("تورين") }))
    }
}

struct OCRQualityEvaluatorTests {
    @Test func gibberishHeuristicCatchesCorruptedLatin() {
        #expect(OCRQualityEvaluator.looksLikeGibberish(
            "plco\nVermnls\nAsrugo\n2T Ple rV\nZ-A pliègelu",
            headerFound: false,
            knownConcepts: 0
        ))
    }

    @Test func realArabicListIsNotGibberish() {
        #expect(!OCRQualityEvaluator.looksLikeGibberish(
            "المكونات: ماء، سكر، حمض الستريك، تورين، كافيين، فيتامينات، منكهات",
            headerFound: true,
            knownConcepts: 3
        ))
    }

    @Test func mixedArabicEnglishIsNotRejectedForScriptMix() {
        let result = ScanAnalyzer.analyze(
            text: "المكونات: ماء، Sugar، Taurine، منكهات",
            ocrConfidence: nil
        )
        #expect(result.status != .unreadableIngredients)
        #expect(result.status == .reviewRecommended)
    }
}

struct ProductCatalogExploreTests {
    @Test func glutenProductsAreEligibleForExplore() {
        #expect(ProductCatalog.isEligibleForExplore(
            verification: .pending,
            gluten: .containsGluten
        ))
        #expect(ProductCatalog.isEligibleForExplore(
            verification: .verified,
            gluten: .noGlutenDetected
        ))
    }

    @Test func rejectedProductsAreHiddenFromExplore() {
        #expect(!ProductCatalog.isEligibleForExplore(
            verification: .rejected,
            gluten: .noGlutenDetected
        ))
    }
}
