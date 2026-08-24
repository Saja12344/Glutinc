import SwiftUI

struct IngredientCropView: View {
    let image: UIImage
    var onCancel: () -> Void
    var onConfirm: (UIImage) -> Void

    @State private var crop = CGRect(x: 0.08, y: 0.18, width: 0.84, height: 0.52)
    @State private var dragStart: CGRect?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(L10n.t("Select the ingredient list", ar: "حدد قائمة المكونات"))
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(L10n.t(
                    "Adjust the frame so the ingredient text fills most of the area.",
                    ar: "حرّك الإطار بحيث تملأ قائمة المكونات معظم المنطقة."
                ))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                GeometryReader { geo in
                    let fitted = ImageCoordinateMapper.aspectFitDisplayedRect(
                        imageSize: image.size,
                        viewSize: geo.size
                    )
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)

                        cropOverlay(in: fitted)
                            .gesture(cropGesture(in: fitted))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text(L10n.t("Cancel", ar: "إلغاء"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .background(Color.white.opacity(0.16))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    Button {
                        onConfirm(image.glutincCropped(toNormalized: crop))
                    } label: {
                        Text(L10n.t("Confirm", ar: "تأكيد"))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(AppColors.navy)
                            .background(AppColors.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func cropOverlay(in fitted: CGRect) -> some View {
        let rect = CGRect(
            x: fitted.minX + crop.origin.x * fitted.width,
            y: fitted.minY + crop.origin.y * fitted.height,
            width: crop.width * fitted.width,
            height: crop.height * fitted.height
        )
        return ZStack {
            Color.black.opacity(0.45)
                .mask(
                    Rectangle()
                        .overlay(
                            Rectangle()
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                                .blendMode(.destinationOut)
                        )
                )
                .compositingGroup()
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppColors.teal, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            ForEach(0..<4, id: \.self) { i in
                let x = i == 0 || i == 3 ? rect.minX : rect.maxX
                let y = i < 2 ? rect.minY : rect.maxY
                Circle()
                    .fill(AppColors.teal)
                    .frame(width: 18, height: 18)
                    .position(x: x, y: y)
            }
        }
        .allowsHitTesting(true)
    }

    private func cropGesture(in fitted: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard fitted.width > 1, fitted.height > 1 else { return }
                if dragStart == nil { dragStart = crop }
                let start = dragStart ?? crop
                let dx = value.translation.width / fitted.width
                let dy = value.translation.height / fitted.height
                let local = CGPoint(
                    x: (value.startLocation.x - fitted.minX) / fitted.width,
                    y: (value.startLocation.y - fitted.minY) / fitted.height
                )
                let handle: Handle = nearestHandle(local, in: start)
                var next = start
                switch handle {
                case .move:
                    next.origin.x = min(max(0, start.origin.x + dx), 1 - start.width)
                    next.origin.y = min(max(0, start.origin.y + dy), 1 - start.height)
                case .topLeft:
                    let maxX = start.maxX - 0.18
                    next.origin.x = min(max(0, start.origin.x + dx), maxX)
                    next.origin.y = min(max(0, start.origin.y + dy), start.maxY - 0.18)
                    next.size.width = start.maxX - next.origin.x
                    next.size.height = start.maxY - next.origin.y
                case .topRight:
                    next.origin.y = min(max(0, start.origin.y + dy), start.maxY - 0.18)
                    next.size.width = min(max(0.18, start.width + dx), 1 - start.origin.x)
                    next.size.height = start.maxY - next.origin.y
                case .bottomLeft:
                    next.origin.x = min(max(0, start.origin.x + dx), start.maxX - 0.18)
                    next.size.width = start.maxX - next.origin.x
                    next.size.height = min(max(0.18, start.height + dy), 1 - start.origin.y)
                case .bottomRight:
                    next.size.width = min(max(0.18, start.width + dx), 1 - start.origin.x)
                    next.size.height = min(max(0.18, start.height + dy), 1 - start.origin.y)
                }
                crop = next
            }
            .onEnded { _ in
                dragStart = nil
            }
    }

    private enum Handle {
        case move, topLeft, topRight, bottomLeft, bottomRight
    }

    private func nearestHandle(_ point: CGPoint, in rect: CGRect) -> Handle {
        let points: [(Handle, CGPoint)] = [
            (.topLeft, CGPoint(x: rect.minX, y: rect.minY)),
            (.topRight, CGPoint(x: rect.maxX, y: rect.minY)),
            (.bottomLeft, CGPoint(x: rect.minX, y: rect.maxY)),
            (.bottomRight, CGPoint(x: rect.maxX, y: rect.maxY))
        ]
        if let hit = points.first(where: { hypot($0.1.x - point.x, $0.1.y - point.y) < 0.08 }) {
            return hit.0
        }
        return .move
    }
}
