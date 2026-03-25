////
////  Model.swift
////  Networking
////
////  Created by German Tihiy on 25.03.2026.
////
//
//import Foundation
//
//// MARK: - Модель для ответа API
//struct MangaResponse: Codable {
//    let data: [Manga]
//    let total: Int
//    let limit: Int
//    let offset: Int
//}
//
//// MARK: - Модель манги
//struct Manga: Codable, Identifiable {
//    let id: String
//    let type: String
//    let attributes: MangaAttributes
//    let relationships: [Relationship]
//}
//
//// MARK: - Атрибуты манги
//struct MangaAttributes: Codable {
//    let title: [String: String]
//    let description: [String: String]?
//    let status: String
//    let year: Int?
//    let tags: [Tag]
//    let contentRating: String
//    let createdAt: String
//    let updatedAt: String
//    
//    // Получаем название на русском или английском
//    var displayTitle: String {
//        if let russianTitle = title["ru"] {
//            return russianTitle
//        }
//        return title["en"] ?? title.values.first ?? "Без названия"
//    }
//    
//    // Получаем описание на русском или английском
//    var displayDescription: String {
//        if let russianDesc = description?["ru"] {
//            return cleanHTMLTags(russianDesc)
//        }
//        if let englishDesc = description?["en"] {
//            return cleanHTMLTags(englishDesc)
//        }
//        return "Описание отсутствует"
//    }
//    
//    // Убираем HTML-теги из описания
//    private func cleanHTMLTags(_ text: String) -> String {
//        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
//    }
//}
//
//// MARK: - Теги (жанры)
//struct Tag: Codable {
//    let id: String
//    let attributes: TagAttributes
//}
//
//struct TagAttributes: Codable {
//    let name: [String: String]
//}
//
//// MARK: - Связи (для обложки)
//struct Relationship: Codable {
//    let id: String
//    let type: String
//}
