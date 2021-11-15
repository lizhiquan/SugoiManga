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
    private var latestMangas = [Manga]()

    init(mangaService: MangaService = NetTruyenService()) {
        self.mangaService = mangaService

        $mangas
            .map { _ in false }
            .assign(to: &$fetching)

        $searchText
            .filter { !$0.isEmpty }
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .handleEvents(receiveOutput: { _ in
                self.fetching = true
            })
            .flatMap { searchText in
                self.mangaService.searchMangasPublisher(keyword: searchText)
                    .retry(1)
            }
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$mangas)

        $searchText
            .filter(\.isEmpty)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                if self.latestMangas.isEmpty {
                    self.fetchLatestMangas()
                } else {
                    self.mangas = self.latestMangas
                }
            })
            .store(in: &disposeBag)
    }

    func fetchLatestMangas(completion: (() -> Void)? = nil) {
        fetching = true

        mangaService.latestUpdateMangasPublisher()
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .retry(1)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .handleEvents(receiveOutput: { mangas in
                self.latestMangas = mangas
                completion?()
            })
            .assign(to: &$mangas)
    }
}
