//
//  GlutincApp.swift
//  Glutinc
//
//  Created by saja khalid on 10/06/1447 AH.
//

import SwiftUI

// App entry point. Presents the main view when the app launches.
@main
struct GlutincApp: App {
    var body: some Scene {
        WindowGroup {
            // TODO: Replace with your primary view (e.g., CameraView or a dedicated scanner view)
            // The referenced GlutenScannerView is not included in the provided files.
            CameraView()
        }
    }
}

