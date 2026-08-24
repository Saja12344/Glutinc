import CoreGraphics
import UIKit

enum ImageCoordinateMapper {
    /// Maps a preview-normalized rect (origin top-left, 0...1) onto an upright image,
    /// accounting for AVCapture preview `.resizeAspectFill`.
    static func imageNormalizedRect(
        previewNormalized rect: CGRect,
        imageSize: CGSize,
        viewSize: CGSize
    ) -> CGRect {
        guard imageSize.width > 1, imageSize.height > 1, viewSize.width > 1, viewSize.height > 1 else {
            return rect
        }
        let displayed = aspectFillDisplayedRect(imageSize: imageSize, viewSize: viewSize)
        let viewRect = CGRect(
            x: rect.origin.x * viewSize.width,
            y: rect.origin.y * viewSize.height,
            width: rect.size.width * viewSize.width,
            height: rect.size.height * viewSize.height
        )
        let scaleX = imageSize.width / displayed.width
        let scaleY = imageSize.height / displayed.height
        let img = CGRect(
            x: (viewRect.minX - displayed.minX) * scaleX,
            y: (viewRect.minY - displayed.minY) * scaleY,
            width: viewRect.width * scaleX,
            height: viewRect.height * scaleY
        )
        return CGRect(
            x: img.origin.x / imageSize.width,
            y: img.origin.y / imageSize.height,
            width: img.size.width / imageSize.width,
            height: img.size.height / imageSize.height
        )
    }

    /// Aspect-fit image rect inside a view (Photo Library crop overlay).
    static func aspectFitDisplayedRect(imageSize: CGSize, viewSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0, viewSize.width > 0, viewSize.height > 0 else {
            return .zero
        }
        let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        return CGRect(
            x: (viewSize.width - width) / 2,
            y: (viewSize.height - height) / 2,
            width: width,
            height: height
        )
    }

    static func aspectFillDisplayedRect(imageSize: CGSize, viewSize: CGSize) -> CGRect {
        let scale = max(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        return CGRect(
            x: (viewSize.width - width) / 2,
            y: (viewSize.height - height) / 2,
            width: width,
            height: height
        )
    }
}
