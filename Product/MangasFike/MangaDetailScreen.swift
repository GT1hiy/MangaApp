import SwiftUI

struct MangaDetailView: View {
    let manga: Manga
    @State private var showingReader = false
    @State private var mangaDexId: String?
    @State private var isSearching = false
    @State private var searchError: String?
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Обложка
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
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(manga.displayTitle)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                                Text(manga.displayStatus)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                            }
                            
                            if let chapters = manga.chapters {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.pages")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                                    Text("\(chapters) глав")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            if let volumes = manga.volumes {
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
                        
                        Divider()
                            .background(Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.3))
                        
                        Text("Описание")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(manga.displayDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                        
                        // Кнопка "Читать"
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
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 239/255, green: 191/255, blue: 4/255),
                                        Color(red: 200/255, green: 160/255, blue: 0/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .shadow(color: Color(red: 239/255, green: 191/255, blue: 4/255).opacity(0.5), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isSearching)
                        .padding(.top, 20)
                        
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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReader) {
            if let id = mangaDexId {
                ReaderView(mangaId: id, mangaTitle: manga.displayTitle)
            }
        }
    }
    
    private func openReader() async {
        isSearching = true
        searchError = nil
        
        let service = MangaService()
        if let id = await service.searchMangaDexId(title: manga.displayTitle) {
            mangaDexId = id
            showingReader = true
        } else {
            searchError = "Не удалось найти эту мангу в MangaDex. Попробуйте другое название."
        }
        
        isSearching = false
    }
}
