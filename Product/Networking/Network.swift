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
    private var retryCount = 0
    private let maxRetries = 2
    
    func loadMangas(reset: Bool = false) {
        currentTask?.cancel()
        
        if reset {
            currentPage = 1
            mangas = []
            hasMore = true
            errorMessage = nil
            retryCount = 0
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
                    native
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
            request.timeoutInterval = 15
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                try Task.checkCancellation()
                
                let result = try JSONDecoder().decode(AniListResponse.self, from: data)
                let newMangas = result.data.Page.media
                
                if reset {
                    self.mangas = newMangas
                } else {
                    self.mangas.append(contentsOf: newMangas)
                }
                
                self.hasMore = result.data.Page.pageInfo?.hasNextPage ?? false
                self.currentPage += 1
                self.isLoading = false
                self.retryCount = 0
                self.errorMessage = nil
                
            } catch is CancellationError {
                self.isLoading = false
                return
            } catch {
                print("Ошибка: \(error)")
                
                if retryCount < maxRetries {
                    retryCount += 1
                    print("Повторная попытка \(retryCount)/\(maxRetries)...")
                    self.isLoading = false
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    await self.loadMangas(reset: reset)
                } else {
                    if self.mangas.isEmpty {
                        self.errorMessage = "Не удалось загрузить. Проверь интернет."
                    }
                    self.isLoading = false
                }
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
        title.english ?? title.romaji ?? title.native ?? "Unknown"
    }
    
    var displayDescription: String {
        guard let desc = description else { return "Описание отсутствует" }
        let cleanDesc = desc.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return cleanDesc.isEmpty ? "Описание отсутствует" : cleanDesc
    }
    
    var displayStatus: String {
        switch status {
        case "RELEASING": return "Выходит"
        case "FINISHED": return "Завершено"
        case "HIATUS": return "На паузе"
        case "CANCELLED": return "Отменено"
        case "NOT_YET_RELEASED": return "Скоро выйдет"
        default: return status ?? "Неизвестно"
        }
    }
}

struct Title: Codable {
    let romaji: String?
    let english: String?
    let native: String?
}

struct CoverImage: Codable {
    let large: String?
}
