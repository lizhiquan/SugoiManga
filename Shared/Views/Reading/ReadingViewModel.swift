//
//  ReadingViewModel.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-05.
//

import Combine
import Foundation

final class ReadingViewModel: ObservableObject {
    private let chapters: [Chapter]
    private let mangaService: MangaService
    private var currentChapterIndex: Int

    @Published private var chapterDetail: ChapterDetail?
    @Published private(set) var fetching = false

    var currentChapter: Chapter { chapters[currentChapterIndex] }
    var imageURLs: [URL] { chapterDetail?.imageURLs ?? [] }
    var title: String { currentChapter.title }
    var hasPrevChapter: Bool { currentChapterIndex < chapters.count - 1 }
    var hasNextChapter: Bool { currentChapterIndex > 0 }
    var imageRequestHeaders: [String: String]? { chapterDetail?.imageRequestHeaders }

    init(chapters: [Chapter],
         chapterIndex: Int,
         mangaService: MangaService = NetTruyenService()) {
        self.chapters = chapters
        self.currentChapterIndex = chapterIndex
        self.mangaService = mangaService

        $chapterDetail
            .map { _ in false }
            .assign(to: &$fetching)
    }

    private func fetchDetail(at url: URL) {
        fetching = true

        mangaService.chapterDetailPublisher(url: url)
            .retry(1)
            .receive(on: DispatchQueue.main)
            .map { d -> ChapterDetail? in d }
            .replaceError(with: nil)
            .assign(to: &$chapterDetail)
    }

    func fetchCurrentChapter() {
        fetchDetail(at: currentChapter.detailURL)
    }

    func fetchPrevChapter() {
        currentChapterIndex += 1
        fetchCurrentChapter()
    }

    func fetchNextChapter() {
        currentChapterIndex -= 1
        fetchCurrentChapter()
    }
}
