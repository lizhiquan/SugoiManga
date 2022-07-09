//
//  LatestUpdatesView.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-12.
//

import SwiftUI
import ComposableArchitecture

struct LatestUpdatesView: View {
  let store: Store<LatestUpdatesState, LatestUpdatesAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      Group {
        if viewStore.isLoading {
          ActivityIndicator(
            style: .large,
            isAnimating: viewStore.isLoading
          )
          .vCenter()
        } else {
          ScrollView {
            VStack {
              mangaList(viewStore)
                .padding()
              if viewStore.isLoadingPage {
                ActivityIndicator(
                  style: .medium,
                  isAnimating: viewStore.isLoadingPage
                )
                .padding()
              }
            }
          }
        }
      }
      .navigationTitle("Latest Updates")
      .searchable(
        text: viewStore.binding(
          get: \.searchQuery,
          send: LatestUpdatesAction.searchQueryChanged
        )
      )
      .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
      .onAppear { viewStore.send(.onAppear) }
      .onDisappear { viewStore.send(.onDisappear) }
    }
  }

  @ViewBuilder
  private func mangaList(
    _ viewStore: ViewStore<LatestUpdatesState, LatestUpdatesAction>
  ) -> some View {
    MangaGrid {
      ForEachStore(
        store.scope(
          state: \.mangas,
          action: LatestUpdatesAction.mangaDetail(id:action:)
        )
      ) { mangaStore in
        WithViewStore(mangaStore) { mangaViewStore in
          NavigationLink(destination: MangaDetailView(store: mangaStore)) {
            MangaItemView(manga: mangaViewStore.manga)
              .onAppear {
                viewStore.send(.fetchNextPageIfNeeded(currentItemID: mangaViewStore.id))
              }
          }
        }
      }
    }
  }
}

struct LatestUpdatesView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(["en", "vi_VN"], id: \.self) { id in
      NavigationView {
        LatestUpdatesView(
          store: Store(
            initialState: LatestUpdatesState(source: sources[0]),
            reducer: latestUpdatesReducer,
            environment: .dev(environment: .init())
          )
        )
      }
      .environment(\.locale, .init(identifier: id))
    }
  }
}
