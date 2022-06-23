//
//  MangaDetailCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-17.
//

import ComposableArchitecture

struct MangaDetailState: Equatable, Identifiable {
  let id: Manga.ID
  let manga: Manga
  var isFavorite: Bool?
  var isLoading = false
  var detail: MangaDetail?
  var isReading = false
  var readingState: ReadingState?
  var alert: AlertState<MangaDetailAction>?
}

enum MangaDetailAction: Equatable {
  case onAppear
  case onDisappear
  case setFavorite(Bool)
  case setLoading(Bool)
  case fetch
  case detailResponse(Result<MangaDetail, ClientError>)
  case toggleFavorite
  case favoriteLoaded(Result<Bool, ClientError>)
  case selectChapterIndex(Int)
  case setReading(isPresented: Bool)
  case readingAction(ReadingAction)
  case alertDismissed
}

struct MangaDetailEnvironment {}

let mangaDetailReducer = Reducer<
  MangaDetailState,
  MangaDetailAction,
  SystemEnvironment<MangaDetailEnvironment>
>.combine(
  readingReducer
    .optional()
    .pullback(
      state: \.readingState,
      action: /MangaDetailAction.readingAction,
      environment: { _ in .live(environment: .init()) }
    ),
  .init { state, action, environment in
    struct FetchDetailID: Hashable {}

    switch action {
    case .onAppear:
      return .merge(
        environment.favoriteMangaClient.isFavorite(state.manga)
          .catchToEffect()
          .map(MangaDetailAction.favoriteLoaded),
        .init(value: .fetch)
      )

    case .onDisappear:
      return .cancel(id: FetchDetailID())

    case .setFavorite(let favorite):
      state.isFavorite = favorite
      return .none

    case .setLoading(let loading):
      state.isLoading = loading
      return .none

    case .fetch:
      guard let source = sources.first(where: { $0.id == state.manga.sourceID }) else {
        return .none
      }
      state.detail = nil
      state.isLoading = true
      return environment.mangaClient.mangaDetail(source.id, state.manga.detailURL)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(MangaDetailAction.detailResponse)
        .cancellable(id: FetchDetailID(), cancelInFlight: true)

    case .detailResponse(.success(let detail)):
      state.isLoading = false
      state.detail = detail
      return .none

    case .detailResponse(.failure(let error)):
      debugPrint(error)
      state.isLoading = false
      state.alert = .init(
        title: .init("Error"),
        message: .init(error.localizedDescription),
        dismissButton: .default(.init("OK"))
      )
      return .none

    case .toggleFavorite:
      guard let isFavorite = state.isFavorite else {
        return .none
      }
      if isFavorite {
        return environment.favoriteMangaClient.remove(state.manga)
          .receive(on: environment.mainQueue)
          .map { false }
          .catchToEffect()
          .map(MangaDetailAction.favoriteLoaded)
      }
      return environment.favoriteMangaClient.add(state.manga)
        .receive(on: environment.mainQueue)
        .map { true }
        .catchToEffect()
        .map(MangaDetailAction.favoriteLoaded)

    case .favoriteLoaded(.success(let isFavorite)):
      state.isFavorite = isFavorite
      return .none

    case .favoriteLoaded(.failure(let error)):
      state.alert = .init(
        title: .init("Error"),
        message: .init(error.localizedDescription),
        dismissButton: .default(.init("OK"))
      )
      return .none

    case .selectChapterIndex(let index):
      guard let chapters = state.detail?.chapters else {
        return .none
      }
      state.readingState = ReadingState(manga: state.manga, chapters: chapters, currentIndex: index)
      state.isReading = true
      return .none

    case .setReading(isPresented: true):
      return .none

    case .setReading(isPresented: false):
      state.isReading = false
      return .none

    case .readingAction:
      return .none

    case .alertDismissed:
      state.alert = nil
      return .none
    }
  }
)
