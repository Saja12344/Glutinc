import Foundation

enum IngredientLexicon {
    static let rules: [IngredientRule] = glutenGrains + glutenDerivatives + oats + ambiguous + knownOrdinary + processingAids

    static let compiledAliases: [CompiledAlias] = {
        var items: [CompiledAlias] = []
        for (index, rule) in rules.enumerated() {
            for alias in rule.aliasesEN + rule.aliasesAR {
                let tokens = ScanTextNormalizer.tokens(alias)
                guard !tokens.isEmpty else { continue }
                items.append(CompiledAlias(tokens: tokens, ruleIndex: index))
            }
        }
        return items.sorted {
            if $0.tokens.count != $1.tokens.count { return $0.tokens.count > $1.tokens.count }
            return $0.tokens.joined().count > $1.tokens.joined().count
        }
    }()

    static let glutenSingleTokens: [String] = {
        var tokens = Set<String>()
        for rule in rules where rule.classification == .containsGluten {
            for alias in rule.aliasesEN + rule.aliasesAR {
                let parts = ScanTextNormalizer.tokens(alias)
                if parts.count == 1, let token = parts.first, token.count >= 4 {
                    tokens.insert(token)
                }
            }
        }
        return Array(tokens)
    }()

    struct CompiledAlias {
        let tokens: [String]
        let ruleIndex: Int
    }

    private static let src = RuleSource.internalManual

    private static func rule(
        _ canonical: String,
        en: [String],
        ar: [String] = [],
        classification: IngredientGlutenClassification,
        category: IngredientCategory,
        notes: String? = nil
    ) -> IngredientRule {
        IngredientRule(
            canonicalName: canonical,
            aliasesEN: en,
            aliasesAR: ar,
            classification: classification,
            category: category,
            source: src,
            notes: notes
        )
    }

