//import SwiftUI
//
//struct CoverImageView: View {
//    let mangaId: String
//    @State private var coverUrl: URL?
//    
//    var body: some View {
//        Group {
//            if let url = coverUrl {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    case .failure:
//                        Image(systemName: "book.closed")
//                            .font(.largeTitle)
//                            .foregroundColor(.gray)
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//            } else {
//                Color.gray.opacity(0.3)
//                    .overlay {
//                        ProgressView()
//                    }
//                    .task {
//                        await loadCover()
//                    }
//            }
//        }
//    }
//    
//    private func loadCover() async {
//        let urlString = "https://api.mangadex.org/cover?manga[]=\(mangaId)&limit=1"
//        guard let url = URL(string: urlString) else { return }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            // Парсим ответ и получаем имя файла обложки
//            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//               let dataArray = json["data"] as? [[String: Any]],
//               let firstCover = dataArray.first,
//               let attributes = firstCover["attributes"] as? [String: Any],
//               let fileName = attributes["fileName"] as? String {
//                coverUrl = URL(string: "https://uploads.mangadex.org/covers/\(mangaId)/\(fileName)")
//            }
//        } catch {
//            print("Ошибка загрузки обложки: \(error)")
//        }
//    }
//}
