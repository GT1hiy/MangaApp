import SwiftUI

struct MangaFeedView: View {
    @StateObject private var service = MangaService()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredMangas: [Manga] {
        if searchText.isEmpty {
            return service.mangas
        } else {
            return service.mangas.filter { manga in
                manga.displayTitle.localizedCaseInsensitiveContains(searchText) ||
                manga.title.english?.localizedCaseInsensitiveContains(searchText) == true ||
                manga.title.romaji?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                contentView
            }
            .navigationTitle("Манга")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbarBackground(.hidden, for: .navigationBar)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Поиск манги")
            .onSubmit(of: .search) {
                isSearchFocused = false
            }
        }
        .task {
            service.loadMangas(reset: true)
        }
    }
    
    private var backgroundView: some View {
        Color(red: 28/255, green: 28/255, blue: 28/255)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let error = service.errorMessage {
            errorView(error)
        } else if service.isLoading && service.mangas.isEmpty {
            loadingView
        } else {
            mangaListView
        }
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
            Text(error)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Button("Повторить") {
                service.loadMangas(reset: true)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    private var loadingView: some View {
        ProgressView()
            .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
            .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    private var mangaListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredMangas) { manga in
                    MangaRowView(manga: manga, general: General())
                        .onAppear {
                            if manga.id == service.mangas.last?.id && service.hasMore && !service.isLoading && searchText.isEmpty {
                                service.loadMangas(reset: false)
                            }
                        }
                }
                
                if service.isLoading && !service.mangas.isEmpty && searchText.isEmpty {
                    ProgressView()
                        .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .refreshable {
            service.loadMangas(reset: true)
        }
    }
}
