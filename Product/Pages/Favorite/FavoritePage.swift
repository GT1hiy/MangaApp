import SwiftUI

struct FavoritePage: View {
    let general: General
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
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
            ZStack {
                Color(red: 28/255, green: 28/255, blue: 28/255)
                    .ignoresSafeArea()
                
                if !general.exit {
                    VStack(spacing: 16) {
                        Image(systemName: "person.slash")
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
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredFavorites) { manga in
                                MangaRowView(manga: manga, general: general)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Избранное")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbarBackground(.hidden, for: .navigationBar)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Поиск в избранном")
            .onSubmit(of: .search) {
                isSearchFocused = false
            }
        }
    }
}
