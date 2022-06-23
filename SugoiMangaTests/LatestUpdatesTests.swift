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
  let testScheduler = DispatchQueue.test

  func testOnAppear() {
    let store = TestStore(
      initialState: LatestUpdatesState(),
      reducer: latestUpdatesReducer,
      environment: SystemEnvironment(
        environment: LatestUpdatesEnvironment(userDefaults: .init()),
        mainQueue: testScheduler.eraseToAnyScheduler(),
        mangaClient: .mock,
        favoriteMangaClient: .mock
      )
    )

    let mangas = [
      Manga(
        title: "1",
        coverImageURL: nil,
        detailURL: URL(string: "1")!,
        genres: [],
        status: .ongoing,
        view: 1,
        sourceID: .mangakakalot
      ),
      Manga(
        title: "2",
        coverImageURL: nil,
        detailURL: URL(string: "2")!,
        genres: [],
        status: .ongoing,
        view: 1,
        sourceID: .mangakakalot
      )
    ]

    store.environment.mangaClient.latestUpdateMangas = { sourceID, page in
      Effect(value: mangas)
    }

    store.send(.onAppear)
    store.receive(.fetch) { state in
      state.mangas.removeAll()
      state.currentPage = 0
      state.isLoading = true
      state.endOfList = false
    }
    testScheduler.advance()
    store.receive(.mangasResponse(.success(mangas))) { state in
      let mangaItems = IdentifiedArrayOf<MangaDetailState>(
        uniqueElements: mangas.map { MangaDetailState(id: $0.id, manga: $0) }
      )
      state.mangas.append(contentsOf: mangaItems)
      state.isLoading = false
      state.isLoadingPage = false
      state.currentPage += 1
    }
  }
}
