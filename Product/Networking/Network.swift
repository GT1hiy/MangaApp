import Foundation
import SwiftUI

@MainActor
class MangaService: ObservableObject {
    @Published var mangas: [Manga] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMore = true
    
    private var currentPage = 1
    private var currentTask: Task<Void, Never>?
    
    func loadMangas(reset: Bool = false) {
        // Отменяем предыдущий запрос
        currentTask?.cancel()
        
        if reset {
            currentPage = 1
            mangas = []
            hasMore = true
            errorMessage = nil
        }
        
        guard !isLoading && hasMore else { return }
        
        currentTask = Task {
            isLoading = true
            
            let url = URL(string: "https://graphql.anilist.co")!
            let query = """
            {
              Page(page: \(currentPage), perPage: 20) {
                pageInfo {
                  hasNextPage
                }
                media(type: MANGA, sort: POPULARITY_DESC) {
                  id
                  title {
                    romaji
                    english
                  }
                  description(asHtml: false)
                  coverImage {
                    large
                  }
                  status
                  chapters
                  volumes
                }
              }
            }
            """
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: ["query": query])
            request.timeoutInterval = 30
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                // Проверяем, не отменена ли задача
                try Task.checkCancellation()
                
                let result = try JSONDecoder().decode(AniListResponse.self, from: data)
                let newMangas = result.data.Page.media
                
                if reset {
                    self.mangas = newMangas
                } else {
                    self.mangas.append(contentsOf: newMangas)
                }
                
                // Проверяем, есть ли следующая страница
                self.hasMore = result.data.Page.pageInfo?.hasNextPage ?? false
                self.currentPage += 1
                self.isLoading = false
                
            } catch is CancellationError {
                // Запрос был отменен — ничего не делаем
                self.isLoading = false
                return
            } catch {
                print("Ошибка: \(error)")
                self.errorMessage = "Не удалось загрузить. Проверь интернет."
                self.isLoading = false
            }
        }
    }
}

// MARK: - Models
struct AniListResponse: Codable {
    let data: DataClass
}

struct DataClass: Codable {
    let Page: PageContainer
}

struct PageContainer: Codable {
    let pageInfo: PageInfo?
    let media: [Manga]
}

struct PageInfo: Codable {
    let hasNextPage: Bool
}

struct Manga: Codable, Identifiable {
    let id: Int
    let title: Title
    let description: String?
    let coverImage: CoverImage?
    let status: String?
    let chapters: Int?
    let volumes: Int?
    
    var displayTitle: String {
        title.english ?? title.romaji ?? "Unknown"
    }
    
    var displayDescription: String {
        description?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) ?? "No description"
    }
    
    var displayStatus: String {
        switch status {
        case "RELEASING": return "Выходит"
        case "FINISHED": return "Завершено"
        case "HIATUS": return "На паузе"
        case "CANCELLED": return "Отменено"
        default: return status ?? "Неизвестно"
        }
    }
}

struct Title: Codable {
    let romaji: String?
    let english: String?
}

struct CoverImage: Codable {
    let large: String?
}

struct MangaDexSearchResponse: Codable {
    let data: [MangaDexManga]
}

struct MangaDexManga: Codable {
    let id: String
}

extension MangaService {
    func searchMangaDexId(title: String) async -> String? {
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.mangadex.org/manga?title=\(encodedTitle)&limit=1"
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("MangaReader/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(MangaDexSearchResponse.self, from: data)
            return response.data.first?.id
        } catch {
            print("Ошибка поиска ID: \(error)")
            return nil
        }
    }
}
