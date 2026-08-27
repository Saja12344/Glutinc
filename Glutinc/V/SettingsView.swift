//
//
//import Foundation
//import SwiftUI
//import PhotosUI
//import UIKit
//
//struct SettingsView: View {
//    @ObservedObject var vm: UserCloudVM
//
//    // Name edit popup
//    @State private var showNamePopup: Bool = false
//    @State private var nameDraft: String = ""
//
//    // Photos
//    @State private var pickerItem: PhotosPickerItem?
//
//    // Danger actions
//    @State private var showDeleteConfirm: Bool = false
//    @State private var showSignOutConfirm: Bool = false
//
//    var body: some View {
//        ZStack {
//           
//            BackgroundView()
//            ScrollView {
//                VStack(spacing: 22) {
//
//                    // MARK: General
//                    SectionHeader(title: NSLocalizedString("General", comment: ""))
//
//                    // Notifications toggle inline
//                    HStack {
//                        Label(NSLocalizedString("Notifications", comment: ""), systemImage: "bell")
//                           // .foregroundStyle(.white)
//                        Spacer()
//                        Toggle("", isOn: $vm.user.notificationsEnabled)
//                            .labelsHidden()
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(AppColors.card.opacity(0.55))     // ← darker
//                           // .fill(.ultraThinMaterial)
//                            //.overlay(
//                            //    RoundedRectangle(cornerRadius: 16)
//                              //      .stroke(Color.white.opacity(0.25), lineWidth: 1)  // subtle border
//                           // )
//                    )
//
//
//                    // Edit name (opens popup)
//                    SettingRow(icon: "pencil", title: NSLocalizedString("Edit Name", comment: "")) {
//                        nameDraft = vm.user.name
//                        showNamePopup = true
//                    }
//
//                    // Edit photo via PhotosPicker
//                    PhotosPicker(selection: $pickerItem, matching: .images) {
//                        HStack(spacing: 14) {
//                            Image(systemName: "camera.circle")
//                              //  .foregroundStyle(.white)
//                                .font(.system(size: 18, weight: .medium))
//
//                            Text(NSLocalizedString("Edit Profile Photo", comment: ""))
//                               // .foregroundStyle(.white)
//
//                            Spacer()
//
//                            Image(systemName: "chevron.forward")
//                                //.foregroundStyle(.white.opacity(0.5))
//                                .flipsForRightToLeftLayoutDirection(true) // ← NEW
//                        }
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 16).fill(AppColors.card)
//                              //  .fill(.ultraThinMaterial)
//                        )
//                    }
////                    .onChange(of: pickerItem) { _, newItem in
////                        guard let newItem else { return }
////                        Task {
////                            if let data = try? await newItem.loadTransferable(type: Data.self),
////                               let img = UIImage(data: data) {
////                                vm.updatePhoto(img)
////                            }
////                        }
////                    }
//                    .onChange(of: pickerItem) { newItem in
//                        guard let newItem else { return }
//                        Task {
//                            if let data = try? await newItem.loadTransferable(type: Data.self),
//                               let img = UIImage(data: data) {
//                                vm.updatePhoto(img)
//                            }
//                        }
//                    }
//
//                    // MARK: About
//                    SectionHeader(title: NSLocalizedString("About the App", comment: ""))
//                    SettingRow(
//                        icon: "info.circle",
//                        title: NSLocalizedString("About", comment: "")
//                    ) {
//                        // افتحي صفحة "عن التطبيق" لاحقًا
//                    }
//
//                    // MARK: Danger Zone
//                    SectionHeader(title: NSLocalizedString("Danger Zone", comment: ""))
//                    SettingRow(icon: "trash",
//                               title: NSLocalizedString("Delete Account", comment: ""),
//                               tint: .red) {
//                        showDeleteConfirm = true
//                    }
//                    SettingRow(icon: "arrowshape.turn.up.left",
//                               title: NSLocalizedString("Sign Out", comment: ""),
//                               tint: .red) {
//                        showSignOutConfirm = true
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 40)
//            }
//        }
//        .navigationTitle(NSLocalizedString("Settings", comment: ""))
//
//        // Delete account confirm
//        .confirmationDialog(NSLocalizedString("Are you sure?", comment: ""),
//                            isPresented: $showDeleteConfirm,
//                            titleVisibility: .visible) {
//            Button(NSLocalizedString("Delete Account", comment: ""), role: .destructive) { /* delete */ }
//            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
//        }
//
//        // Sign out confirm
//        .alert(NSLocalizedString("Sign out?", comment: ""),
//               isPresented: $showSignOutConfirm) {
//            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
//            Button(NSLocalizedString("Sign Out", comment: ""), role: .destructive) { /* sign out */ }
//        }
//
//        // MARK: Name Edit Popup (custom alert-style editor)
//        .overlay(
//            Group {
//                if showNamePopup {
//                    ZStack {
//                        // Dim background
//                        Color.black.opacity(0.4)
//                            .ignoresSafeArea()
//                            .onTapGesture { showNamePopup = false }
//
//                        // Popup
//                        VStack(spacing: 20) {
//                            Text(NSLocalizedString("Edit Name", comment: ""))
//                                .font(.system(size: 20, weight: .semibold))
//                               // .foregroundStyle(.white)
//
//                            TextField(NSLocalizedString("Your name", comment: ""), text: $nameDraft)
//                                .padding()
//                               // .background(Color.white.opacity(0.15))
//                                .cornerRadius(12)
//                                .foregroundStyle(.white)
//                                .tint(.white)
//
//                            HStack(spacing: 20) {
//                                Button(NSLocalizedString("Cancel", comment: "")) {
//                                    showNamePopup = false
//                                }
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.white.opacity(0.1))
//                                .cornerRadius(10)
//                                .foregroundStyle(.white)
//
//                                Button(NSLocalizedString("Save", comment: "")) {
//                                    vm.updateName(nameDraft)
//                                    showNamePopup = false
//                                }
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.blue.opacity(0.8))
//                                .cornerRadius(10)
//                                .foregroundStyle(.white)
//                            }
//                        }
//                        .padding()
//                        .frame(width: 300)
//                        .background(
//                            RoundedRectangle(cornerRadius: 20)
//                                .fill(.ultraThinMaterial)
//                                .shadow(radius: 10)
//                        )
//                    }
//                    .transition(.opacity)
//                    .animation(.easeInOut, value: showNamePopup)
//                }
//            }
//        )
//        .environment(\.layoutDirection,
//                     Locale.preferredLanguages.first?.hasPrefix("ar") == true ? .rightToLeft : .leftToRight) // ← NEW
//
//    }
//}
import SwiftUI
import PhotosUI
import UIKit