    private static let glutenGrains: [IngredientRule] = [
        rule("wheat", en: ["wheat"], ar: ["قمح", "حنطة"], classification: .containsGluten, category: .glutenGrain),
        rule("wheat flour", en: ["wheat flour", "wheatflour"], ar: ["دقيق القمح", "طحين القمح", "دقيق حنطة", "طحين الحنطة"], classification: .containsGluten, category: .glutenGrain),
        rule("wheat starch", en: ["wheat starch"], ar: ["نشا القمح"], classification: .containsGluten, category: .glutenDerivative),
        rule("wheat protein", en: ["wheat protein"], ar: ["بروتين القمح"], classification: .containsGluten, category: .glutenDerivative),
        rule("hydrolyzed wheat protein", en: ["hydrolyzed wheat protein", "hydrolysed wheat protein", "hydrolyzed wheat"], ar: ["بروتين القمح المتحلل"], classification: .containsGluten, category: .glutenDerivative),
        rule("wheat bran", en: ["wheat bran"], ar: ["نخالة القمح"], classification: .containsGluten, category: .glutenGrain),
        rule("wheat germ", en: ["wheat germ"], ar: ["جنين القمح"], classification: .containsGluten, category: .glutenGrain),
        rule("wheat gluten", en: ["wheat gluten"], ar: ["غلوتين القمح", "جلوتين القمح"], classification: .containsGluten, category: .glutenDerivative),
        rule("gluten", en: ["gluten"], ar: ["غلوتين", "جلوتين"], classification: .containsGluten, category: .glutenDerivative, notes: "Ingredient token only. Gluten-free claims are masked before matching."),
        rule("barley", en: ["barley"], ar: ["شعير"], classification: .containsGluten, category: .glutenGrain),
        rule("barley malt", en: ["barley malt", "malted barley"], ar: ["شعير مملت", "شعير ممات", "شعير مستنبت"], classification: .containsGluten, category: .glutenDerivative),
        rule("malt extract", en: ["malt extract"], ar: ["مستخلص المالت", "مستخلص الملت", "مستخلص الشعير"], classification: .containsGluten, category: .glutenDerivative),
        rule("malt syrup", en: ["malt syrup"], ar: ["شراب المالت", "شراب الملت"], classification: .containsGluten, category: .glutenDerivative),
        rule("malt vinegar", en: ["malt vinegar"], ar: ["خل المالت", "خل الملت"], classification: .containsGluten, category: .glutenDerivative),
        rule("malt flavor", en: ["malt flavor", "malt flavour", "malt flavoring", "malt flavouring"], ar: ["نكهة المالت", "نكهة الملت"], classification: .containsGluten, category: .glutenDerivative),
        rule("malt", en: ["malt", "malted"], ar: ["مالت", "ملت"], classification: .containsGluten, category: .glutenDerivative),
        rule("rye", en: ["rye"], ar: ["جاودار"], classification: .containsGluten, category: .glutenGrain),
        rule("rye flour", en: ["rye flour"], ar: ["دقيق الجاودار", "طحين الجاودار"], classification: .containsGluten, category: .glutenGrain),
        rule("triticale", en: ["triticale"], ar: ["تريتيكال"], classification: .containsGluten, category: .glutenGrain),
        rule("durum", en: ["durum", "durum wheat"], ar: ["قمح دوروم"], classification: .containsGluten, category: .glutenGrain),
        rule("semolina", en: ["semolina"], ar: ["سميد", "سيمولينا"], classification: .containsGluten, category: .glutenGrain),
        rule("farina", en: ["farina"], ar: ["فارينا"], classification: .containsGluten, category: .glutenGrain),
        rule("spelt", en: ["spelt", "spelt wheat"], ar: ["سبلت"], classification: .containsGluten, category: .glutenGrain),
        rule("einkorn", en: ["einkorn"], classification: .containsGluten, category: .glutenGrain),
        rule("emmer", en: ["emmer"], classification: .containsGluten, category: .glutenGrain),
        rule("farro", en: ["farro", "faro"], classification: .containsGluten, category: .glutenGrain),
        rule("khorasan wheat", en: ["khorasan wheat", "khorasan", "kamut"], ar: ["قمح خوراسان", "كاموت"], classification: .containsGluten, category: .glutenGrain),
        rule("bulgur", en: ["bulgur", "bulghur"], ar: ["برغل"], classification: .containsGluten, category: .glutenGrain),
        rule("couscous", en: ["couscous"], ar: ["كسكس", "كسكسي"], classification: .containsGluten, category: .glutenGrain),
        rule("seitan", en: ["seitan"], ar: ["سيتان"], classification: .containsGluten, category: .glutenDerivative),
        rule("graham flour", en: ["graham flour", "graham"], ar: ["دقيق جراهام"], classification: .containsGluten, category: .glutenGrain),
        rule("matzo", en: ["matzo", "matzah", "matza"], classification: .containsGluten, category: .glutenGrain),
        rule("orzo", en: ["orzo"], classification: .containsGluten, category: .glutenGrain),
        rule("beer", en: ["beer", "lager"], ar: ["بيرة", "لايغر"], classification: .containsGluten, category: .glutenDerivative),
        rule("brewers yeast", en: ["brewers yeast", "brewer yeast"], ar: ["خميرة البيرة"], classification: .containsGluten, category: .glutenDerivative),
    ]

    private static let glutenDerivatives: [IngredientRule] = [
        rule("breadcrumbs", en: ["breadcrumbs", "bread crumbs", "breaded", "breading"], ar: ["بقسماط"], classification: .ambiguous, category: .ambiguous, notes: "Often wheat-based; treated as review unless source is declared."),
    ]

    private static let oats: [IngredientRule] = [
        rule("oats", en: ["oats", "oat", "oatmeal", "oat flour", "oat flakes"], ar: ["شوفان", "دقيق الشوفان"], classification: .ambiguous, category: .oats, notes: "Ordinary oats are not treated as wheat, but are not green without independent certification."),
    ]

