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
                
            } catch is CancellationError {
                self.isLoading = false
                return
            } catch {
                print("Ошибка: \(error)")
                self.errorMessage = "Не удалось загрузить. Проверь интернет."
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Поиск ID манги в MangaDex
    func searchMangaDexId(title: String) async -> String? {
        let searchTitle = title.lowercased()
        let encodedTitle = searchTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let apiUrls = [
            "https://api.mangadex.org",
            "https://api.mangadex.cc",
            "https://api.mangadex.network"
        ]
        
        for apiUrl in apiUrls {
            let urlString = "\(apiUrl)/manga?title=\(encodedTitle)&limit=5"
            
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("MangaReader/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Поиск через \(apiUrl): статус \(httpResponse.statusCode)")
                }
                
                let responseString = String(data: data, encoding: .utf8) ?? ""
                
                if responseString.contains("<!DOCTYPE html>") || responseString.contains("html") {
                    print("API вернул HTML, пробуем другое зеркало")
                    continue
                }
                
                struct SearchResponse: Codable {
                    let data: [MangaDexManga]
                }
                
                struct MangaDexManga: Codable {
                    let id: String
                    let attributes: MangaDexAttributes
                }
                
                struct MangaDexAttributes: Codable {
                    let title: [String: String]
                }
                
                let searchResult = try JSONDecoder().decode(SearchResponse.self, from: data)
                
                for manga in searchResult.data {
                    for (lang, mangaTitle) in manga.attributes.title {
                        if mangaTitle.lowercased() == searchTitle {
                            print("Найден ID: \(manga.id) через язык \(lang)")
                            return manga.id
                        }
                    }
                }
                
                if let firstId = searchResult.data.first?.id {
                    print("Взяли первый результат: \(firstId)")
                    return firstId
                }
                
            } catch {
                print("Ошибка через \(apiUrl): \(error)")
                continue
            }
        }
        
        return await searchMangaDexIdSimple(title: searchTitle)
    }
    
    private func searchMangaDexIdSimple(title: String) async -> String? {
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let apiUrls = [
            "https://api.mangadex.org",
            "https://api.mangadex.cc"
        ]
        
        for apiUrl in apiUrls {
            let urlString = "\(apiUrl)/manga?limit=50"
            
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("MangaReader/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                struct SearchResponse: Codable {
                    let data: [MangaItem]
                }
                
                struct MangaItem: Codable {
                    let id: String
                    let attributes: MangaAttributes
                }
                
                struct MangaAttributes: Codable {
                    let title: [String: String]
                }
                
                let searchResult = try JSONDecoder().decode(SearchResponse.self, from: data)
                
                for manga in searchResult.data {
                    for (_, mangaTitle) in manga.attributes.title {
                        if mangaTitle.lowercased().contains(title) || title.contains(mangaTitle.lowercased()) {
                            print("Найден ID через частичное совпадение: \(manga.id)")
                            return manga.id
                        }
                    }
                }
                
                if let firstId = searchResult.data.first?.id {
                    print("Взяли первый ID из списка: \(firstId)")
                    return firstId
                }
                
            } catch {
                print("Ошибка простого поиска через \(apiUrl): \(error)")
                continue
            }
        }
        
        return nil
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
