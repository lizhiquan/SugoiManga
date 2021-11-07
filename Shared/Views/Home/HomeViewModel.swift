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
    @Published var searchText = ""

    private let mangaService: MangaService
    private var disposeBag = Set<AnyCancellable>()

    init(mangaService: MangaService = NetTruyenService()) {
        self.mangaService = mangaService

        $mangas
            .map { _ in false }
            .assign(to: &$fetching)

        $searchText
            .filter { $0.isEmpty }
            .sink { _ in
                self.fetchLatestMangas()
            }
            .store(in: &disposeBag)
    }

    func fetchLatestMangas() {
        fetching = true

        mangaService.latestUpdateMangasPublisher()
            .retry(1)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$mangas)
    }

    func performSearch() {
        guard !searchText.isEmpty else {
            fetchLatestMangas()
            return
        }

        searchMangas()
    }

    private func searchMangas() {
        fetching = true

        mangaService.searchMangasPublisher(keyword: searchText)
            .retry(1)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$mangas)
    }
}
