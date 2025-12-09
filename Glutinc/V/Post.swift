//
//  Post.swift
//  Glutinc22
//

import SwiftUI
import PhotosUI
import CloudKit

struct Post: View {
    // Inject your UserVM so we can call createPost(...)
    @ObservedObject var vm: UserVM

    // If you still need SignInViewModel for categories/rating, keep it.
    // Otherwise we can move those into local @State:
    @StateObject private var signInVM = SignInViewModel()

    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var pickedItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var titleText: String = ""
    @State private var contentText: String = ""
    @State private var priceText: String = ""
    @State private var locationText: String = ""
    @State private var selectedCategory: String = ""
    @State private var isPosting = false
    @State private var showError = false

    let onPost: () -> Void

    var body: some View {
        ZStack {
            Color("Colorback").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Top bar
                    HStack {
                        ZStack {
                            Capsule()
                                .frame(width: 44, height: 44)
                                .foregroundStyle(Color("GlassColor"))
                                .glassEffect()

                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.primary)
                                    .font(.system(size: 18.64, weight: .medium))
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 20)

                    // Image picker
                    HStack { Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Colorpost"))
                                .frame(width: 180, height: 160)

                            if let img = pickedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                PhotosPicker(selection: $pickedItem, matching: .images, photoLibrary: .shared()) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 28, weight: .medium))
                                        Text("Add photo")
                                            .font(.footnote)
                                    }
                                    .foregroundStyle(.primary)
                                }
                            }
                        }
                        Spacer()
                    }
                    .onChange(of: pickedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let img = UIImage(data: data) {
                                pickedImage = img
                            }
                        }
                    }

                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.system(size: 18, weight: .bold))
                        TextField("Enter a short title", text: $titleText)
                            .padding(.horizontal, 10)
                            .frame(height: 41)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                            .textInputAutocapitalization(.sentences)
                    }
                    .foregroundStyle(.primary)

                    // Rating
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How was your product?")
                            .font(.system(size: 18, weight: .bold))
                        HStack(spacing: 10) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(star <= signInVM.rating ? .yellow : .gray.opacity(0.4))
                                    .onTapGesture { signInVM.updateRating(to: star) }
                            }
                        }
                    }
                    .foregroundStyle(.primary)

                    // Price
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How much?")
                            .font(.system(size: 18, weight: .bold))
                        TextField("Enter the price", text: $priceText)
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 10)
                            .frame(height: 41)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                    }
                    .foregroundStyle(.primary)

                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.system(size: 18, weight: .bold))
                        TextField("Where did you buy it?", text: $locationText)
                            .padding(.horizontal, 10)
                            .frame(height: 41)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                    }
                    .foregroundStyle(.primary)

                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.system(size: 18, weight: .bold))

                        Menu {
                            ForEach(signInVM.categories, id: \.self) { c in
                                Button {
                                    selectedCategory = c
                                } label: { Text(c) }
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory.isEmpty ? "Select Category" : selectedCategory)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(height: 41)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                        }
                    }
                    .foregroundStyle(.primary)

                    // Notes / content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.system(size: 18, weight: .bold))
                        TextField("Optional: taste, texture, etc.", text: $contentText, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                    }
                    .foregroundStyle(.primary)

                    // Post button
                    Button(action: submitPost) {
                        Text(isPosting ? "Posting..." : "Post")
                            .frame(width: 180, height: 42)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(uiColor: .label))
                            .glassEffect(.clear.tint(Color.btn.opacity(0.9)))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(isPosting || titleText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(vm.errorMessage ?? "Something went wrong.")
        })
        .onChange(of: vm.errorMessage) { _, new in
            if new != nil { showError = true }
        }
    }

    // MARK: - Actions

    private func submitPost() {
        Task {
            isPosting = true
            defer { isPosting = false }

            // Build a title that can include rating/price/category if you like
            let composedTitle = titleText.isEmpty
                ? (selectedCategory.isEmpty ? "Post" : selectedCategory)
                : titleText

            // Include some metadata in content (optional)
            var composedContent = contentText
            if !priceText.isEmpty { composedContent += "\nPrice: \(priceText)" }
            if !locationText.isEmpty { composedContent += "\nLocation: \(locationText)" }
            if signInVM.rating > 0 { composedContent += "\nRating: \(signInVM.rating)/5" }

            await vm.createPost(
                title: composedTitle,
                content: composedContent,
                image: pickedImage
            )

            if vm.errorMessage == nil {
                onPost()     // callback if parent wants to react
                dismiss()    // go back after successful post
            }
        }
    }
}

#Preview {
    // Example preview with a temporary VM
    Post(vm: UserVM(), onPost: {})
}
