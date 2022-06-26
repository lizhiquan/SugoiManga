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
        NavigationView {
          SourcePickerView(
            store: store.scope(
              state: \.sourcePickerState,
              action: RootAction.sourcePickerAction
            )
          )
        }
        .navigationViewStyle(.stack)
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

// MARK: - Previews

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(["en", "vi_VN"], id: \.self) { id in
      RootView(
        store: Store(
          initialState: RootState(),
          reducer: rootReducer,
          environment: .dev(environment: .init())
        )
      )
      .environment(\.locale, .init(identifier: id))
    }
  }
}
