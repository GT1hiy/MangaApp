import SwiftUI

struct MangaRowView: View {
    let manga: Manga
    let general: General
    @State private var isFavorite = false
    @State private var showAuthAlert = false
    
    var body: some View {
        NavigationLink(destination: MangaDetailView(manga: manga, general: general)) {
            HStack(alignment: .top, spacing: 12) {
                coverImage
                infoView
                Spacer()
                favoriteButton
            }
            .frame(height: 160) // Увеличил высоту для дополнительной строки
            .padding(16)
            .background(cardBackground)
            .overlay(cardOverlay)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Вход в аккаунт", isPresented: $showAuthAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Вам нужно войти в аккаунт, чтобы добавлять в избранное")
        }
        .onAppear {
            isFavorite = FavoriteManager.shared.isFavorite(mangaId: manga.id)
        }
        .onReceive(FavoriteManager.shared.$favorites) { _ in
            isFavorite = FavoriteManager.shared.isFavorite(mangaId: manga.id)
        }
    }
    
    private var coverImage: some View {
        Group {
            if let urlString = manga.coverImage?.large, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 100, height: 140)
                            .overlay(ProgressView().tint(Color(red: 239/255, green: 191/255, blue: 4/255)))
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
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 140)
                    .overlay(Image(systemName: "book.closed").foregroundColor(.gray))
            }
        }
    }
    
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Заголовок - фиксированная высота
            Text(manga.displayTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(height: 44, alignment: .top)
            
            // Описание - фиксированная высота
            Text(manga.displayDescription)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)
                .frame(height: 32, alignment: .top)
            
            // Первая строка со статусом
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10))
                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                Text(manga.displayStatus)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
            }
            .frame(height: 20, alignment: .leading)
            
            // Вторая строка с количеством глав и томов
            HStack(spacing: 16) {
                // Количество глав
                if let chapters = manga.chapters, chapters > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                        Text("\(chapters) глав")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
                
                // Количество томов
                if let volumes = manga.volumes, volumes > 0 {
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
            .frame(height: 20, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            if general.exit {
                toggleFavorite()
            } else {
                showAuthAlert = true
            }
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 20))
                .foregroundColor(isFavorite ? .red : .gray)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 30, height: 30)
        .padding(.top, 8)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(red: 38/255, green: 38/255, blue: 38/255))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var cardOverlay: some View {
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
    }
    
    private func toggleFavorite() {
        if isFavorite {
            FavoriteManager.shared.removeFromFavorites(manga: manga)
        } else {
            FavoriteManager.shared.addToFavorites(manga: manga)
        }
        isFavorite.toggle()
    }
}

#Preview{
    MangaFeedView(general: General())
}
