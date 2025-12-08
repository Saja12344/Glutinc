//
//  AppGradient.swift
//  Glutinc
//
//  Created by Deemah Alhazmi on 01/12/2025.
//

import SwiftUI

struct AppGradient {
    static let background = LinearGradient(
        colors: [AppColors.softBlueTop, AppColors.softBlueBottom],
        startPoint: .top,
        endPoint: .bottom
    )
}