struct SettingsView: View {

    @EnvironmentObject var vm: UserCloudVM
    @Environment(\.dismiss) private var dismiss

    @State private var showNamePopup = false
    @State private var nameDraft = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var showSignOutConfirm = false

    private var isAR: Bool {
        Locale.preferredLanguages.first?.hasPrefix("ar") == true
    }

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack(spacing: 12) {

                    // MARK: - General
                    SectioHeader(title: NSLocalizedString("General", comment: ""))

                    // Notifications
//                    HStack {
//                        Label(NSLocalizedString("Notifications", comment: ""),
//                              systemImage: "bell")
//                        .foregroundStyle(.primary)
//
//                        Spacer()
//
//                        Toggle("", isOn: $vm.user.notificationsEnabled)
//                            .labelsHidden()
//                    }
//                    .glassCard()

                    // Edit Name
                    Button {
                        nameDraft = vm.user.name
                        showNamePopup = true
                    } label: {
                        SettingRowContent(
                            icon: "pencil",
                            title: NSLocalizedString("Edit Name", comment: "")
                        )
                    }
                    .buttonStyle(.plain)


//                    // Edit Photo
//                    PhotosPicker(selection: $pickerItem, matching: .images) {
//                        SettingRowContent(
//                            icon: "camera.circle",
//                            title: NSLocalizedString("Edit Profile Photo", comment: "")
//                        )
//                    }
//                    .onChange(of: pickerItem) { newItem in
//                        guard let newItem else { return }
//                        Task {
//                            if let data = try? await newItem.loadTransferable(type: Data.self),
//                               let img = UIImage(data: data) {
//                                vm.updatePhoto(img)
//                            }
//                        }
//                    }

                    // MARK: - About & Legal
                    SectioHeader(title: L10n.t("About", ar: "حول التطبيق"))

                    if vm.isAdmin {
                        NavigationLink {
                            AdminModerationView()
                        } label: {
                            SettingRowContent(
                                icon: "shield.checkered",
                                title: L10n.t("Reports", ar: "البلاغات")
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    NavigationLink {
                        AboutGlutincView()
                    } label: {
                        SettingRowContent(
                            icon: "info.circle",
                            title: L10n.t("About", ar: "حول التطبيق")
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        LegalHubView()
                    } label: {
                        SettingRowContent(
                            icon: "building.columns",
                            title: L10n.t("Legal", ar: "قانوني")
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        SettingRowContent(
                            icon: "hand.raised.fill",
                            title: L10n.t("Privacy Policy", ar: "سياسة الخصوصية")
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        HealthDisclaimerView()
                    } label: {
                        SettingRowContent(
                            icon: "heart.text.clipboard",
                            title: L10n.t("Health Information", ar: "معلومات صحية")
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SupportView()
                    } label: {
                        SettingRowContent(
                            icon: "envelope",
                            title: L10n.t("Contact / Support", ar: "التواصل والدعم")
                        )
                    }
                    .buttonStyle(.plain)

                    // MARK: - Danger Zone
                    SectioHeader(title: NSLocalizedString("Danger Zone", comment: ""))
                        .tint(.rd)

                    NavigationLink {
                        BlockedUsersView()
                    } label: {
                        SettingRowContent(
                            icon: "person.slash",
                            title: L10n.t("Blocked accounts", ar: "الحسابات المحظورة")
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        showSignOutConfirm = true
                    } label: {
                        SettingRowContent(
                            icon: "arrowshape.turn.up.left",
                            title: NSLocalizedString("Sign Out", comment: ""),
                            tint: .red
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        DeleteAccountView()
                    } label: {
                        SettingRowContent(
                            icon: "trash.fill",
                            title: NSLocalizedString("Delete Account", comment: ""),
                            tint: .red
                        )
                    }
                    .buttonStyle(.plain)

                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(NSLocalizedString("Settings", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .environment(\.layoutDirection, isAR ? .rightToLeft : .leftToRight)

        // Sign out alert
        .alert(NSLocalizedString("Sign out?", comment: ""),
               isPresented: $showSignOutConfirm) {
            Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("Sign Out", comment: ""), role: .destructive) {
                vm.logout()
                dismiss()
                
        
            }
        }
        // Edit Name alert

       .alert("Edit Name", isPresented: $showNamePopup) {

            TextField("Your name", text: $nameDraft)

                   Button("Save") {
                       let trimmed = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                       if !trimmed.isEmpty {
                           vm.updateName(trimmed)
                       }
                   }

                   Button("Cancel", role: .cancel) {}

               }
    }
}
struct SectioHeader: View {

    let title: String
    var color: Color = .secondary

    var body: some View {
        Text(title)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 4)
            .padding(.bottom, 6)
    }
}


struct SettingRowContent: View {

    let icon: String
    let title: String
    var tint: Color = .primary

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)

            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(tint)

            Spacer()

            Image(systemName: "chevron.forward")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .flipsForRightToLeftLayoutDirection(true)
        }
        .padding()
      
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.card)
        )

    }
}
extension View {
    func glassCard() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
    }
}

struct BlockedUsersView: View {
    @EnvironmentObject var vm: UserCloudVM

    private var blockedIDs: [String] {
        vm.blockedUserIDs.sorted()
    }

    var body: some View {
        ZStack {
            BackgroundView()
            Group {
                if blockedIDs.isEmpty {
                    Text(L10n.t(
                        "Accounts you block appear here.",
                        ar: "تظهر هنا الحسابات التي تحظرها."
                    ))
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
                } else {
                    List {
                        ForEach(blockedIDs, id: \.self) { userId in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vm.displayName(forBlockedUserId: userId))
                                        .foregroundStyle(AppColors.textPrimary)
                                    Text(L10n.t("Blocked", ar: "محظور"))
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                Spacer()
                                Button {
                                    vm.unblockUser(userId: userId)
                                } label: {
                                    Text(L10n.t("Unblock", ar: "إلغاء الحظر"))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColors.teal)
                                }
                                .buttonStyle(.borderless)
                            }
                            .listRowBackground(AppColors.card)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle(L10n.t("Blocked accounts", ar: "الحسابات المحظورة"))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear { vm.loadModerationState() }
    }
}
