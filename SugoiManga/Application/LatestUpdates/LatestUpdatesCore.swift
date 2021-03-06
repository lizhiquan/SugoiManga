//
//  LatestUpdatesCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-12.
//

import ComposableArchitecture

struct LatestUpdatesState: Equatable, Identifiable {
  var id: SourceID { source.id }
  let source: Source
  var mangas = IdentifiedArrayOf<MangaDetailState>()
  var currentPage = 0
  var isLoading = false
  var isLoadingPage = false
  var endOfList = false
  var alert: AlertState<LatestUpdatesAction>?
  var searchQuery = ""
}

enum LatestUpdatesAction: Equatable {
  case onAppear
  case onDisappear
  case mangaDetail(id: Manga.ID, action: MangaDetailAction)
  case fetch
  case fetchNextPageIfNeeded(currentItemID: Manga.ID)
  case mangasResponse(Result<[Manga], ClientError>)
  case alertDismissed
  case searchQueryChanged(String)
}

struct LatestUpdatesEnvironment {}

let latestUpdatesReducer = Reducer<
  LatestUpdatesState,
  LatestUpdatesAction,
  SystemEnvironment<LatestUpdatesEnvironment>
>.combine(
  mangaDetailReducer.forEach(
    state: \.mangas,
    action: /LatestUpdatesAction.mangaDetail,
    environment: { _ in .live(environment: .init()) }
  ),
  .init { state, action, environment in
    struct FetchMangasID: Hashable {
      let id: SourceID
    }
    struct SearchMangasID: Hashable {
      let id: SourceID
    }

    switch action {
    case .onAppear:
      if state.mangas.isEmpty {
        return .init(value: .fetch)
      }
      return .none

    case .onDisappear:
      return .merge(
        .cancel(id: FetchMangasID(id: state.id)),
        .cancel(id: SearchMangasID(id: state.id))
      )

    case .mangaDetail:
      return .none

    case .fetch:
      state.mangas.removeAll()
      state.currentPage = 0
      state.isLoading = true
      state.endOfList = false
      if state.searchQuery.isEmpty {
        return .concatenate(
          .cancel(id: SearchMangasID(id: state.id)),
          environment.mangaClient.latestUpdateMangas(state.source.id, 1)
          .receive(on: environment.mainQueue)
          .catchToEffect(LatestUpdatesAction.mangasResponse)
          .cancellable(id: FetchMangasID(id: state.id), cancelInFlight: true)
        )
      } else {
        return environment.mangaClient.searchMangas(state.source.id, state.searchQuery, 1)
          .debounce(id: SearchMangasID(id: state.id), for: 0.3, scheduler: environment.mainQueue)
          .catchToEffect(LatestUpdatesAction.mangasResponse)
      }

    case .fetchNextPageIfNeeded(currentItemID: let id):
      guard state.mangas.last?.id == id, !state.isLoadingPage, !state.endOfList else {
        return .none
      }
      state.isLoadingPage = true
      if state.searchQuery.isEmpty {
        return environment.mangaClient.latestUpdateMangas(state.source.id, state.currentPage + 1)
          .receive(on: environment.mainQueue)
          .catchToEffect(LatestUpdatesAction.mangasResponse)
          .cancellable(id: FetchMangasID(id: state.id), cancelInFlight: true)
      } else {
        return environment.mangaClient.searchMangas(state.source.id, state.searchQuery, state.currentPage + 1)
          .receive(on: environment.mainQueue)
          .catchToEffect(LatestUpdatesAction.mangasResponse)
          .cancellable(id: SearchMangasID(id: state.id), cancelInFlight: true)
      }

    case .mangasResponse(.success(let mangas)):
      let mangaItems = IdentifiedArrayOf<MangaDetailState>(
        uniqueElements: mangas.map { MangaDetailState(id: $0.id, manga: $0) }
      )
      state.mangas.append(contentsOf: mangaItems)
      state.isLoading = false
      state.isLoadingPage = false
      if mangas.isEmpty {
        state.endOfList = true
      }
      state.currentPage += 1
      return .none

    case .mangasResponse(.failure(let error)):
      state.isLoading = false
      state.isLoadingPage = false
      state.alert = .init(
        title: .init("Error"),
        message: .init(error.localizedDescription),
        dismissButton: .default(.init("OK"))
      )
      return .none

    case .alertDismissed:
      state.alert = nil
      return .none

    case .searchQueryChanged(let query):
      state.searchQuery = query
      return .init(value: .fetch)
    }
  }
)
