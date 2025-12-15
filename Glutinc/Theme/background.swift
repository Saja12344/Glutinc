//
//  background.swift
//  Glutinc
//
//  Created by saja khalid on 24/06/1447 AH.
//

import Foundation
import SwiftUI
struct BackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.48, blue: 0.95)
                        .opacity(colorScheme == .dark ? 0.35 : 0.55),
                    .clear
                ],
                startPoint: .topTrailing,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
    }
}
