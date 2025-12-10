

import Foundation
import SwiftUI
import PhotosUI
import UIKit

struct SettingsView: View {
    @ObservedObject var vm: UserCloudVM

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

                    // MARK: General
                    SectionHeader(title: NSLocalizedString("General", comment: ""))

                    // Notifications toggle inline
                    HStack {
                        Label(NSLocalizedString("Notifications", comment: ""), systemImage: "bell")
                           // .foregroundStyle(.white)
                        Spacer()
                        Toggle("", isOn: $vm.user.notificationsEnabled)
                            .labelsHidden()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.card.opacity(0.55))     // ← darker
                           // .fill(.ultraThinMaterial)
                            //.overlay(
                            //    RoundedRectangle(cornerRadius: 16)
                              //      .stroke(Color.white.opacity(0.25), lineWidth: 1)  // subtle border
                           // )
                    )


                    // Edit name (opens popup)
                    SettingRow(icon: "pencil", title: NSLocalizedString("Edit Name", comment: "")) {
                        nameDraft = vm.user.name
                        showNamePopup = true
                    }

                    // Edit photo via PhotosPicker
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        HStack(spacing: 14) {
                            Image(systemName: "camera.circle")
                              //  .foregroundStyle(.white)
                                .font(.system(size: 18, weight: .medium))

                            Text(NSLocalizedString("Edit Profile Photo", comment: ""))
                               // .foregroundStyle(.white)

                            Spacer()

                            Image(systemName: "chevron.forward")
                                //.foregroundStyle(.white.opacity(0.5))
                                .flipsForRightToLeftLayoutDirection(true) // ← NEW
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16).fill(AppColors.card)
                              //  .fill(.ultraThinMaterial)
                        )
                    }
//                    .onChange(of: pickerItem) { _, newItem in
//                        guard let newItem else { return }
//                        Task {
//                            if let data = try? await newItem.loadTransferable(type: Data.self),
//                               let img = UIImage(data: data) {
//                                vm.updatePhoto(img)
//                            }
//                        }
//                    }
                    .onChange(of: pickerItem) { newItem in
                        guard let newItem else { return }
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let img = UIImage(data: data) {
                                vm.updatePhoto(img)
                            }
                        }
                    }

                    // MARK: About
                    SectionHeader(title: NSLocalizedString("About the App", comment: ""))
                    SettingRow(
                        icon: "info.circle",
                        title: NSLocalizedString("About", comment: "")
                    ) {
                        // افتحي صفحة "عن التطبيق" لاحقًا
                    }

                    // MARK: Danger Zone
                    SectionHeader(title: NSLocalizedString("Danger Zone", comment: ""))
                    SettingRow(icon: "trash",
                               title: NSLocalizedString("Delete Account", comment: ""),
                               tint: .red) {
                        showDeleteConfirm = true
                    }
                    SettingRow(icon: "arrowshape.turn.up.left",
                               title: NSLocalizedString("Sign Out", comment: ""),
                               tint: .red) {
                        showSignOutConfirm = true
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(NSLocalizedString("Settings", comment: ""))

        // Delete account confirm
        .confirmationDialog(NSLocalizedString("Are you sure?", comment: ""),
                            isPresented: $showDeleteConfirm,
                            titleVisibility: .visible) {
            Button(NSLocalizedString("Delete Account", comment: ""), role: .destructive) { /* delete */ }
            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
        }

        // Sign out confirm
        .alert(NSLocalizedString("Sign out?", comment: ""),
               isPresented: $showSignOutConfirm) {
            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("Sign Out", comment: ""), role: .destructive) { /* sign out */ }
        }

        // MARK: Name Edit Popup (custom alert-style editor)
        .overlay(
            Group {
                if showNamePopup {
                    ZStack {
                        // Dim background
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture { showNamePopup = false }

                        // Popup
                        VStack(spacing: 20) {
                            Text(NSLocalizedString("Edit Name", comment: ""))
                                .font(.system(size: 20, weight: .semibold))
                               // .foregroundStyle(.white)

                            TextField(NSLocalizedString("Your name", comment: ""), text: $nameDraft)
                                .padding()
                               // .background(Color.white.opacity(0.15))
                                .cornerRadius(12)
                                .foregroundStyle(.white)
                                .tint(.white)

                            HStack(spacing: 20) {
                                Button(NSLocalizedString("Cancel", comment: "")) {
                                    showNamePopup = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                                .foregroundStyle(.white)

                                Button(NSLocalizedString("Save", comment: "")) {
                                    vm.updateName(nameDraft)
                                    showNamePopup = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.8))
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
                    .animation(.easeInOut, value: showNamePopup)
                }
            }
        )
        .environment(\.layoutDirection,
                     Locale.preferredLanguages.first?.hasPrefix("ar") == true ? .rightToLeft : .leftToRight) // ← NEW

    }
}
