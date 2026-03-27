import SwiftUI

struct FavoritePage: View {
    let general: General
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var searchText = ""
    @State private var isSearchActive = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    
    var filteredFavorites: [Manga] {
        if searchText.isEmpty {
            return favoriteManager.favorites
        } else {
            return favoriteManager.favorites.filter { manga in
                manga.displayTitle.localizedCaseInsensitiveContains(searchText) ||
                manga.title.english?.localizedCaseInsensitiveContains(searchText) == true ||
                manga.title.romaji?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Фон
                Color(red: 28/255, green: 28/255, blue: 28/255)
                    .ignoresSafeArea()
                    .brightness(isSearchActive ? -0.15 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isSearchActive)
                
                // Контент
                VStack(spacing: 0) {
                    // Кастомная поисковая строка
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 17))
                            
                            TextField("Поиск в избранном", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .focused($isTextFieldFocused)
                                .onChange(of: isTextFieldFocused) { oldValue, newValue in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isSearchActive = newValue
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 15))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(red: 38/255, green: 38/255, blue: 38/255))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isTextFieldFocused ? Color(red: 239/255, green: 191/255, blue: 4/255) : Color.clear, lineWidth: 1)
                        )
                        
                        if isSearchActive {
                            Button("Отмена") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isSearchActive = false
                                    isTextFieldFocused = false
                                    searchText = ""
                                }
                            }
                            .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(Color(red: 28/255, green: 28/255, blue: 28/255))
                    
                    // Основной контент
                    if !general.exit {
                        VStack(spacing: 16) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Войдите в аккаунт")
                                .foregroundColor(.gray)
                            Text("Чтобы видеть избранное, нужно авторизоваться")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if favoriteManager.favorites.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Нет избранных манг")
                                .foregroundColor(.gray)
                            Text("Добавляйте мангу в избранное, нажимая на сердечко")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        favoritesListView
                    }
                }
                
                // Затемненный фон для закрытия поиска
                if isSearchActive {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isSearchActive = false
                                isTextFieldFocused = false
                                searchText = ""
                            }
                        }
                        .zIndex(-1)
                }
            }
            .navigationTitle("Избранное")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeInOut(duration: 0.25)) {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
    }
    
    private var favoritesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredFavorites) { manga in
                    MangaRowView(manga: manga, general: general)
                        .opacity(isSearchActive ? 0.5 : 1)
                        .animation(.easeInOut(duration: 0.3), value: isSearchActive)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .padding(.bottom, keyboardHeight)
        }
        .refreshable {
            // Обновление избранного (если нужно)
        }
        .scrollDisabled(isSearchActive)
    }
}

#Preview {
    FavoritePage(general: General())
}
