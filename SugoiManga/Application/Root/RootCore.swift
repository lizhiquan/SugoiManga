//
//  RootCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-12.
//

import ComposableArchitecture

struct RootState: Equatable {
  var sourcePickerState = SourcePickerState()
  var favoritesState = FavoritesState()
}

enum RootAction {
  case sourcePickerAction(SourcePickerAction)
  case favoritesAction(FavoritesAction)
}

struct RootEnvironment {}

let rootReducer = Reducer<
  RootState,
  RootAction,
  SystemEnvironment<RootEnvironment>
>.combine(
  sourcePickerReducer.pullback(
    state: \.sourcePickerState,
    action: /RootAction.sourcePickerAction,
    environment: { _ in .live(environment: .init()) }
  ),
  favoritesReducer.pullback(
    state: \.favoritesState,
    action: /RootAction.favoritesAction,
    environment: { _ in .live(environment: .init()) }
  ),
  .init { state, action, environment in
    return .none
  }
)
