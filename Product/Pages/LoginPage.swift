//
//  LoginPage.swift
//  Product
//
//  Created by German Tihiy on 21.03.2026.
//
import SwiftUI

struct LoginPage: View {
    let general: General
    @State private var showWelcomeAlert = false    
    var body: some View {
        ZStack{
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
            VStack {
                Text("Hey, \(general.userEmail)!")
                    .foregroundColor(.white)
                    .font(.custom("HelveticaNeue-Medium", size: 40))
                    .bold()
            }
        }
        .onAppear {
            // Показываем alert при появлении страницы
            if !general.welcomeMessage.isEmpty {
                showWelcomeAlert = true
            }
        }
        .alert(isPresented: $showWelcomeAlert) {
            Alert(
                title: Text("Вход"),
                message: Text(general.welcomeMessage),
                dismissButton: .default(Text("OK")) {
                    general.welcomeMessage = ""
                }
            )
        }
    }
} 
