//
//  LatestUpdatesTests.swift
//  SugoiMangaTests
//
//  Created by Vincent Le on 2022-06-21.
//

import XCTest
@testable import SugoiManga
import ComposableArchitecture

class LatestUpdatesTests: XCTestCase {
  let scheduler = DispatchQueue.test

  func testOnAppear_emptyMangas() {
    let store = TestStore(
      initialState: LatestUpdatesState(source: sources[0]),
      reducer: latestUpdatesReducer,
      environment: SystemEnvironment(
        environment: .init(),
        mainQueue: scheduler.eraseToAnyScheduler(),
        mangaClient: .mock,
        favoriteMangaClient: .mock
      )
    )

    let mangas = Manga.mocks
    store.environment.mangaClient.latestUpdateMangas = { sourceID, page in
      .init(value: mangas)
    }

    store.send(.onAppear)
    store.receive(.fetch) { state in
      state.isLoading = true
    }
    scheduler.advance()
    store.receive(.mangasResponse(.success(mangas))) { state in
      let mangaItems = IdentifiedArrayOf<MangaDetailState>(
        uniqueElements: mangas.map { MangaDetailState(id: $0.id, manga: $0) }
      )
      state.mangas.append(contentsOf: mangaItems)
      state.isLoading = false
      state.currentPage += 1
    }
  }

  func testOnAppear_nonemptyMangas() {
    let store = TestStore(
      initialState: LatestUpdatesState(
        source: sources[0],
        mangas: .init(
          uniqueElements: Manga.mocks.map {
            MangaDetailState(id: $0.id, manga: $0)
          }
        )
      ),
      reducer: latestUpdatesReducer,
      environment: SystemEnvironment(
        environment: .init(),
        mainQueue: scheduler.eraseToAnyScheduler(),
        mangaClient: .mock,
        favoriteMangaClient: .mock
      )
    )

    store.send(.onAppear)
  }

  func testOnDisappear_cancelFetch() {
    let store = TestStore(
      initialState: LatestUpdatesState(source: sources[0]),
      reducer: latestUpdatesReducer,
      environment: SystemEnvironment(
        environment: .init(),
        mainQueue: scheduler.eraseToAnyScheduler(),
        mangaClient: .mock,
        favoriteMangaClient: .mock
      )
    )

    store.environment.mangaClient.latestUpdateMangas = { sourceID, page in
      .init(value: Manga.mocks)
    }

    store.send(.fetch) { state in
      state.isLoading = true
    }
    store.send(.onDisappear)
    scheduler.run()
  }

  func testOnDisappear_cancelSearch() {
    let store = TestStore(
      initialState: LatestUpdatesState(
        source: sources[0],
        searchQuery: "abc"
      ),
      reducer: latestUpdatesReducer,
      environment: SystemEnvironment(
        environment: .init(),
        mainQueue: scheduler.eraseToAnyScheduler(),
        mangaClient: .mock,
        favoriteMangaClient: .mock
      )
    )

    store.environment.mangaClient.searchMangas = { sourceID, query, page in
      .init(value: Manga.mocks)
    }

    store.send(.fetch) { state in
      state.isLoading = true
    }
    store.send(.onDisappear)
    scheduler.run()
  }

  func testFetchError() {
    let store = TestStore(
      initialState: LatestUpdatesState(source: sources[0]),
      reducer: latestUpdatesReducer,
      environment: SystemEnvironment(
        environment: .init(),
        mainQueue: scheduler.eraseToAnyScheduler(),
        mangaClient: .mock,
        favoriteMangaClient: .mock
      )
    )

    let error = ClientError.decoding
    store.environment.mangaClient.latestUpdateMangas = { sourceID, page in
      .init(error: error)
    }

    store.send(.fetch) { state in
      state.isLoading = true
    }
    scheduler.advance()
    store.receive(.mangasResponse(.failure(error))) { state in
      state.isLoading = false
      state.alert = .init(
        title: .init("Error"),
        message: .init(error.localizedDescription),
        dismissButton: .default(.init("OK"))
      )
    }
    store.send(.alertDismissed) { state in
      state.alert = nil
    }
  }
}
