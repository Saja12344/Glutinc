//
//  OCR.swift
//  Glutinc
//
//  Created by saja khalid on 10/06/1447 AH.
//

import Vision
import UIKit

class OCRService {
    
    static let shared = OCRService()
    
    private init() {}
    
    func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
        // Convert UIImage to CGImage (required by Vision)
        guard let cgImage = image.cgImage else { return }

        // Create the text recognition request
        let request = VNRecognizeTextRequest { request, error in
            var fullText = ""
            
            // Gather recognized text lines from observations
            if let observations = request.results as? [VNRecognizedTextObservation] {
                fullText = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: " ")
            }
            
            // Ensure UI updates and model changes occur on the main queue
            DispatchQueue.main.async {
                completion(fullText)
            }
        }

        // Prefer higher accuracy (may be slower, but better quality)
        request.recognitionLevel = .accurate
        
        // Perform the request using a VNImageRequestHandler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        // Swallowing errors here for simplicity; consider error propagation for production
        try? handler.perform([request])
    }
}
