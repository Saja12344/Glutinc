
import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var cloudVM: UserCloudVM
    @State private var searchText: String = ""
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedCategory: ProductCategory? = nil
    @Environment(\.layoutDirection) private var layoutDirection

    
    // ✅ فلترة صحيحة 100% على ProductModel
    var filteredProducts: [ProductModel] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cloudVM.products.filter { product in
            
            let matchesSearch =
            q.isEmpty ||
            product.productName.localizedCaseInsensitiveContains(q) ||
            product.username.localizedCaseInsensitiveContains(q) ||
            product.location.localizedCaseInsensitiveContains(q) ||
            product.category.localizedCaseInsensitiveContains(q)
            
            let matchesCategory =
            selectedCategory == nil ||
            product.category == selectedCategory?.rawValue
            
            return matchesSearch && matchesCategory
        }
    }
    
    enum ProductCategory: String, CaseIterable, Identifiable {
        case grains = "Grains & Flours"
        case dairy = "Dairy"
        case drinks = "Drinks"
        case meat = "Meat & Alternatives"
        case others = "Others"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(colorScheme == .dark ? .black : .white)
                    .ignoresSafeArea()
                
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.48, blue: 0.95).opacity(
                            colorScheme == .dark ? 0.35 : 0.55
                        ),
                        Color.clear
                    ],
                    startPoint: .topTrailing,
                    endPoint: .center
                )
                .ignoresSafeArea()
                VStack {
                   

                    // 🔹 Categories
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            
                            // All Button
                            Button {
                                selectedCategory = nil
                            } label: {
                                Text("All")
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == nil ? .btn : .gray.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                            }
                            
                            ForEach(ProductCategory.allCases) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    Text(category.rawValue)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedCategory == category
                                            ? .blue
                                            : .gray.opacity(0.2)
                                        )
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 16)   // 👈 نفس الفيد
                        .padding(.top, 6)
                        .padding(.bottom, 12)
                    }
                    
                    // 🔹 Feed
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            
                            ForEach(filteredProducts) { product in
                                PostRow(post: product)
                            }
                            
                            if filteredProducts.isEmpty {
                                Text("No products yet")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal, 16)   // 👈 نفس القيمة
                    }
                }}
            .navigationTitle("Explore")
                .searchable(text: $searchText, prompt: "Search")
                .onAppear {
                    print("🏠 Home appeared – loading products")
                    cloudVM.loadProductsFromCloud()
                }
            }
        }
    private struct PostRow: View {
        
        let post: ProductModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                          .overlay(
                              RoundedRectangle(cornerRadius: 16)
                                  .stroke(Color.white.opacity(0.25), lineWidth: 1)
                          )                        .frame(height: 180)
                        .cornerRadius(16)
                    
                    Image(uiImage: post.image)
                        .resizable()
                             .scaledToFill()
                             .frame(height: 180)
                             .clipped()
                             .cornerRadius(16)
                    
                    HStack {
                        Spacer()
                        
                        Text(post.isGlutenFree ? "Gluten-Free" : "Contains Gluten")
                            .font(.caption2)
                            .padding(.horizontal, )
                            .padding(.vertical, 4)
                            .background(post.isGlutenFree ? .grn : .rd)
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                        
                            .padding(.top,160)
                    }
                }
                
                Text(post.productName)
                    .font(.headline)
                
                HStack {
                    Text("@\(post.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", post.rating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("💰 \(post.price)")
                    Spacer()
                    Text("📍 \(post.location)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
               
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
            )
        }
    }}
#Preview {
    HomeView()
}
