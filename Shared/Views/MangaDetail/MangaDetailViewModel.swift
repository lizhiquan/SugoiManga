//
//  MangaDetailViewModel.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-04.
//

import Foundation

final class MangaDetailViewModel: ObservableObject {
    private let manga: Manga
    private let mangaService: MangaService

    @Published private var mangaDetail: MangaDetail?
    @Published private(set) var fetching = false

    var title: String { manga.title }
    var coverImageURL: URL? { manga.coverImageURL }
    var author: String? { manga.author }
    var description: String { manga.description }
    var chapters: [Chapter] { mangaDetail?.chapters ?? [] }

    init(manga: Manga, mangaService: MangaService = NetTruyenService()) {
        self.manga = manga
        self.mangaService = mangaService

        $mangaDetail
            .map { _ in false }
            .assign(to: &$fetching)
    }

    func fetchDetail() {
        fetching = true

        mangaService.mangaDetailPublisher(url: manga.detailURL)
            .retry(1)
            .receive(on: DispatchQueue.main)
            .map { d -> MangaDetail? in d }
            .replaceError(with: nil)
            .assign(to: &$mangaDetail)
    }
}
