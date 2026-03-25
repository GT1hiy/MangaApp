import SwiftUI

struct ReaderView: View {
    let mangaId: String
    let mangaTitle: String
    
    @StateObject private var chapterService = ChapterService()
    @State private var selectedChapter: Chapter?
    @State private var showingChapterList = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var showingSourceSelector = false
    
    var body: some View {
        ZStack {
            Color(red: 28/255, green: 28/255, blue: 28/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Верхняя панель с кнопками
                HStack {
                    // Кнопка выбора зеркала
                    Button(action: { showingSourceSelector = true }) {
                        HStack {
                            Image(systemName: "network")
                            Text("Зеркало")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(20)
                        .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                    }
                    
                    Spacer()
                    
                    // Кнопка списка глав
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
                    
                    // Текущее зеркало
                    Text(chapterService.currentImageDomainName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .background(Color(red: 28/255, green: 28/255, blue: 28/255))
                
                // Основной контент
                ZStack {
                    if let error = chapterService.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                            Text(error)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Button("Повторить") {
                                Task {
                                    if selectedChapter != nil {
                                        await chapterService.loadPages(chapterId: selectedChapter!.id)
                                    } else {
                                        await chapterService.loadChapters(mangaId: mangaId)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
                        }
                        .padding()
                    } else if chapterService.isLoading && chapterService.pages.isEmpty {
                        ProgressView()
                            .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
                    } else if !chapterService.pages.isEmpty {
                        // Чтение страниц
                        TabView(selection: $chapterService.currentPage) {
                            ForEach(Array(chapterService.pages.enumerated()), id: \.offset) { index, url in
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
                                                Task {
                                                    await chapterService.loadPages(chapterId: selectedChapter!.id)
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
                            Text("Стр. \(chapterService.currentPage + 1) / \(chapterService.totalPages)")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(20)
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                        }
                    } else if !chapterService.chapters.isEmpty {
                        // Список глав
                        VStack {
                            Text("Выберите главу")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                            
                            List(chapterService.chapters) { chapter in
                                Button(action: {
                                    selectedChapter = chapter
                                    Task {
                                        await chapterService.loadPages(chapterId: chapter.id)
                                    }
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(chapter.attributes.displayTitle)
                                            .foregroundColor(.white)
                                        HStack {
                                            Text("Том \(chapter.attributes.displayVolume)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("• \(chapter.attributes.pages) стр.")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .listRowBackground(Color(red: 38/255, green: 38/255, blue: 38/255))
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                        .background(Color(red: 28/255, green: 28/255, blue: 28/255))
                    } else {
                        // Начальная загрузка списка глав
                        ProgressView()
                            .tint(Color(red: 239/255, green: 191/255, blue: 4/255))
                            .task {
                                await chapterService.loadChapters(mangaId: mangaId)
                            }
                    }
                }
            }
        }
        .navigationTitle(mangaTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingChapterList) {
            ChapterListView(
                chapters: chapterService.chapters,
                currentChapter: selectedChapter,
                onSelect: { chapter in
                    selectedChapter = chapter
                    showingChapterList = false
                    Task {
                        await chapterService.loadPages(chapterId: chapter.id)
                    }
                }
            )
        }
        .sheet(isPresented: $showingSourceSelector) {
            SourceSelectorView(
                currentDomain: chapterService.currentImageDomainName,
                onSelect: { domainIndex in
                    chapterService.switchImageDomain(to: domainIndex)
                    if let chapter = selectedChapter {
                        Task {
                            await chapterService.loadPages(chapterId: chapter.id)
                        }
                    }
                }
            )
        }
    }
}

// MARK: - Выбор зеркала
struct SourceSelectorView: View {
    let currentDomain: String
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    let domains = [
        "mangadex.org",
        "mangadex.cc",
        "mangadex.network"
    ]
    
    var body: some View {
        NavigationStack {
            List(Array(domains.enumerated()), id: \.offset) { index, domain in
                Button(action: {
                    onSelect(index)
                    dismiss()
                }) {
                    HStack {
                        Text(domain)
                            .foregroundColor(.primary)
                        Spacer()
                        if domain == currentDomain {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                        }
                    }
                }
            }
            .navigationTitle("Выберите зеркало")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Список глав (sheet)
struct ChapterListView: View {
    let chapters: [Chapter]
    let currentChapter: Chapter?
    let onSelect: (Chapter) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(chapters) { chapter in
                Button(action: {
                    onSelect(chapter)
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chapter.attributes.displayTitle)
                                .foregroundColor(.primary)
                            HStack {
                                Text("Том \(chapter.attributes.displayVolume)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("• \(chapter.attributes.pages) стр.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if chapter.id == currentChapter?.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(red: 239/255, green: 191/255, blue: 4/255))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Список глав")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}
