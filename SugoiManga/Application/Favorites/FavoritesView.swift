//
//  FavoritesView.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-01-03.
//

import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
  let store: Store<FavoritesState, FavoritesAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        Group {
          if viewStore.isLoading {
            ActivityIndicator(
              style: .large,
              isAnimating: viewStore.isLoading
            )
            .vCenter()
          } else if viewStore.mangas.isEmpty {
            Text("No favorites")
          } else {
            ScrollView {
              MangaGrid {
                ForEachStore(
                  store.scope(
                    state: \.mangas,
                    action: FavoritesAction.mangaDetail(id:action:)
                  )
                ) { mangaStore in
                  WithViewStore(mangaStore) { mangaViewStore in
                    NavigationLink(destination: MangaDetailView(store: mangaStore)) {
                      MangaItemView(manga: mangaViewStore.manga)
                    }
                    .buttonStyle(.plain)
                  }
                }
              }
              .padding()
            }
          }
        }
        .navigationTitle("Favorites")
      }
      .navigationViewStyle(.stack)
      .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
      .onAppear { viewStore.send(.onAppear) }
    }
  }
}

struct FavoritesView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(["en", "vi_VN"], id: \.self) { id in
      FavoritesView(
        store: Store(
          initialState: FavoritesState(),
          reducer: favoritesReducer,
          environment: .dev(environment: .init())
        )
      )
      .environment(\.locale, .init(identifier: id))
    }
  }
}
