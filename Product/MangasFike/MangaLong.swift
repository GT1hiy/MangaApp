import SwiftUI

struct UnifiedReaderView: View {
    let mangaTitle: String
    let source: MangaSource
    let mangaId: String
    
    @StateObject private var sourceManager = MangaSourceManager.shared
    @State private var chapters: [ChapterItem] = []
    @State private var selectedChapter: ChapterItem?
    @State private var pages: [URL] = []
    @State private var currentPage = 0
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingChapterList = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Верхняя панель
                HStack {
                    Button(action: { showingChapterList = true }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Главы")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(20)
                        .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                    }
                    
                    Spacer()
                    
                    Text(source.name)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "gear")
                            .font(.caption)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }
                    .hidden()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .background(Color(red: 28/255, green: 28/255, blue: 28/255))
                
                // Основной контент
                ZStack {
                    if let error = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                            Text(error)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Повторить") {
                                Task { await loadChapters() }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
                        }
                    } else if isLoading && chapters.isEmpty {
                        ProgressView()
                            .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
                    } else if !pages.isEmpty {
                        // Чтение страниц
                        TabView(selection: $currentPage) {
                            ForEach(Array(pages.enumerated()), id: \.offset) { index, url in
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(scale)
                                            .gesture(
                                                MagnificationGesture()
                                                    .onChanged { value in
                                                        scale = lastScale * value
                                                    }
                                                    .onEnded { _ in
                                                        lastScale = scale
                                                    }
                                            )
                                    case .failure:
                                        VStack {
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                            Text("Не удалось загрузить страницу")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Button("Повторить") {
                                                if let chapter = selectedChapter {
                                                    Task { await loadPages(chapter: chapter) }
                                                }
                                            }
                                            .font(.caption)
                                            .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                                        }
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .overlay(alignment: .bottom) {
                            Text("Стр. \(currentPage + 1) / \(pages.count)")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                        }
                    } else if !chapters.isEmpty {
                        // Список глав
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(chapters) { chapter in
                                    Button(action: {
                                        Task { await loadPages(chapter: chapter) }
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Глава \(chapter.number)")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                                if let title = chapter.title {
                                                    Text(title)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                                        }
                                        .padding()
                                        .background(Color(red: 38/255, green: 38/255, blue: 38/255))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .navigationTitle(mangaTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingChapterList) {
            ChapterSelectionSheet(chapters: chapters, onSelect: { chapter in
                showingChapterList = false
                Task { await loadPages(chapter: chapter) }
            })
        }
        .task {
            await loadChapters()
        }
    }
    
    private func loadChapters() async {
        isLoading = true
        errorMessage = nil
        
        chapters = await sourceManager.getChapters(source: source, mangaId: mangaId)
        
        if chapters.isEmpty {
            errorMessage = "Не удалось загрузить список глав.\nПопробуйте позже."
        }
        
        isLoading = false
    }
    
    private func loadPages(chapter: ChapterItem) async {
        isLoading = true
        pages = []
        
        let loadedPages = await sourceManager.getPages(source: source, chapterUrl: chapter.url)
        
        if loadedPages.isEmpty {
            errorMessage = "Не удалось загрузить страницы главы.\nПопробуйте другую главу."
        } else {
            pages = loadedPages
            selectedChapter = chapter
            currentPage = 0
            errorMessage = nil
        }
        
        isLoading = false
    }
}

struct ChapterSelectionSheet: View {
    let chapters: [ChapterItem]
    let onSelect: (ChapterItem) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(chapters) { chapter in
                Button(action: {
                    onSelect(chapter)
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Глава \(chapter.number)")
                            .foregroundColor(.primary)
                        if let title = chapter.title {
                            Text(title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Список глав")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }
}
