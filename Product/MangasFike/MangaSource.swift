import Foundation
import SwiftUI

// Протокол для всех источников манги
protocol MangaSource {
    func searchManga(title: String) async -> String?
    func getChapters(mangaId: String) async -> [ChapterItem]
    func getChapterPages(chapterUrl: String) async -> [URL]
    var name: String { get }
}

// Модель для главы
struct ChapterItem: Identifiable {
    let id = UUID()
    let number: String
    let url: String
    let title: String?
    let source: String
}

// Источник 1: MangaDex (с обходом блокировки)
class MangaDexSource: MangaSource {
    var name: String { "MangaDex" }
    
    private let apiDomains = [
        "https://api.mangadex.org",
        "https://api.mangadex.cc",
        "https://api.mangadex.network"
    ]
    
    private let imageDomains = [
        "https://uploads.mangadex.org",
        "https://mangadex.org",
        "https://mangadex.cc"
    ]
    
    func searchManga(title: String) async -> String? {
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        for apiDomain in apiDomains {
            let urlString = "\(apiDomain)/manga?title=\(encodedTitle)&limit=5"
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                struct Response: Codable {
                    let data: [MangaData]
                }
                struct MangaData: Codable {
                    let id: String
                    let attributes: Attributes
                }
                struct Attributes: Codable {
                    let title: [String: String]
                }
                
                let response = try JSONDecoder().decode(Response.self, from: data)
                if let first = response.data.first {
                    print("MangaDex нашел: \(first.id)")
                    return first.id
                }
            } catch {
                continue
            }
        }
        return nil
    }
    
    func getChapters(mangaId: String) async -> [ChapterItem] {
        var chapters: [ChapterItem] = []
        
        for apiDomain in apiDomains {
            let urlString = "\(apiDomain)/manga/\(mangaId)/feed?translatedLanguage[]=ru&translatedLanguage[]=en&order[chapter]=asc&limit=200"
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                struct Response: Codable {
                    let data: [ChapterData]
                }
                struct ChapterData: Codable {
                    let id: String
                    let attributes: ChapterAttributes
                }
                struct ChapterAttributes: Codable {
                    let chapter: String?
                    let title: String?
                }
                
                let response = try JSONDecoder().decode(Response.self, from: data)
                
                for chapter in response.data {
                    if let chapterNum = chapter.attributes.chapter, !chapterNum.isEmpty {
                        chapters.append(ChapterItem(
                            number: chapterNum,
                            url: chapter.id,
                            title: chapter.attributes.title,
                            source: "MangaDex"
                        ))
                    }
                }
                
                if !chapters.isEmpty {
                    return chapters.sorted { (Double($0.number) ?? 0) < (Double($1.number) ?? 0) }
                }
            } catch {
                continue
            }
        }
        
        return chapters
    }
    
    func getChapterPages(chapterUrl: String) async -> [URL] {
        for apiDomain in apiDomains {
            let urlString = "\(apiDomain)/at-home/server/\(chapterUrl)"
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                struct Response: Codable {
                    let chapter: ChapterPages
                }
                struct ChapterPages: Codable {
                    let hash: String
                    let data: [String]
                }
                
                let response = try JSONDecoder().decode(Response.self, from: data)
                
                for imageDomain in imageDomains {
                    let urls = response.chapter.data.map { fileName in
                        URL(string: "\(imageDomain)/data/\(response.chapter.hash)/\(fileName)")!
                    }
                    if !urls.isEmpty {
                        print("Загружено \(urls.count) страниц из MangaDex")
                        return urls
                    }
                }
            } catch {
                continue
            }
        }
        return []
    }
}

// Источник 2: MangaKatana
class MangaKatanaSource: MangaSource {
    var name: String { "MangaKatana" }
    private let baseURL = "https://mangakatana.com"
    
    func searchManga(title: String) async -> String? {
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/search?query=\(encodedTitle)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let html = String(data: data, encoding: .utf8) ?? ""
            let nsString = html as NSString
            
            // Ищем ссылку на мангу
            let pattern = "href=\"(/manga/[^\"]+)\"[^>]*>\\s*<img[^>]*alt=\"[^\"]*\""
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges > 1 {
                    let path = nsString.substring(with: match.range(at: 1))
                    print("Нашел ссылку: \(path)")
                    return path
                }
            }
            
