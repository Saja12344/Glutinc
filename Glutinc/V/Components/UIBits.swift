//
//  UIBits.swift
//  Glutinc
//
//  Created by Deemah Alhazmi on 01/12/2025.
//

import Foundation
import SwiftUI


struct SectionHeader: View {
    var title: String
    var color: Color = AppColors.textSecondary
    var body: some View {
        Text(title)
            .foregroundStyle(color)
            .font(.system(size: 18, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

struct SettingRow: View {
    var icon: String
    var title: String
    var tint: Color = .white
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(tint)

                Text(title)
                    .foregroundStyle(.textPrimary)

                Spacer()

                Image(systemName: "chevron.forward")
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.card)
            )
        }
    }
}

struct ProductCard: View {
    var imageName: String
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(AppColors.card)
            .frame(height: 150)
            .overlay(
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

enum GlutincLayout {
    static let contentMaxWidth: CGFloat = 720
}

extension View {
    /// Keeps phone layouts readable on iPad instead of stretching edge to edge.
    func glutincContentWidth() -> some View {
        frame(maxWidth: GlutincLayout.contentMaxWidth)
            .frame(maxWidth: .infinity)
    }
}

/// Fixed photo well so every product image sits in the same frame.
struct ProductPhotoFrame: View {
    let image: UIImage
    var ratio: CGFloat = 4 / 3
    var cornerRadius: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .aspectRatio(ratio, contentMode: .fit)
        .background(AppColors.navy3)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(AppColors.border, lineWidth: 1)
        )
    }
}
