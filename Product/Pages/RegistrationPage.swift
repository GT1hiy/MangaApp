//
//  RegistrationPage.swift
//  Product
//
//  Created by German Tihiy on 24.03.2026.
//

import SwiftUI

struct RegistrationPage: View {
    @State var info = regInfo()
    var general: General
    
    var body: some View {
        
        ZStack{
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Регистрация")
                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                    .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.9), radius: 35, x: 0, y: 5)
                    .overlay(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .clear,
                                .white.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Text("Регистрация")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, 20)
                        )
                    )
                
                
                VStack(alignment: .leading) {
                    TextField("Введите логин", text: $info.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .colorScheme(.light)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading) {
                    SecureField("Введите пароль", text: $info.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .colorScheme(.light)
                    
                }
                
                VStack(alignment: .leading) {
                    SecureField("Повторите пароль", text: $info.repeatPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .colorScheme(.light)
                    
                }
                
                // Кнопка входа
                Button(action: {
                    registerButtonTapped()
                }) {
                    Text("Войти")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: 100)
                        .padding()
                        .background(Color(red: 239/255, green: 191/255, blue: 4/255))
                        .cornerRadius(20)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.4),
                                    .clear,
                                    .white.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )).cornerRadius(30)
                    
                        .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5), radius: 10, x: 0, y: 0)
                    
                }
                .padding(.top, 20)
                
                Button("У меня есть аккаунт") {
                    general.reg = false
                }
                .foregroundStyle(Color(red: 239/255, green: 191/255, blue: 4/255))
                .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5), radius: 10, x: 0, y: 0)
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.6),
                            .clear,
                            .white.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Text("У меня есть аккаунт")
                    )
                    .allowsHitTesting(false)
                )
                .padding(.top, 10)
                
                
            }
            .padding(.horizontal, 50)
            .padding(.top, -105)
        }
        .alert(isPresented: $info.showingAlert) {
            Alert(
                title: Text("Регистрация"),
                message: Text(info.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func registerButtonTapped() {
        if info.email.isEmpty || info.password.isEmpty || info.repeatPassword.isEmpty {
            info.showingAlert = true
            info.alertMessage = "Заполните все поля"
        } else if info.password != info.repeatPassword {
            info.showingAlert = true
            info.alertMessage = "Пароли не совпадают"
        } else {
            general.welcomeMessage = "Добро пожаловать, \(info.email)!"
            general.userEmail = info.email
            general.exit = true
            general.reg = false
            
            info.showingAlert = true
            info.alertMessage = "Регистрация успешно завершена!"
        }
    }
}

#Preview {
    RegistrationPage(general: General())
}


