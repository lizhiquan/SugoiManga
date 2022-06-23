//
//  RootView.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-01-03.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
  let store: Store<RootState, RootAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      TabView {
        LatestUpdatesView(
          store: store.scope(
            state: \.latestUpdatesState,
            action: RootAction.latestUpdatesAction
          )
        )
        .tabItem {
          Label("Discover", systemImage: "square.grid.3x2")
        }

        FavoritesView(
          store: store.scope(
            state: \.favoritesState,
            action: RootAction.favoritesAction
          )
        )
        .tabItem {
          Label("Favorites", systemImage: "star")
        }
      }
    }
  }
}
