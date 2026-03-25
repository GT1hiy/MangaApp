import Foundation

// MARK: - Ответ со списком глав
struct ChaptersResponse: Codable {
    let data: [Chapter]
    let total: Int
    let limit: Int
    let offset: Int
}

// MARK: - Модель главы
struct Chapter: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: ChapterAttributes
    let relationships: [Relationship]  // Добавляем relationships
}

// MARK: - Атрибуты главы
struct ChapterAttributes: Codable {
    let volume: String?
    let chapter: String?
    let title: String?
    let pages: Int
    let translatedLanguage: String
    let createdAt: String
    let updatedAt: String
    let publishAt: String
    
    var displayTitle: String {
        if let title = title, !title.isEmpty {
            return "Глава \(chapter ?? "?") - \(title)"
        }
        return "Глава \(chapter ?? "?")"
    }
    
    var displayVolume: String {
        return volume ?? "?"
    }
}

// MARK: - Связи (как в модели Manga)
struct Relationship: Codable {
    let id: String
    let type: String
    let attributes: RelationshipAttributes?  // Опционально, т.к. не всегда есть
}

// MARK: - Атрибуты связей
struct RelationshipAttributes: Codable {
    let fileName: String?  // Для обложек
}

// MARK: - Ответ с сервером для чтения
struct AtHomeResponse: Codable {
    let result: String
    let baseUrl: String
    let chapter: ChapterPages
}

// MARK: - Страницы главы
struct ChapterPages: Codable {
    let hash: String
    let data: [String]          // оригинальное качество
    let dataSaver: [String]     // сжатое качество
}
