//
//  LogoutButton.swift
//  Product
//
//  Created by German Tihiy on 22.03.2026.
//
import SwiftUI

struct LogoutButton: View {
    let general: General
    let onLogout: () -> Void
    @State private var showConfirmAlert = false
    
    var body: some View {
        Button(action: {
            logout()
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 17))
                Text("Выйти")
                    .font(.custom("Montserrat-Medium", size: 15))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(red: 239/255, green: 191/255, blue: 4/255))
            .cornerRadius(20)
            .overlay(
                LinearGradient(
                    colors: [
                        .white.opacity(0.8),
                        .clear,
                        .white.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask(
                    HStack{
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 17))
                        Text("Выйти")
                            .font(.custom("Montserrat-Medium", size: 15))
                    }
                    
                )
            )
            
            
            .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5), radius: 10, x: 0, y: 0)

        }
        .alert("Подтверждение выхода", isPresented: $showConfirmAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Выйти", role: .destructive) {
                logout()
            }
        } message: {
            Text("Вы уверены, что хотите выйти?")
        }
    }
    
    func logout() {
        general.exit = false
        general.userEmail = ""
        general.welcomeMessage = ""
        onLogout() // вызываем замыкание для дополнительных действий
    }
}

struct LogoutButtonModifier: ViewModifier {
    let general: General
    let onLogout: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    HStack {
                        // Ник пользователя слева
                        if general.exit == true && !general.userEmail.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 19.5))
                                    .foregroundColor(.white)
                                
                                Text(general.userEmail)
                                    .font(.custom("Montserrat-Medium", size: 15))
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            
                            .padding(.vertical, 8)
                            .frame(height: 36)
                            .background(Color(red: 239/255, green: 191/255, blue: 4/255))
                            .cornerRadius(20)
                            .padding(.leading, 20)
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.8),
                                        .clear,
                                        .white.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ).mask(
                                    Text(general.userEmail)
                                        .font(.custom("Montserrat-Medium", size: 14))
                                        .lineLimit(1)
                                        .foregroundColor(.white)
                                )
                            )
                            
                            
                            .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5), radius: 10, x: 0, y: 0)
            
                        }
                        
                        Spacer()
                        
                        // Кнопка выхода справа
                        if general.exit == true {
                            LogoutButton(general: general, onLogout: onLogout)
                                .frame(height: 36)
                                .padding(.trailing, 20)
                        }
                    }
                    .padding(.top, 10)
                    Spacer()
                }
            )
    }
}

extension View {
    func withLogoutButton(general: General, onLogout: @escaping () -> Void) -> some View {
        modifier(LogoutButtonModifier(general: general, onLogout: onLogout))
    }
}

#Preview {
    TabView()
}
