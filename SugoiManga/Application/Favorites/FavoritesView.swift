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
          } else {
            ScrollView {
              let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]
              LazyVGrid(columns: columns, spacing: 12) {
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
