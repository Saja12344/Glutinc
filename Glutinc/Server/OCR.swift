import UIKit

/// Deprecated wrapper. Production scanning uses `LabelOCRService`.
enum OCRService {
    static func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
        LabelOCRService.recognize(image: image, cropToFocusGuide: false) { result in
            completion(result.originalText)
        }
    }
}
