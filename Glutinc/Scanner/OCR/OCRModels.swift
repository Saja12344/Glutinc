import Foundation
import CoreGraphics

struct OCRConfidencePolicy: Sendable {
    /// Vision confidence is 0...1. These values are internal routing heuristics,
    /// not a measured accuracy percentage.
    /// Printed ingredient text in good light typically scores well above 0.8;
    /// glare and tiny type often drop below 0.5. Below `reviewThreshold` a token
    /// cannot support noGlutenDetected.
    let confidentThreshold: Float
    let reviewThreshold: Float

    static let standard = OCRConfidencePolicy(
        confidentThreshold: 0.75,
        reviewThreshold: 0.50
    )
}

struct OCRTextObservation: Hashable, Sendable {
    let text: String
    let confidence: Float
    let boundingBox: CGRect
}

struct OCRResult: Sendable {
    let originalText: String
    let observations: [OCRTextObservation]
    let usedFocusCrop: Bool
}

enum ScanCaptureSource: String, Sendable {
    case camera
    case photoLibrary
}

enum CameraFocusGuide {
    /// Normalized to the camera preview view (origin top-left). The visible guide
    /// and the OCR crop must use this same rectangle after aspect-fill conversion.
    static let previewNormalizedRect = CGRect(x: 0.08, y: 0.22, width: 0.84, height: 0.42)
}
