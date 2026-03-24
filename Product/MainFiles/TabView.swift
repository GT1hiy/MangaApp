import SwiftUI

struct TabView: View {
    @State private var selectedTab = 0
    @State var general = General()
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    MainPage(general: general)
                case 1:
                    FavoritePage(general: general)
                case 2:
                    if general.exit == false {
                        RegPage(general: general)
                                
                    } else {
                        LoginPage(general: general)
                    }
                //case 3:
                    //Notification()
                default:
                    MainPage(general: general)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            RoundedRectangle(cornerRadius: 30)
                 .fill(.ultraThinMaterial)
                 .opacity(0.7)
                 .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 10)
                 .padding(.horizontal, 15)
                 .padding(.bottom, -6)
                 .frame(height: 52)
            
            HStack(spacing: 0) {
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(selectedTab == 0 ? Color(red: 239/255, green: 191/255, blue: 4/255) : .white)
                        
                            .shadow(color: selectedTab == 0 ? Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                        
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
                                    Image(systemName: selectedTab == 0 ? "star.fill" : "star")
                                        .font(.system(size: 22))
                                )
                            )
                        
                        Text("Main")
                            .font(.caption2)
                            .foregroundStyle(selectedTab == 0 ? .yellow : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: { selectedTab = 1 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(selectedTab == 1 ? Color(red: 239/255, green: 191/255, blue: 4/255) : .white)
                        
                            .shadow(color: selectedTab == 1 ? Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                        
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
                                    Image(systemName: selectedTab == 0 ? "heart.fill" : "heart")
                                        .font(.system(size: 22))
                                )
                            )
                        
                        Text("Favorite")
                            .font(.caption2)
                            .foregroundStyle(selectedTab == 1 ? .yellow : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: { selectedTab = 3 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(selectedTab == 3 ? Color(red: 239/255, green: 191/255, blue: 4/255) : .white)
                        
                            .shadow(color: selectedTab == 3 ? Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                        
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
                                    Image(systemName: selectedTab == 3 ? "bell.fill" : "bell")
                                        .font(.system(size: 22))
                                )
                            )
                        
                        Text("Notification")
                            .font(.caption2)
                            .foregroundStyle(selectedTab == 3 ? .yellow : .white)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: { selectedTab = 2 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(selectedTab == 2 ? Color(red: 239/255, green: 191/255, blue: 4/255) : .white)
                        
                            .shadow(color: selectedTab == 2 ? Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5) : .clear, radius: 10, x: 0, y: 0)
                        
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
                                    Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                                        .font(.system(size: 22))
                                )
                            )
                        
                        Text("Profile")
                            .font(.caption2)
                            .foregroundStyle(selectedTab == 2 ? .yellow : .white)
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
        .alert("Выход", isPresented: $showLogoutAlert) {
            Button("OK", role: .cancel) {
            }
        } message: {
            Text("Вы успешно вышли из аккаунта")
        }
    }
}

#Preview {
    TabView()
}
