//
//  LatestUpdatesCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-12.
//

import ComposableArchitecture

struct LatestUpdatesState: Equatable {
  var sourcePickerState: SourcePickerState?
  var source = sources[0]
  var sourcePickerPresented = false
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
  case sourcePickerAction(SourcePickerAction)
  case mangaDetail(id: Manga.ID, action: MangaDetailAction)
  case fetch
  case fetchNextPageIfNeeded(currentItemID: Manga.ID)
  case mangasResponse(Result<[Manga], ClientError>)
  case setSourcePicker(isPresented: Bool)
  case alertDismissed
  case searchQueryChanged(String)
}

struct LatestUpdatesEnvironment {
  var userDefaults: UserDefaults
  var mangaClient: MangaClient?
}

let latestUpdatesReducer = Reducer<
  LatestUpdatesState,
  LatestUpdatesAction,
  SystemEnvironment<LatestUpdatesEnvironment>
>.combine(
  sourcePickerReducer
    .optional()
    .pullback(
      state: \.sourcePickerState,
      action: /LatestUpdatesAction.sourcePickerAction,
      environment: { _ in .live(environment: .init()) }
    ),
  mangaDetailReducer.forEach(
    state: \.mangas,
    action: /LatestUpdatesAction.mangaDetail,
    environment: { _ in .live(environment: .init()) }
  ),
  .init { state, action, environment in
    enum FetchMangasID {}
    enum SearchMangasID {}

    switch action {
    case .onAppear:
      if let source = environment.userDefaults.string(forKey: "source")
        .flatMap(SourceID.init)
        .flatMap(findSource(with:)) {
        state.source = source
      }
      return .init(value: .fetch)

    case .onDisappear:
      return .merge(
        .cancel(id: FetchMangasID.self),
        .cancel(id: SearchMangasID.self)
      )

    case .sourcePickerAction(.sourceTapped(let source)):
      if source == state.source {
        return .none
      }
      environment.userDefaults.set(source.id.rawValue, forKey: "source")
      state.source = source
      return .init(value: .fetch)

    case .sourcePickerAction, .mangaDetail:
      return .none

    case .fetch:
      enum SearchMangasID {}

      state.mangas.removeAll()
      state.currentPage = 0
      state.isLoading = true
      state.endOfList = false
      if state.searchQuery.isEmpty {
        return .concatenate(
          .cancel(id: SearchMangasID.self),
          environment.mangaClient.latestUpdateMangas(state.source.id, 1)
          .receive(on: environment.mainQueue)
          .catchToEffect(LatestUpdatesAction.mangasResponse)
          .cancellable(id: FetchMangasID.self, cancelInFlight: true)
        )
      } else {
        return environment.mangaClient.searchMangas(state.source.id, state.searchQuery, 1)
          .debounce(id: SearchMangasID.self, for: 0.3, scheduler: environment.mainQueue)
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
          .cancellable(id: FetchMangasID.self, cancelInFlight: true)
      } else {
        return environment.mangaClient.searchMangas(state.source.id, state.searchQuery, state.currentPage + 1)
          .receive(on: environment.mainQueue)
          .catchToEffect(LatestUpdatesAction.mangasResponse)
          .cancellable(id: SearchMangasID.self, cancelInFlight: true)
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

    case .setSourcePicker(isPresented: true):
      state.sourcePickerState = SourcePickerState(selectedSource: state.source)
      state.sourcePickerPresented = true
      return .none

    case .setSourcePicker(isPresented: false):
      state.sourcePickerPresented = false
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
