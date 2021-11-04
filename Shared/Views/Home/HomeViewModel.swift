//
//  HomeViewModel.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-02.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    @Published private(set) var mangas: [Manga] = []
    @Published private(set) var fetching = false

    private let mangaService: MangaService

    init(mangaService: MangaService = NetTruyenService()) {
        self.mangaService = mangaService

        $mangas
            .map { _ in false }
            .assign(to: &$fetching)
    }

    func fetchMangas() {
        fetching = true

        mangaService.latestUpdateMangasPublisher()
            .retry(1)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$mangas)
    }
}
