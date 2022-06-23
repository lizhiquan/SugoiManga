//
//  RootCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-12.
//

import ComposableArchitecture

struct RootState: Equatable {
  var latestUpdatesState = LatestUpdatesState()
  var favoritesState = FavoritesState()
}

enum RootAction {
  case latestUpdatesAction(LatestUpdatesAction)
  case favoritesAction(FavoritesAction)
}

struct RootEnvironment {}

let rootReducer = Reducer<
  RootState,
  RootAction,
  SystemEnvironment<RootEnvironment>
>.combine(
  latestUpdatesReducer.pullback(
    state: \.latestUpdatesState,
    action: /RootAction.latestUpdatesAction,
    environment: { _ in .live(environment: .init(userDefaults: .standard)) }
  ),
  favoritesReducer.pullback(
    state: \.favoritesState,
    action: /RootAction.favoritesAction,
    environment: { _ in .live(environment: .init()) }
  ),
  .init { state, action, environment in
    switch action {
    case .latestUpdatesAction, .favoritesAction:
      return .none
    }
  }
)