    private static let ambiguous: [IngredientRule] = [
        rule("flavoring", en: ["flavoring", "flavouring", "flavorings", "flavourings", "flavor", "flavour", "flavors", "flavours", "natural flavor", "natural flavour", "natural flavors", "natural flavours", "artificial flavor", "artificial flavour"], ar: ["منكهات", "نكهات", "نكهة", "نكهة طبيعية", "نكهات طبيعية"], classification: .ambiguous, category: .ambiguous),
        rule("seasoning", en: ["seasoning", "seasonings"], ar: ["تتبيلة", "توابل", "خلطة توابل"], classification: .ambiguous, category: .ambiguous),
        rule("starch", en: ["starch", "modified starch", "modified food starch"], ar: ["نشا", "نشا معدل"], classification: .ambiguous, category: .ambiguous),
        rule("flour", en: ["flour"], ar: ["دقيق", "طحين"], classification: .ambiguous, category: .ambiguous, notes: "Unspecified flour may be wheat."),
        rule("yeast extract", en: ["yeast extract"], ar: ["مستخلص الخميرة", "مستخلص خميرة"], classification: .ambiguous, category: .ambiguous),
        rule("hydrolyzed protein", en: ["hydrolyzed protein", "hydrolysed protein"], ar: ["بروتين متحلل"], classification: .ambiguous, category: .ambiguous),
        rule("vegetable protein", en: ["vegetable protein", "hydrolyzed vegetable protein", "hydrolysed vegetable protein"], ar: ["بروتين نباتي"], classification: .ambiguous, category: .ambiguous),
        rule("soy sauce", en: ["soy sauce", "soya sauce"], ar: ["صلصة الصويا", "صويا صوص"], classification: .ambiguous, category: .ambiguous),
        rule("dextrin", en: ["dextrin"], ar: ["دكسترين"], classification: .ambiguous, category: .processingAid),
        rule("gravy", en: ["gravy"], ar: ["مرقة"], classification: .ambiguous, category: .ambiguous),
        rule("broth", en: ["broth", "bouillon"], ar: ["مرق"], classification: .ambiguous, category: .ambiguous),
        rule("marinade", en: ["marinade"], classification: .ambiguous, category: .ambiguous),
        rule("coating", en: ["coating"], ar: ["تغليف"], classification: .ambiguous, category: .ambiguous),
        rule("miso", en: ["miso"], ar: ["ميسو"], classification: .ambiguous, category: .ambiguous),
        rule("vinegar", en: ["vinegar"], ar: ["خل"], classification: .ambiguous, category: .ambiguous, notes: "Unspecified vinegar; malt vinegar is a separate gluten rule."),
    ]

