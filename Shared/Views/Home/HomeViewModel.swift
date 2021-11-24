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
    @Published private(set) var isFetchingFromBeginning = false
    @Published private(set) var isFetchingNextPage = false
    @Published var searchText = ""
    var scrollToTopPublisher: AnyPublisher<Void, Never> {
        scrollToTopSubject.eraseToAnyPublisher()
    }

    private let mangaService: MangaService
    private var subscriptions = [AnyCancellable]()
    private var mangaDataSource: MangaDataSource
    private let scrollToTopSubject = PassthroughSubject<Void, Never>()

    init(mangaService: MangaService = NetTruyenService()) {
        self.mangaService = mangaService
        mangaDataSource = LatestUpdateMangaDataSource(mangaService: mangaService)
        bindDataSource()

        $searchText
            .dropFirst()
            .map { !$0.isEmpty }
            .removeDuplicates()
            .sink { [weak self] isSearching in
                self?.updateDataSource(isSearching: isSearching)
            }
            .store(in: &subscriptions)

        $searchText
            .filter { !$0.isEmpty }
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.mangaDataSource.fetchFromBeginning()
            }
            .store(in: &subscriptions)
    }

    private func updateDataSource(isSearching: Bool) {
        if isSearching {
            mangaDataSource = SearchMangaDataSource(
                mangaService: mangaService,
                getKeyword: { [unowned self] in self.searchText }
            )
        } else {
            mangaDataSource = LatestUpdateMangaDataSource(mangaService: mangaService)
            mangaDataSource.fetchFromBeginning()
            // TODO: scroll to top
            scrollToTopSubject.send()
        }

        bindDataSource()
    }

    private func bindDataSource() {
        mangaDataSource.mangasPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$mangas)

        mangaDataSource.isFetchingFromBeginningPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$isFetchingFromBeginning)

        mangaDataSource.isFetchingNextPagePublisher
            .receive(on: RunLoop.main)
            .assign(to: &$isFetchingNextPage)
    }

    func fetchFromBeginning() {
        mangaDataSource.fetchFromBeginning()
    }

    func loadMoreIfNeeded(currentItem: Manga) {
        if currentItem == mangas.last {
            mangaDataSource.fetchNextPage()
        }
    }
}
