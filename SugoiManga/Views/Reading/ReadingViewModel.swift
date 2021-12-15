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
    var fetchDetailCancellable: AnyCancellable?

    init(chapters: [Chapter],
         chapterIndex: Int,
         mangaService: MangaService) {
        self.chapters = chapters
        self.currentChapterIndex = chapterIndex
        self.mangaService = mangaService
    }

    private func fetchDetail(at url: URL) {
        fetchDetailCancellable?.cancel()
        fetching = true

        fetchDetailCancellable = mangaService.chapterDetailPublisher(url: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.fetching = false
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { detail in
                self.fetching = false
                self.chapterDetail = detail
            })
    }

    func fetchCurrentChapter() {
        chapterDetail = nil
        fetchDetail(at: currentChapter.detailURL)
    }

    func fetchPrevChapter() {
        guard hasPrevChapter else { return }

        currentChapterIndex += 1
        fetchCurrentChapter()
    }

    func fetchNextChapter() {
        guard hasNextChapter else { return }

        currentChapterIndex -= 1
        fetchCurrentChapter()
    }
}