    /// Known ordinary foods so a complete, fully classified list can reach noGlutenDetected.
    /// Absence from this list is unknown, never assumed gluten-free.
    private static let knownOrdinary: [IngredientRule] = [
        rule("buckwheat", en: ["buckwheat"], ar: ["حنطة سوداء", "قمح سوداء"], classification: .noKnownGluten, category: .ordinaryIngredient, notes: "Must not match the wheat rule."),
        rule("maltodextrin", en: ["maltodextrin"], ar: ["مالتودكسترين", "ملتودكسترين"], classification: .noKnownGluten, category: .processingAid, notes: "Must not match the malt rule by substring."),
        rule("water", en: ["water"], ar: ["ماء"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("sugar", en: ["sugar", "sugars", "glucose", "sucrose", "fructose"], ar: ["سكر"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("salt", en: ["salt", "sea salt", "sodium chloride"], ar: ["ملح"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("rice", en: ["rice", "rice flour"], ar: ["ارز", "دقيق الارز"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("olive oil", en: ["olive oil"], ar: ["زيت زيتون", "زيت الزيتون"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("oil", en: ["oil", "vegetable oil", "sunflower oil", "canola oil", "corn oil"], ar: ["زيت"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("milk", en: ["milk", "milk powder", "skim milk"], ar: ["حليب"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("cocoa", en: ["cocoa", "cocoa powder"], ar: ["كاكاو"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("chocolate", en: ["chocolate", "chocolate coating"], ar: ["شوكولاتة", "شوكولاته"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("egg", en: ["egg", "eggs"], ar: ["بيض"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("corn", en: ["corn", "maize", "corn starch", "cornstarch"], ar: ["ذرة", "نشا الذرة"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("potato", en: ["potato", "potatoes"], ar: ["بطاطس", "بطاطا"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("honey", en: ["honey"], ar: ["عسل"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("butter", en: ["butter"], ar: ["زبدة"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("onion", en: ["onion", "onions"], ar: ["بصل"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("garlic", en: ["garlic"], ar: ["ثوم"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("tomato", en: ["tomato", "tomatoes"], ar: ["طماطم"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("pepper", en: ["pepper", "black pepper"], ar: ["فلفل"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("quinoa", en: ["quinoa"], ar: ["كينوا"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("millet", en: ["millet"], ar: ["دخن"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("tapioca", en: ["tapioca"], ar: ["تابيوكا"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("amaranth", en: ["amaranth"], ar: ["قطيفة"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("coffee", en: ["coffee"], ar: ["قهوة"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("tea", en: ["tea"], ar: ["شاي"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("citric acid", en: ["citric acid"], ar: ["حمض الستريك"], classification: .noKnownGluten, category: .processingAid),
        rule("caffeine", en: ["caffeine"], ar: ["كافيين"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("taurine", en: ["taurine"], ar: ["تورين"], classification: .noKnownGluten, category: .ordinaryIngredient),
        rule("carbonated water", en: ["carbonated water", "sparkling water"], ar: ["ماء فوار"], classification: .noKnownGluten, category: .ordinaryIngredient),
    ]

    private static let processingAids: [IngredientRule] = []

    static func rule(forCanonical name: String) -> IngredientRule? {
        let key = ScanTextNormalizer.matchingKey(name)
        return rules.first { ScanTextNormalizer.matchingKey($0.canonicalName) == key }
    }

    static func displayName(forCanonical name: String, arabic: Bool) -> String {
        if let rule = rule(forCanonical: name) {
            return displayName(rule, arabic: arabic)
        }
        return arabic ? name : titleCased(name)
    }

    static func displayName(_ rule: IngredientRule, arabic: Bool) -> String {
        if arabic {
            return rule.aliasesAR.first ?? rule.canonicalName
        }
        return titleCased(rule.aliasesEN.first ?? rule.canonicalName)
    }

    static func isGlutenRisk(_ rule: IngredientRule) -> Bool {
        switch rule.classification {
        case .containsGluten:
            return true
        case .ambiguous:
            return rule.category == .oats
                || rule.canonicalName == "flour"
                || rule.canonicalName == "breadcrumbs"
        default:
            return false
        }
    }

    static func isSafeDisplayKeyword(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return false }
        if trimmed.contains(where: \.isNumber) { return false }
        if trimmed.unicodeScalars.allSatisfy({ !CharacterSet.letters.contains($0) }) { return false }
        let key = ScanTextNormalizer.matchingKey(trimmed)
        return !blockedDisplayKeys.contains(key)
    }

    /// Resolve stored names (canonical or legacy noisy OCR) into confirmed gluten keywords.
    static func userFacingKeywords(from stored: [String], arabic: Bool) -> [String] {
        localizedRules(from: stored, arabic: arabic) { $0.classification == .containsGluten }
    }

    static func userFacingReviewKeywords(from stored: [String], arabic: Bool) -> [String] {
        localizedRules(from: stored, arabic: arabic) { isGlutenRisk($0) && $0.classification != .containsGluten }
    }

    private static func localizedRules(
        from stored: [String],
        arabic: Bool,
        include: (IngredientRule) -> Bool
    ) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for item in stored {
            let matched: [IngredientRule]
            if let exact = rule(forCanonical: item), include(exact) {
                matched = [exact]
            } else {
                matched = IngredientMatcher.matchedRules(in: item).filter(include)
            }
            for rule in matched {
                guard seen.insert(rule.canonicalName).inserted else { continue }
                let visible = displayName(rule, arabic: arabic)
                guard isSafeDisplayKeyword(visible) else { continue }
                result.append(visible)
            }
        }
        return result
    }

    static func localizedKeywords(canonical names: [String], arabic: Bool) -> [String] {
        userFacingKeywords(from: names, arabic: arabic)
    }

    private static func titleCased(_ name: String) -> String {
        name.split(separator: " ").map { part in
            part.count <= 2 ? part.uppercased() : part.localizedCapitalized
        }.joined(separator: " ")
    }

    private static let blockedDisplayKeys: Set<String> = {
        let phrases = [
            "contains", "may contain", "contains:", "may contain:",
            "يحتوي على", "قد يحتوي على", "يحتوي", "قد يحتوي",
            "kingdom of bahrain", "bahrain", "مملكة البحرين", "البحرين",
            "nutrition facts", "calories"
        ]
        return Set(phrases.map { ScanTextNormalizer.matchingKey($0) })
    }()
}
