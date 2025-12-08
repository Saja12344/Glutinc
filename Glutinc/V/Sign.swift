//
//  Sign.swift
//  Glutinc22
//
//  Created by Norah Masoud Aloqayli on 17/06/1447 AH.
//


import SwiftUI
import AuthenticationServices

struct Signup: View {
    @StateObject private var viewModel = SignInViewModel()
    
    var body: some View {
        
            VStack(spacing: 30) {
                
                AppGradient.background.ignoresSafeArea()
                
                Text("Sign up for sharing with people")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundColor(.black)
                
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        viewModel.handleSignIn(result: result)
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)
                
                // ⁠عرض بيانات المستخدم بعد نجاح تسجيل الدخول
            //   if let user = viewModel.user {
                 //   VStack(spacing: 5) {
                    //    Text("Apple ID: \(user.id)")
                    //   Text("Name: \(user.name)")
                    //   Text("Email: \(user.email)")
            //       }
               //    .font(.system(size: 15))
                //   .foregroundColor(.gray)
         //       }
                
                // ⁠عرض الخطأ لو فيه مشكلة
                if !viewModel.errorMessage.isEmpty {
                    Text("Error: \(viewModel.errorMessage)")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .frame(width: 372, height: 329)
            .background(Color("Colorback"))
            .cornerRadius(20)
            .multilineTextAlignment(.center)
        }
}

#Preview {
    Signup()
}
