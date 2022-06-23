//
//  FavoritesCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-15.
//

import ComposableArchitecture

struct FavoritesState: Equatable {
  var mangas = IdentifiedArrayOf<MangaDetailState>()
  var isLoading = false
  var alert: AlertState<FavoritesAction>?
}

enum FavoritesAction: Equatable {
  case onAppear
  case mangaDetail(id: Manga.ID, action: MangaDetailAction)
  case mangaLoaded(Result<[Manga], ClientError>)
  case alertDismissed
}

struct FavoritesEnvironment {}

let favoritesReducer = Reducer<
  FavoritesState,
  FavoritesAction,
  SystemEnvironment<FavoritesEnvironment>
>.combine(
  mangaDetailReducer.forEach(
    state: \.mangas,
    action: /FavoritesAction.mangaDetail,
    environment: { _ in .live(environment: .init()) }
  ),
  .init { state, action, environment in
    switch action {
    case .onAppear:
      state.isLoading = true
      return environment.favoriteMangaClient.all()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FavoritesAction.mangaLoaded)

    case .mangaDetail:
      return .none

    case .mangaLoaded(.success(let mangas)):
      state.mangas = IdentifiedArrayOf<MangaDetailState>(
        uniqueElements: mangas.map { MangaDetailState(id: $0.id, manga: $0) }
      )
      state.isLoading = false
      return .none

    case .mangaLoaded(.failure(let error)):
      state.isLoading = false
      state.alert = .init(
        title: .init("Error"),
        message: .init(error.localizedDescription),
        dismissButton: .default(.init("OK"))
      )
      return .none

    case .alertDismissed:
      state.alert = nil
      return .none
    }
  }
)
