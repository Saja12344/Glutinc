import Foundation
import UIKit
import Vision

enum LabelOCRService {
    static let customWords = [
        "Ingredients", "Wheat", "Barley", "Rye", "Gluten", "Malt", "Semolina",
        "Bulgur", "Couscous", "Oats", "Flavouring", "Flavoring", "Starch",
        "wheat", "barley", "rye", "malt", "semolina", "gluten", "ingredients",
        "buckwheat", "maltodextrin", "oats",
        "المكونات", "المقادير", "قمح", "القمح", "دقيق", "طحين", "دقيق القمح",
        "طحين القمح", "شعير", "الشعير", "جاودار", "غلوتين", "جلوتين",
        "مالت", "ملت", "سميد", "برغل", "كسكس", "شوفان", "منكهات", "نكهات",
        "نشا", "نشا معدل"
    ]

    static func recognize(
        image: UIImage,
        cropToFocusGuide: Bool,
        previewSize: CGSize = UIScreen.main.bounds.size,
        completion: @escaping (OCRResult) -> Void
    ) {
        let working: UIImage
        if cropToFocusGuide {
            let upright = image.glutincUpright()
            let imageSize = CGSize(width: upright.size.width * upright.scale, height: upright.size.height * upright.scale)
            let normalized = ImageCoordinateMapper.imageNormalizedRect(
                previewNormalized: CameraFocusGuide.previewNormalizedRect,
                imageSize: imageSize,
                viewSize: previewSize
            )
            working = upright.glutincCropped(toNormalized: normalized)
        } else {
            working = image
        }

        guard let cgImage = working.cgImage else {
            completion(OCRResult(originalText: "", observations: [], usedFocusCrop: cropToFocusGuide))
            return
        }

        let orientation = working.imageOrientation.glutincCGImageOrientation
        #if DEBUG
        print("[GlutincOCR] original=\(Int(image.size.width * image.scale))x\(Int(image.size.height * image.scale)) cropped=\(cgImage.width)x\(cgImage.height) orientation=\(orientation.rawValue) crop=\(cropToFocusGuide) languages=ar-SA,en-US")
        #endif

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(OCRResult(originalText: "", observations: [], usedFocusCrop: cropToFocusGuide))
                }
                return
            }
            let raw = (request.results as? [VNRecognizedTextObservation]) ?? []
            let mapped: [OCRTextObservation] = raw.compactMap { obs in
                guard let candidate = obs.topCandidates(1).first else { return nil }
                return OCRTextObservation(
                    text: candidate.string,
                    confidence: candidate.confidence,
                    boundingBox: obs.boundingBox
                )
            }
            let sorted = sortSpatially(mapped)
            #if DEBUG
            for obs in sorted {
                print("[GlutincOCR] conf=\(String(format: "%.2f", obs.confidence)) box=\(obs.boundingBox) text=\(obs.text)")
            }
            #endif
            let text = sorted.map(\.text).joined(separator: "\n")
            DispatchQueue.main.async {
                completion(OCRResult(originalText: text, observations: sorted, usedFocusCrop: cropToFocusGuide))
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ar-SA", "en-US"]
        request.customWords = customWords
        request.minimumTextHeight = 0.006
        if #available(iOS 16.0, *) {
            request.automaticallyDetectsLanguage = true
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                #if DEBUG
                print("[GlutincOCR] Vision error: \(error)")
                #endif
                DispatchQueue.main.async {
                    completion(OCRResult(originalText: "", observations: [], usedFocusCrop: cropToFocusGuide))
                }
            }
        }
    }

    static func sortSpatially(_ observations: [OCRTextObservation]) -> [OCRTextObservation] {
        guard !observations.isEmpty else { return [] }
        let joined = observations.map(\.text).joined()
        let arabicChars = joined.filter { ScanTextNormalizer.containsArabic(String($0)) }.count
        let latinChars = joined.filter(\.isASCII).filter(\.isLetter).count
        let preferRTL = arabicChars > latinChars

        let rowThreshold: CGFloat = 0.03
        var rows: [[OCRTextObservation]] = []
        let byY = observations.sorted { $0.boundingBox.midY > $1.boundingBox.midY }
        for obs in byY {
            if var last = rows.last, let sample = last.first,
               abs(sample.boundingBox.midY - obs.boundingBox.midY) < rowThreshold {
                last.append(obs)
                rows[rows.count - 1] = last
            } else {
                rows.append([obs])
            }
        }

        return rows.flatMap { row in
            row.sorted {
                preferRTL ? $0.boundingBox.minX > $1.boundingBox.minX : $0.boundingBox.minX < $1.boundingBox.minX
            }
        }
    }
}

extension UIImage.Orientation {
    var glutincCGImageOrientation: CGImagePropertyOrientation {
        switch self {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}

extension UIImage {
    /// Re-render so `imageOrientation` is `.up` without reducing pixel scale.
    func glutincUpright() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func glutincCropped(toNormalized rect: CGRect) -> UIImage {
        let upright = glutincUpright()
        guard let cg = upright.cgImage else { return upright }
        let width = CGFloat(cg.width)
        let height = CGFloat(cg.height)
        let crop = CGRect(
            x: rect.origin.x * width,
            y: rect.origin.y * height,
            width: rect.size.width * width,
            height: rect.size.height * height
        ).integral
        let bounded = crop.intersection(CGRect(x: 0, y: 0, width: width, height: height))
        guard !bounded.isNull, bounded.width > 8, bounded.height > 8,
              let cropped = cg.cropping(to: bounded) else {
            return upright
        }
        #if DEBUG
        print("[GlutincOCR] pixel crop \(Int(bounded.width))x\(Int(bounded.height)) from \(Int(width))x\(Int(height))")
        #endif
        return UIImage(cgImage: cropped, scale: 1, orientation: .up)
    }
}
