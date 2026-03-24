//
//  MenuBar.swift
//  Product
//
//  Created by German Tihiy on 24.03.2026.
//

import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let action: () -> Void
}

// Основной класс для управления состоянием меню
@Observable
class MenuState {
    var isShowing = false
    
    func toggle() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isShowing.toggle()
        }
    }
    
    func hide() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isShowing = false
        }
    }
}

struct HamburgerButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Три полоски
                Rectangle()
                    .fill(Color(.white))
                    .frame(width: 25, height: 2.5)
                    .cornerRadius(1)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: 25, height: 2.5)
                    .cornerRadius(1)
                
                Rectangle()
                    .fill(.white)
                    .frame(width: 25, height: 2.5)
                    .cornerRadius(1)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .pressAction {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

// Расширение для обработки нажатий
extension View {
    func pressAction(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

struct SideMenuView: View {
    @Bindable var menuState: MenuState
    let general: General
    let onLogout: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Затемненный фон
            Color.black.opacity(menuState.isShowing ? 0.5 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    menuState.hide()
                }
            
            // Само меню
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    // Шапка меню с информацией о пользователе
                    if general.exit {
                        // Пользователь авторизован
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(general.userEmail)
                                    .font(.custom("Montserrat-Medium", size: 16))
                                    .foregroundColor(.white)
                                
                                Text("Добро пожаловать!")
                                    .font(.custom("Montserrat-Regular", size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 60)
                    } else {
                        // Пользователь не авторизован
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Не авторизован")
                                .font(.custom("Montserrat-Medium", size: 16))
                                .foregroundColor(.white)
                            
                            Text("Войдите, чтобы продолжить")
                                .font(.custom("Montserrat-Regular", size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 20)
                        .padding(.top, 60)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Пункты меню
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            MenuItemView(icon: "star.fill", title: "Главная") {
                                menuState.hide()
                                general.selectedTab = 0
                            }
                            
                            MenuItemView(icon: "heart.fill", title: "Избранное") {
                                menuState.hide()
                                general.selectedTab = 1
                            }
                            
                            MenuItemView(icon: "bell.fill", title: "Уведомления") {
                                menuState.hide()
                                general.selectedTab = 3
                            }
                            
                            MenuItemView(icon: "person.fill", title: "Профиль") {
                                menuState.hide()
                                general.selectedTab = 2
                            }
                            
                            MenuItemView(icon: "gearshape.fill", title: "Настройки") {
                                menuState.hide()
                                // Переход в настройки
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    
                    Spacer()
                    
                    // Кнопка выхода (показываем только если авторизован)
                    if general.exit {
                        Button(action: {
                            menuState.hide()
                            onLogout()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18))
                                Text("Выйти")
                                    .font(.custom("Montserrat-Medium", size: 16))
                                Spacer()
                            }
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.bottom, 40)
                    }
                }
                .padding(.horizontal, 25)
                .frame(width: UIScreen.main.bounds.width * 0.75)
                .background(
                    Color(red: 28/255, green: 28/255, blue: 28/255)
                        .ignoresSafeArea()
                )
                .offset(x: menuState.isShowing ? 0 : -UIScreen.main.bounds.width * 0.75)
                
                Spacer()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: menuState.isShowing)
    }
}

// Компонент для пункта меню
struct MenuItemView: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 25)
                
                Text(title)
                    .font(.custom("Montserrat-Medium", size: 16))
                
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
        }

    }
}

struct SideMenuModifier: ViewModifier {
    @State private var menuState = MenuState()
    let general: General
    let onLogout: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .overlay(
                    
                    // Кнопка-гамбургер в правом верхнем углу
                    VStack {
                        HStack {
                            Spacer()
                            HamburgerButton {
                                menuState.toggle()
                            }
                            .padding(.trailing, 20)
                            .padding(.top, 15)
                        }
                        Spacer()
                        
                    }
                )
            
            // Выдвижное меню
            SideMenuView(menuState: menuState, general: general, onLogout: onLogout)
        }
    }
}

extension View {
    func withSideMenu(general: General, onLogout: @escaping () -> Void) -> some View {
        modifier(SideMenuModifier(general: general, onLogout: onLogout))
    }
}

#Preview{
    MainTabView()
}
