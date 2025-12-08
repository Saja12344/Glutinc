//
//  test.swift
//  Glutinc22
//
//  Created by Norah Masoud Aloqayli on 17/06/1447 AH.
//

import SwiftUI

struct Post: View {
    @StateObject var viewModel = SignInViewModel()
    @State private var amount: String = ""
    let onPost: () -> Void
    
    var body: some View {
        ZStack {
            Color("Colorback")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // زر العودة
                HStack {
                    ZStack {
                        Capsule()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(Color("GlassColor"))
                            .glassEffect()
                        
                        Button {
                            // action
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 18.64, weight: .medium))
                        }
                    }
                    Spacer()
                }
                .padding(.top, 20)
                
                HStack {
                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Colorpost"))
                            .frame(width: 147, height: 137)
                        
                        Button {
                            // action
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                                .font(.system(size: 25, weight: .medium))
                        }
                    }

                    Spacer()

                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("How was your product?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: "star.fill")
                                .font(.system(size: 30))
                                .foregroundColor(star <= viewModel.rating ? .yellow : .gray.opacity(0.4))
                                .onTapGesture {
                                    viewModel.updateRating(to: star)
                                }
                        }
                    }
                }
                

                VStack(alignment: .leading, spacing: 8) {
                    Text("How much?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    TextField("Enter the price", text: $amount)
                        .font(.system(size: 18))
                            .padding(.horizontal, 10)
                            .frame(height: 41)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    TextField("Enter the price", text: $amount)
                        .font(.system(size: 18))
                            .padding(.horizontal, 10)
                            .frame(height: 41)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    TextField("Enter the price", text: $amount)
                        .font(.system(size: 18))
                            .padding(.horizontal, 10)
                            .frame(height: 41)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 1)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Menu {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button {
                                viewModel.selectedCategory = category
                            } label: {
                                Text(category)
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCategory.isEmpty ? "Select Category" : viewModel.selectedCategory)
                                .foregroundColor(.gray)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(height: 41)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                    }
                }
                 
                Button(action:onPost ) {
                    Text("Post")
                        .frame(width: 180, height: 42)  // أعرض شوي
                        .fontWeight(.bold)
                        .foregroundStyle(Color(uiColor: .label))
                        .glassEffect(.clear.tint(Color.btn.opacity(0.9))) // ✅ نفس أسلوبك تمامًا
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    Post(onPost: {})
}

