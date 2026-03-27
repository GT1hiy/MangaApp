import Foundation

@MainActor
class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    
    @Published var favorites: [Manga] = []
    
    private let favoritesKey = "favorite_mangas"
    
    private init() {
        loadFavorites()
    }
    
    func addToFavorites(manga: Manga) {
        if !favorites.contains(where: { $0.id == manga.id }) {
            favorites.append(manga)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(manga: Manga) {
        favorites.removeAll { $0.id == manga.id }
        saveFavorites()
    }
    
    func isFavorite(mangaId: Int) -> Bool {
        return favorites.contains { $0.id == mangaId }
    }
    
    func clearFavorites() {
        favorites.removeAll()
        saveFavorites()
    }
    
    private func saveFavorites() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favorites)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("Ошибка сохранения избранного: \(error)")
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            favorites = try decoder.decode([Manga].self, from: data)
        } catch {
            print("Ошибка загрузки избранного: \(error)")
        }
    }
}
