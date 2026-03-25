import SwiftUI

struct MangaFeedView: View {
    @StateObject private var service = MangaService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView
                contentView
            }
            .navigationTitle("Манга")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
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
                ForEach(service.mangas) { manga in
                    MangaRowView(manga: manga)
                        .onAppear {
                            if manga.id == service.mangas.last?.id && service.hasMore && !service.isLoading {
                                service.loadMangas(reset: false)
                            }
                        }
                }
                
                if service.isLoading && !service.mangas.isEmpty {
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
