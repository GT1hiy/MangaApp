//
//  General.swift
//  Product
//
//  Created by German Tihiy on 21.03.2026.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var general = General()
    @State private var showLogoutAlert = false
    @StateObject private var favoriteManager = FavoriteManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch general.selectedTab {
                case 0:
                    MangaFeedView(general: general)
                case 1:
                    FavoritePage(general: general)
                case 2:
                    if general.exit {
                    LoginPage(general: general)
                    } else {
                        if general.reg {
                            RegistrationPage(general: general)
                        } else {
                            RegPage(general: general)
                        }
                    }
                case 3:
                    NotifPage(general: general)
                default:
                    MainPage(general: general)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            RoundedRectangle(cornerRadius: 30)
                 .fill(.ultraThinMaterial)
                 .opacity(0.7)
                 .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 10)
                 .padding(.horizontal, 12)
                 .padding(.bottom, -6)
                 .frame(height: 52)
                 .preferredColorScheme(.dark)
            
            HStack(spacing: 0) {
                Button(action: { general.selectedTab = 0 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(general.selectedTab == 0 ? Color(red: 239/255, green: 191/255, blue: 4/255) : .white)
                        
                            .shadow(color: general.selectedTab == 0 ? Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                        
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.9),
                                        .clear,
                                        .white.opacity(0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .mask(
                                    Image(systemName: general.selectedTab == 0 ? "star.fill" : "star")
                                        .font(.system(size: 22))
                                )
                            )
                        
                        Text("Главная")
                            .font(.caption2)
                            .foregroundStyle(general.selectedTab == 0 ? .yellow : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: { general.selectedTab = 1 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(general.selectedTab == 1 ? Color(red: 239/255, green: 191/255, blue: 4/255) : .white)
                        
                            .shadow(color: general.selectedTab == 1 ? Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                        
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.9),
                                        .clear,
                                        .white.opacity(0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .mask(
                                    Image(systemName: general.selectedTab == 0 ? "heart.fill" : "heart")
                                        .font(.system(size: 22))
                                )
                            )
                        
                        Text("Избранное")
                            .font(.caption2)
                            .foregroundStyle(general.selectedTab == 1 ? .yellow : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: { general.selectedTab = 3 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(general.selectedTab == 3 ? Color(red: 239/255, green: 191/255, blue: 4/255) : .white)
                        
                            .shadow(color: general.selectedTab == 3 ? Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                        
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.9),
                                        .clear,
                                        .white.opacity(0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .mask(
                                    Image(systemName: general.selectedTab == 3 ? "bell.fill" : "bell")
                                        .font(.system(size: 22))
                                )
                            )
                        
                        Text("Уведомления")
                            .font(.caption2)
                            .foregroundStyle(general.selectedTab == 3 ? .yellow : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: { general.selectedTab = 2 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(general.selectedTab == 2 ? Color(red: 239/255, green: 191/255, blue: 4/255) : .white)
                        
                            .shadow(color: general.selectedTab == 2 ? Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                        
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.9),
                                        .clear,
                                        .white.opacity(0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .mask(
                                    Image(systemName: general.selectedTab == 2 ? "person.fill" : "person")
                                        .font(.system(size: 22))
                                )
                            )
                        
                        Text("Профиль")
                            .font(.caption2)
                            .foregroundStyle(general.selectedTab == 2 ? .yellow : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: general.exit) { oldValue, newValue in
            if newValue == false {
                showLogoutAlert = true
            }
        }
        .withSideMenu(general: general) {
                   // Действие при выходе
                   general.exit = false
                   general.userEmail = ""
                   general.welcomeMessage = ""
                   general.reg = false
                   showLogoutAlert = true
               }
        .alert("Выход", isPresented: $showLogoutAlert) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text("Вы успешно вышли из аккаунта")
        }
    }
}

#Preview {
    MainTabView()
}
