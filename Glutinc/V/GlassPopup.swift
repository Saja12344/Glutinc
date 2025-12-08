//
//  GlassPopup.swift
//  Glutinc
//
//  Created by saja khalid on 17/06/1447 AH.
//


import SwiftUI

struct GlassPopup<Content: View>: View {
    let title: String
    let content: Content
    let confirmTitle: String
    let confirmColor: Color
    let onConfirm: () -> Void
    let onCancel: () -> Void

    init(
        title: String,
        confirmTitle: String = "تأكيد",
        confirmColor: Color = .red,
        @ViewBuilder content: () -> Content,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.confirmTitle = confirmTitle
        self.confirmColor = confirmColor
        self.content = content()
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                // ✅ لون عنوان البوب أب
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)

                content

                HStack(spacing: 16) {
                    Button("إلغاء", action: onCancel)
                        .foregroundStyle(.gray)

                    Button(confirmTitle, action: onConfirm)
                        .foregroundStyle(confirmColor)
                }
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(radius: 25)
            .padding(.horizontal, 40)
        }
    }
}
