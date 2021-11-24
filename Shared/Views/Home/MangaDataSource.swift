//
//  MangaDataSource.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-23.
//

import Combine

protocol MangaDataSource {
    var mangasPublisher: AnyPublisher<[Manga], Never> { get }
    var isFetchingFromBeginningPublisher: AnyPublisher<Bool, Never> { get }
    var isFetchingNextPagePublisher: AnyPublisher<Bool, Never> { get }

    func fetchFromBeginning()
    func fetchNextPage()
}

class LatestUpdateMangaDataSource: MangaDataSource {
    let mangasPublisher: AnyPublisher<[Manga], Never>
    let isFetchingFromBeginningPublisher: AnyPublisher<Bool, Never>
    let isFetchingNextPagePublisher: AnyPublisher<Bool, Never>

    private var currentPage = 1
    private var subscriptions = [AnyCancellable]()
    private let fetchFromBeginningTriggerSubject = PassthroughSubject<Void, Never>()
    private let fetchPageTriggerSubject = PassthroughSubject<Int, Never>()
    private let mangasSubject = CurrentValueSubject<[Manga], Never>([])
    private let isFetchingFromBeginningSubject = CurrentValueSubject<Bool, Never>(false)
    private let isFetchingNextPageSubject = CurrentValueSubject<Bool, Never>(false)

    init(mangaService: MangaService) {
        self.mangasPublisher = mangasSubject.eraseToAnyPublisher()
        self.isFetchingFromBeginningPublisher = isFetchingFromBeginningSubject.eraseToAnyPublisher()
        self.isFetchingNextPagePublisher = isFetchingNextPageSubject.eraseToAnyPublisher()

        fetchFromBeginningTriggerSubject
            .handleEvents(receiveOutput: { [weak self] in
                self?.isFetchingFromBeginningSubject.send(true)
            })
            .flatMap {
                mangaService.latestUpdateMangasPublisher(page: 1)
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.currentPage = 1
                self?.isFetchingFromBeginningSubject.send(false)
            }, receiveCancel: { [weak self] in
                self?.isFetchingFromBeginningSubject.send(false)
            })
            .replaceError(with: [])
            .assign(to: \.value, on: mangasSubject)
            .store(in: &subscriptions)

        fetchPageTriggerSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isFetchingNextPageSubject.send(true)
            })
            .flatMap { [weak self] page in
                mangaService.latestUpdateMangasPublisher(page: page)
                    .handleEvents(receiveOutput: { [weak self] _ in
                        self?.currentPage = page
                    })
            }
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isFetchingNextPageSubject.send(false)
            }, receiveCancel: { [weak self] in
                self?.isFetchingNextPageSubject.send(false)
            })
            .replaceError(with: [])
            .map { [weak self] mangas in
                self?.mangasSubject.value.mergeNextPageResults(mangas) ?? []
            }
            .assign(to: \.value, on: mangasSubject)
            .store(in: &subscriptions)
    }

    func fetchFromBeginning() {
        fetchFromBeginningTriggerSubject.send()
    }

    func fetchNextPage() {
        fetchPageTriggerSubject.send(currentPage + 1)
    }
}

class SearchMangaDataSource: MangaDataSource {
    let mangasPublisher: AnyPublisher<[Manga], Never>
    let isFetchingFromBeginningPublisher: AnyPublisher<Bool, Never>
    let isFetchingNextPagePublisher: AnyPublisher<Bool, Never>

    private var currentPage = 1
    private var subscriptions = [AnyCancellable]()
    private let fetchFromBeginningTriggerSubject = PassthroughSubject<Void, Never>()
    private let fetchPageTriggerSubject = PassthroughSubject<Int, Never>()
    private let mangasSubject = CurrentValueSubject<[Manga], Never>([])
    private let isFetchingFromBeginningSubject = CurrentValueSubject<Bool, Never>(false)
    private let isFetchingNextPageSubject = CurrentValueSubject<Bool, Never>(false)

    init(mangaService: MangaService, getKeyword: @escaping () -> String) {
        self.mangasPublisher = mangasSubject.eraseToAnyPublisher()
        self.isFetchingFromBeginningPublisher = isFetchingFromBeginningSubject.eraseToAnyPublisher()
        self.isFetchingNextPagePublisher = isFetchingNextPageSubject.eraseToAnyPublisher()

        fetchFromBeginningTriggerSubject
            .handleEvents(receiveOutput: { [weak self] in
                self?.isFetchingFromBeginningSubject.send(true)
            })
            .flatMap {
                mangaService.searchMangasPublisher(keyword: getKeyword(), page: 1)
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.currentPage = 1
                self?.isFetchingFromBeginningSubject.send(false)
            }, receiveCancel: { [weak self] in
                self?.isFetchingFromBeginningSubject.send(false)
            })
            .replaceError(with: [])
            .assign(to: \.value, on: mangasSubject)
            .store(in: &subscriptions)

        fetchPageTriggerSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isFetchingNextPageSubject.send(true)
            })
            .flatMap { [weak self] page in
                mangaService.searchMangasPublisher(keyword: getKeyword(), page: page)
                    .handleEvents(receiveOutput: { [weak self] _ in
                        self?.currentPage = page
                    })
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isFetchingNextPageSubject.send(false)
            }, receiveCancel: { [weak self] in
                self?.isFetchingNextPageSubject.send(false)
            })
            .replaceError(with: [])
            .map { [weak self] mangas in
                self?.mangasSubject.value.mergeNextPageResults(mangas) ?? []
            }
            .assign(to: \.value, on: mangasSubject)
            .store(in: &subscriptions)
    }

    func fetchFromBeginning() {
        fetchFromBeginningTriggerSubject.send()
    }

    func fetchNextPage() {
        fetchPageTriggerSubject.send(currentPage + 1)
    }
}

extension Array where Element == Manga {
    func mergeNextPageResults(_ nextPageMangas: [Manga]) -> [Manga] {
        guard let lastManga = self.last else {
            return nextPageMangas
        }

        if let indexOfLastManga = nextPageMangas.firstIndex(of: lastManga) {
            let nextPageResults = nextPageMangas[(indexOfLastManga + 1)...]
            return self + nextPageResults
        }

        return self + nextPageMangas
    }
}
