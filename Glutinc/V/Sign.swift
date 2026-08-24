//
//  Sign.swift
//  Glutinc22
//
//  Created by Norah Masoud Aloqayli on 17/06/1447 AH.
//


import SwiftUI
import AuthenticationServices

struct Signup: View {

        @EnvironmentObject var vm: UserCloudVM
        @Environment(\.dismiss) private var dismiss

        var body: some View {

            VStack(spacing: 30) {

                Text("Sign up for sharing with people")
                    .font(.system(size: 27, weight: .bold))

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        vm.handleSignIn(result: result)
                        
                        // ✅ 2) نقفل البوب-أب بعد نجاح التسجيل
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()}}
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)

                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .frame(width: 372, height: 329)
//            .background(Color("Colorback"))
            .cornerRadius(20)
            .multilineTextAlignment(.center)
            
        }
    }

//#Preview {
//    Signup()
//}
