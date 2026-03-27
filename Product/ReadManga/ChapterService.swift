import Foundation

@MainActor
class ChapterService: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var pages: [URL] = []
    @Published var currentPage = 0
    @Published var totalPages = 0
    @Published var currentImageDomainIndex = 0
    
    private let apiURL = "https://api.mangadex.org"
    
    private let imageDomains = [
        "https://uploads.mangadex.org",
        "https://mangadex.org",
        "https://mangadex.cc",
        "https://mangadex.network",
        "https://cdn.mangadex.org"
    ]
    
    var currentImageDomainName: String {
        return imageDomains[currentImageDomainIndex].replacingOccurrences(of: "https://", with: "")
    }
    
    func switchImageDomain(to index: Int) {
        guard index < imageDomains.count else { return }
        currentImageDomainIndex = index
        print("Переключено на зеркало: \(imageDomains[currentImageDomainIndex])")
    }
    
    func loadChapters(mangaId: String) async {
        isLoading = true
        errorMessage = nil
        
        guard !mangaId.isEmpty else {
            errorMessage = "ID манги не найден"
            isLoading = false
            return
        }
        
        let urlString = "\(apiURL)/manga/\(mangaId)/feed"
        var components = URLComponents(string: urlString)
        components?.queryItems = [
            URLQueryItem(name: "translatedLanguage[]", value: "ru"),
            URLQueryItem(name: "translatedLanguage[]", value: "en"),
            URLQueryItem(name: "order[chapter]", value: "asc"),
            URLQueryItem(name: "limit", value: "500"),
            URLQueryItem(name: "includes[]", value: "scanlation_group")
        ]
        
        guard let url = components?.url else {
            errorMessage = "Неверный URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("MangaReader/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(ChaptersResponse.self, from: data)
            chapters = response.data
            isLoading = false
            print("Загружено \(chapters.count) глав")
        } catch {
            print("Ошибка загрузки глав: \(error)")
            errorMessage = "Не удалось загрузить список глав. Проверьте интернет."
            isLoading = false
        }
    }
    
    func loadPages(chapterId: String) async {
        isLoading = true
        pages = []
        errorMessage = nil
        
        let urlString = "\(apiURL)/at-home/server/\(chapterId)"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("MangaReader/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(AtHomeResponse.self, from: data)
            
            print("Глава: hash=\(response.chapter.hash), страниц=\(response.chapter.data.count)")
            
            // Пробуем загрузить страницы через выбранное зеркало
            let baseUrl = imageDomains[currentImageDomainIndex]
            var imageUrls = response.chapter.data.map { fileName in
                URL(string: "\(baseUrl)/data/\(response.chapter.hash)/\(fileName)")!
            }
            
            // Если не загрузились через основное зеркало, пробуем через альтернативные
            if imageUrls.isEmpty {
                for domain in imageDomains {
                    let altUrls = response.chapter.data.map { fileName in
                        URL(string: "\(domain)/data/\(response.chapter.hash)/\(fileName)")!
                    }
                    imageUrls = altUrls
                    if !imageUrls.isEmpty {
                        break
                    }
                }
            }
            
            pages = imageUrls
            totalPages = pages.count
            currentPage = 0
            isLoading = false
            print("Загружено \(pages.count) страниц через зеркало: \(baseUrl)")
            
        } catch {
            print("Ошибка загрузки страниц: \(error)")
            errorMessage = "Не удалось загрузить страницы главы. Попробуйте другое зеркало."
            isLoading = false
        }
    }
}