            // Альтернативный поиск
            let altPattern = #"href="(/manga/[^"]+)"#
            let altRegex = try NSRegularExpression(pattern: altPattern, options: [])
            let altMatches = altRegex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if let match = altMatches.first, match.numberOfRanges > 1 {
                let path = nsString.substring(with: match.range(at: 1))
                return path
            }
            
        } catch {
            print("Ошибка поиска: \(error)")
        }
        return nil
    }
    
    func getChapters(mangaId: String) async -> [ChapterItem] {
        let urlString = "\(baseURL)\(mangaId)"
        guard let url = URL(string: urlString) else { return [] }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let html = String(data: data, encoding: .utf8) ?? ""
            let nsString = html as NSString
            
            var chapters: [ChapterItem] = []
            
            // Парсим главы
            let pattern = #"<a href="(/manga/[^"]+/chapter-([\d\.]+))"[^>]*>"#
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges > 2 {
                    let chapterUrl = nsString.substring(with: match.range(at: 1))
                    let chapterNumber = nsString.substring(with: match.range(at: 2))
                    
                    chapters.append(ChapterItem(
                        number: chapterNumber,
                        url: chapterUrl,
                        title: nil,
                        source: "MangaKatana"
                    ))
                }
            }
            
            return chapters.sorted { (Double($0.number) ?? 0) < (Double($1.number) ?? 0) }
        } catch {
            return []
        }
    }
    
    func getChapterPages(chapterUrl: String) async -> [URL] {
        let urlString = "\(baseURL)\(chapterUrl)"
        guard let url = URL(string: urlString) else { return [] }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let html = String(data: data, encoding: .utf8) ?? ""
            let nsString = html as NSString
            
            var imageUrls: [URL] = []
            
            // Парсим изображения
            let pattern = #"<img[^>]+src="([^"]+)"[^>]*>"#
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges > 1 {
                    var imageUrl = nsString.substring(with: match.range(at: 1))
                    
                    // Исправляем URL если нужно
                    if imageUrl.hasPrefix("//") {
                        imageUrl = "https:" + imageUrl
                    }
                    
                    if let url = URL(string: imageUrl) {
                        // Фильтруем только изображения
                        if imageUrl.contains(".jpg") || imageUrl.contains(".png") || imageUrl.contains(".webp") {
                            imageUrls.append(url)
                        }
                    }
                }
            }
            
            // Если не нашли в src, пробуем data-src
            if imageUrls.isEmpty {
                let altPattern = #"<img[^>]+data-src="([^"]+)"[^>]*>"#
                let altRegex = try NSRegularExpression(pattern: altPattern, options: [])
                let altMatches = altRegex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
                
                for match in altMatches {
                    if match.numberOfRanges > 1 {
                        var imageUrl = nsString.substring(with: match.range(at: 1))
                        
                        if imageUrl.hasPrefix("//") {
                            imageUrl = "https:" + imageUrl
                        }
                        
                        if let url = URL(string: imageUrl) {
                            imageUrls.append(url)
                        }
                    }
                }
            }
            
            print("Найдено \(imageUrls.count) изображений в главе")
            return imageUrls
        } catch {
            print("Ошибка загрузки страниц: \(error)")
            return []
        }
    }
}

// Источник 3: Демо-режим (для отладки)
class DemoSource: MangaSource {
    var name: String { "Demo" }
    
    func searchManga(title: String) async -> String? {
        return "demo"
    }
    
    func getChapters(mangaId: String) async -> [ChapterItem] {
        return (1...5).map { i in
            ChapterItem(
                number: "\(i)",
                url: "demo",
                title: nil,
                source: "Demo"
            )
        }
    }
    
    func getChapterPages(chapterUrl: String) async -> [URL] {
        // Возвращаем демо-изображения для теста
        return (1...10).map { i in
            URL(string: "https://picsum.photos/id/\(100 + i)/800/1200")!
        }
    }
}

// Менеджер источников
@MainActor
class MangaSourceManager: ObservableObject {
    static let shared = MangaSourceManager()
    
    @Published var currentSource: MangaSource?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let sources: [MangaSource] = [
        MangaKatanaSource(),     // Сначала MangaKatana (работает без VPN)
        MangaDexSource(),        // Потом MangaDex
        DemoSource()             // В конце демо-режим
    ]
    
    func findManga(title: String) async -> (source: MangaSource, id: String)? {
        isLoading = true
        defer { isLoading = false }
        
        for source in sources {
            print("🔍 Пробуем \(source.name)...")
            if let id = await source.searchManga(title: title) {
                print("Нашли через \(source.name)!")
                currentSource = source
                return (source, id)
            } else {
                print("❌ \(source.name) не нашел")
            }
        }
        
        errorMessage = "Не удалось найти мангу. Использую демо-режим."
        // Возвращаем демо-режим как fallback
        return (DemoSource(), "demo")
    }
    
    func getChapters(source: MangaSource, mangaId: String) async -> [ChapterItem] {
        return await source.getChapters(mangaId: mangaId)
    }
    
    func getPages(source: MangaSource, chapterUrl: String) async -> [URL] {
        return await source.getChapterPages(chapterUrl: chapterUrl)
    }
}
