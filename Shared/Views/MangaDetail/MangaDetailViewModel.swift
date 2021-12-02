//
//  MangaDetailViewModel.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-04.
//

import Foundation
import Combine

final class MangaDetailViewModel: ObservableObject {
    private let manga: Manga
    let mangaService: MangaService

    @Published private var mangaDetail: MangaDetail?
    @Published private(set) var fetching = false

    var title: String { manga.title }
    var coverImageURL: URL? { manga.coverImageURL }
    var author: String? { mangaDetail?.author }
    var summary: String? { mangaDetail?.summary }
    var chapters: [Chapter] { mangaDetail?.chapters ?? [] }

    init(manga: Manga, mangaService: MangaService) {
        self.manga = manga
        self.mangaService = mangaService
    }

    func fetchDetail() {
        Task {
            await fetchDetailAsync()
        }
    }

    func fetchDetailAsync() async {
        DispatchQueue.main.async {
            self.fetching = true
        }

        defer {
            DispatchQueue.main.async {
                self.fetching = false
            }
        }

        do {
            let mangaDetail = try await fetchMangaDetailAsync()
            DispatchQueue.main.async {
                self.mangaDetail = mangaDetail
            }
        } catch {
            print(error)
        }
    }

    private func fetchMangaDetailAsync() async throws -> MangaDetail {
        try await withCheckedThrowingContinuation { c in
            var cancellable: AnyCancellable?
            cancellable = self.mangaService.mangaDetailPublisher(url: manga.detailURL)
                .first()
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        c.resume(throwing: error)
                    }
                    cancellable?.cancel()
                }, receiveValue: { value in
                    c.resume(returning: value)
                })
        }
    }
}
