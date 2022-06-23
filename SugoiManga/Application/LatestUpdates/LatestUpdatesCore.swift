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
}

enum LatestUpdatesAction: Equatable {
  case onAppear
  case onDisappear
  case sourcePickerAction(SourcePickerAction)
  case mangaDetail(id: Manga.ID, action: MangaDetailAction)
  case loadSource
  case setSource(Source)
  case fetch
  case fetchNextPageIfNeeded(currentItemID: Manga.ID)
  case mangasResponse(Result<[Manga], ClientError>)
  case setSourcePicker(isPresented: Bool)
  case alertDismissed
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
    struct FetchMangasID: Hashable {}

    switch action {
    case .onAppear:
      return .init(value: .loadSource)

    case .onDisappear:
      return .cancel(id: FetchMangasID())

    case .sourcePickerAction(.sourceTapped(let source)):
      if source == state.source {
        return .none
      }
      environment.userDefaults.set(source.id.rawValue, forKey: "source")
      return .init(value: .setSource(source))

    case .sourcePickerAction, .mangaDetail:
      return .none

    case .loadSource:
      if let source = environment.userDefaults.string(forKey: "source")
        .flatMap(SourceID.init)
        .flatMap(findSource(with:)) {
        state.source = source
      }
      return .init(value: .fetch)

    case .setSource(let source):
      state.source = source
      return .init(value: .fetch)

    case .fetch:
      state.mangas.removeAll()
      state.currentPage = 0
      state.isLoading = true
      state.endOfList = false
      return environment.mangaClient.latestUpdateMangas(state.source.id, 1)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(LatestUpdatesAction.mangasResponse)
        .cancellable(id: FetchMangasID(), cancelInFlight: true)

    case .fetchNextPageIfNeeded(currentItemID: let id):
      guard state.mangas.last?.id == id, !state.isLoadingPage, !state.endOfList else {
        return .none
      }
      state.isLoadingPage = true
      return environment.mangaClient.latestUpdateMangas(state.source.id, state.currentPage + 1)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(LatestUpdatesAction.mangasResponse)
        .cancellable(id: FetchMangasID(), cancelInFlight: true)

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
    }
  }
)
