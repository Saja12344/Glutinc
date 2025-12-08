//
//  SettingsView.swift
//  Glutinc
//
//  Created by Deemah Alhazmi on 01/12/2025.


import SwiftUI
import PhotosUI
import UIKit

struct SettingsView: View {
    @ObservedObject var vm: UserVM

    // Name edit popup
    @State private var showNamePopup: Bool = false
    @State private var nameDraft: String = ""

    // Photos
    @State private var pickerItem: PhotosPickerItem?

    // Danger actions
    @State private var showDeleteConfirm: Bool = false
    @State private var showSignOutConfirm: Bool = false

    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    GeneralSection(vm: vm)

                    EditNameRow {
                        nameDraft = vm.user.name
                        showNamePopup = true
                    }

                    EditPhotoRow(pickerItem: $pickerItem) { image in
                        vm.updatePhoto(image)
                    }

                    AboutSection()

                    DangerSection(
                        deleteTapped: { showDeleteConfirm = true },
                        signOutTapped: { showSignOutConfirm = true }
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(NSLocalizedString("Settings", comment: ""))

        // Delete account confirm
        .confirmationDialog(
            NSLocalizedString("Are you sure?", comment: ""),
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("Delete Account", comment: ""), role: .destructive) { /* delete */ }
            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
        }

        // Sign out confirm
        .alert(NSLocalizedString("Sign out?", comment: ""), isPresented: $showSignOutConfirm) {
            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("Sign Out", comment: ""), role: .destructive) { /* sign out */ }
        }

        // Name Edit Popup (custom alert-style editor)
        .overlay(
            NamePopup(
                isShown: $showNamePopup,
                name: $nameDraft,
                onSave: { vm.updateName($0) }
            )
        )
        // Keep LTR/RTL behavior
        .environment(
            \.layoutDirection,
            Locale.preferredLanguages.first?.hasPrefix("ar") == true ? .rightToLeft : .leftToRight
        )
    }
}

//
// MARK: - Subviews (very small = easy for type-checker)
//

private struct GeneralSection: View {
    @ObservedObject var vm: UserVM

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: NSLocalizedString("General", comment: ""))

            HStack {
                Label(NSLocalizedString("Notifications", comment: ""), systemImage: "bell")
                    .foregroundStyle(Color.primary)

                Spacer()

                Toggle("", isOn: $vm.user.notificationsEnabled)
                    .labelsHidden()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.card.opacity(0.55)) // better contrast
            )
        }
    }
}

private struct EditNameRow: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "pencil")
                    .foregroundStyle(Color.primary)
                Text(NSLocalizedString("Edit Name", comment: ""))
                    .foregroundStyle(Color.primary)
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundStyle(Color.primary.opacity(0.5))
                    .flipsForRightToLeftLayoutDirection(true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.card)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(NSLocalizedString("Edit Name", comment: "")))
    }
}

private struct EditPhotoRow: View {
    @Binding var pickerItem: PhotosPickerItem?
    var onImage: (UIImage) -> Void

    var body: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            HStack(spacing: 14) {
                Image(systemName: "camera.circle")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: 18, weight: .medium))

                Text(NSLocalizedString("Edit Profile Photo", comment: ""))
                    .foregroundStyle(Color.primary)

                Spacer()

                Image(systemName: "chevron.forward")
                    .foregroundStyle(Color.primary.opacity(0.5))
                    .flipsForRightToLeftLayoutDirection(true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.card)
            )
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    onImage(img)
                }
            }
        }
    }
}

private struct AboutSection: View {
    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: NSLocalizedString("About the App", comment: ""))
            Button(action: {}) { // explicit empty action avoids overload issues
                HStack(spacing: 14) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color.primary)
                    Text(NSLocalizedString("About", comment: ""))
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(Color.primary.opacity(0.5))
                        .flipsForRightToLeftLayoutDirection(true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.card)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct DangerSection: View {
    var deleteTapped: () -> Void
    var signOutTapped: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: NSLocalizedString("Danger Zone", comment: ""))

            Button(action: deleteTapped) {
                HStack(spacing: 14) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                    Text(NSLocalizedString("Delete Account", comment: ""))
                        .foregroundStyle(.red)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.red.opacity(0.6))
                        .flipsForRightToLeftLayoutDirection(true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.card)
                )
            }
            .buttonStyle(.plain)

            Button(action: signOutTapped) {
                HStack(spacing: 14) {
                    Image(systemName: "arrowshape.turn.up.left")
                        .foregroundStyle(.red)
                    Text(NSLocalizedString("Sign Out", comment: ""))
                        .foregroundStyle(.red)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.red.opacity(0.6))
                        .flipsForRightToLeftLayoutDirection(true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.card)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct NamePopup: View {
    @Binding var isShown: Bool
    @Binding var name: String
    var onSave: (String) -> Void

    var body: some View {
        Group {
            if isShown {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { isShown = false }

                    VStack(spacing: 20) {
                        Text(NSLocalizedString("Edit Name", comment: ""))
                            .font(.headline)
                            .foregroundStyle(.white)

                        TextField(NSLocalizedString("Your name", comment: ""), text: $name)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(12)
                            .foregroundStyle(.white)
                            .tint(.white)

                        HStack(spacing: 20) {
                            Button(NSLocalizedString("Cancel", comment: "")) {
                                isShown = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundStyle(.white)

                            Button(NSLocalizedString("Save", comment: "")) {
                                onSave(name)
                                isShown = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.85))
                            .cornerRadius(10)
                            .foregroundStyle(.white)
                        }
                    }
                    .padding()
                    .frame(width: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 10)
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut, value: isShown)
            }
        }
    }
}
