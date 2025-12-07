//
//  UserKit.swift
//  Glutinc
//
//  Created by Deemah Alhazmi on 01/12/2025.
//

import SwiftUI
import Combine          // <- needed for ObservableObject / @Published
import UIKit            // <- needed for UIImage
import PhotosUI

struct UserModel {
    var name: String = "Jasmin"
    var photo: UIImage? = nil                 // nil -> use placeholder asset "userPhoto"
    var savedImages: [String] = ["prod1","prod2"]
    var notificationsEnabled: Bool = true
}

final class UserVM: ObservableObject {
    @Published var user = UserModel()

    func updateName(_ new: String) {
        user.name = new.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func updatePhoto(_ image: UIImage?) {
        user.photo = image
    }
}
