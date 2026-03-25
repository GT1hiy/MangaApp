import SwiftUI

struct MangaRowView: View {
    let manga: Manga
    
    var body: some View {
        NavigationLink(destination: MangaDetailView(manga: manga)) {
            HStack(alignment: .top, spacing: 12) {
                // Обложка
                if let urlString = manga.coverImage?.large, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 140)
                                .overlay(
                                    ProgressView()
                                        .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 140)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 140)
                        .overlay(
                            Image(systemName: "book.closed")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(manga.displayTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(manga.displayDescription)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(3)
                    
                    HStack(spacing: 12) {
                        Text(manga.displayStatus)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                        
                        if let chapters = manga.chapters {
                            HStack(spacing: 4) {
                                Image(systemName: "book.pages")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                                Text("\(chapters) глав")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if let volumes = manga.volumes {
                            HStack(spacing: 4) {
                                Image(systemName: "books.vertical")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                                Text("\(volumes) томов")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 38/255, green: 38/255, blue: 38/255))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.3),
                                .clear,
                                Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
