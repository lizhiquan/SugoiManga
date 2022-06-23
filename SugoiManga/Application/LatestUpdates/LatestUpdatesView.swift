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
              VStack {
                mangaList(viewStore)
                  .padding()
                ActivityIndicator(
                  style: .medium,
                  isAnimating: viewStore.isLoadingPage
                )
              }
            }
          }
        }
        .navigationTitle("Latest Updates")
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Sources") {
              viewStore.send(.setSourcePicker(isPresented: true))
            }
          }
        }
      }
      .navigationViewStyle(.stack)
      .sheet(
        isPresented: viewStore.binding(
          get: \.sourcePickerPresented,
          send: LatestUpdatesAction.setSourcePicker(isPresented:)
        )
      ) {
        IfLetStore(
          store.scope(
            state: \.sourcePickerState,
            action: LatestUpdatesAction.sourcePickerAction
          )
        ) { store in
          SourcePickerView(store: store)
        }
      }
      .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
      .onAppear { viewStore.send(.onAppear) }
      .onDisappear { viewStore.send(.onDisappear) }
    }
  }

  @ViewBuilder
  private func mangaList(
    _ viewStore: ViewStore<LatestUpdatesState, LatestUpdatesAction>
  ) -> some View {
    let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]
    LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
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
          .buttonStyle(.plain)
        }
      }
    }
  }
}

struct LatestUpdatesView_Previews: PreviewProvider {
  static var previews: some View {
    LatestUpdatesView(
      store: Store(
        initialState: LatestUpdatesState(source: sources[0]),
        reducer: latestUpdatesReducer,
        environment: .dev(
          environment: LatestUpdatesEnvironment(userDefaults: .init())
        )
      )
    )
  }
}
