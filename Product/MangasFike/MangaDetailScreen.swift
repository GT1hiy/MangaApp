import SwiftUI

struct MangaDetailView: View {
    let manga: Manga
    let general: General
    @State private var showingReader = false
    @State private var mangaSourceId: String?
    @State private var currentSource: MangaSource?
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var isFavorite = false
    @State private var showAuthAlert = false
    @State private var sourceName: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    coverImage
                    infoSection
                    
                    if !sourceName.isEmpty {
                        HStack {
                            Text("Источник:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(sourceName)
                                .font(.caption)
                                .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, -10)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReader) {
            if let id = mangaSourceId, let source = currentSource {
                UnifiedReaderView(
                    mangaTitle: manga.displayTitle,
                    source: source,
                    mangaId: id
                )
            }
        }
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
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(ProgressView().tint(Color(red: 239/255, green: 191/255, blue: 4/255)))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                    case .failure:
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.3), radius: 15, x: 0, y: 5)
                .padding(.horizontal)
                .padding(.top)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    .padding(.horizontal)
                    .padding(.top)
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            titleRow
            statusRow
            Divider().background(Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.3))
            descriptionView
            Spacer(minLength: 80)
            readButton
            if let error = searchError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    private var titleRow: some View {
        HStack {
            Text(manga.displayTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                if general.exit {
                    toggleFavorite()
                } else {
                    showAuthAlert = true
                }
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 28))
                    .foregroundColor(isFavorite ? .red : .gray)
            }
        }
    }
    
    private var statusRow: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                Text(manga.displayStatus)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
            }
            
            if let chapters = manga.chapters, chapters > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "book.pages")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                    Text("\(chapters) глав")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            if let volumes = manga.volumes, volumes > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                    Text("\(volumes) томов")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text(manga.displayDescription)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }
    
    private var readButton: some View {
        Button(action: {
            Task {
                await openReader()
            }
        }) {
            HStack {
                if isSearching {
                    ProgressView()
                        .tint(.black)
                } else {
                    Image(systemName: "book.fill")
                    Text("Читать")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(buttonGradient)
            .foregroundColor(.black)
            .cornerRadius(12)
            .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .disabled(isSearching)
        .padding(.bottom, 65)
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 239/255, green: 191/255, blue: 4/255),
                Color(red: 200/255, green: 160/255, blue: 0/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
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
    
    private func openReader() async {
        isSearching = true
        searchError = nil
        sourceName = ""
        
        let searchTitles = [
            manga.title.english,
            manga.title.romaji,
            manga.title.native,
            manga.displayTitle
        ].compactMap { $0 }
        
        let manager = MangaSourceManager.shared
        
        for title in searchTitles {
            if let (source, id) = await manager.findManga(title: title) {
                currentSource = source
                mangaSourceId = id
                sourceName = source.name
                showingReader = true
                break
            }
        }
        
        if mangaSourceId == nil {
            searchError = "Не удалось найти мангу.\nПопробуйте позже или проверьте название"
        }
        
        isSearching = false
    }
}
