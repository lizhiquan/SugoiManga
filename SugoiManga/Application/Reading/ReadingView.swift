//
//  ReadingView.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-05.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct ReadingView: View {
  let store: Store<ReadingState, ReadingAction>
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        Group {
          if viewStore.isLoading && !viewStore.isRefreshing {
            ActivityIndicator(style: .large, isAnimating: true)
          }

          ZoomableScrollView {
            List(viewStore.imageURLs, id: \.self) { url in
              KFImage(url)
                .placeholder { progress in
                  ProgressView(progress)
                    .progressViewStyle(.circular)
                    .padding()
                }
                .requestModifier(imageRequestModifier(headers: viewStore.imageRequestHeaders))
                .resizable()
                .scaledToFill()
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
          }
        }
        .navigationTitle(viewStore.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar(viewStore) }
        .if(viewStore.isRefreshing || !viewStore.isLoading) { view in
          view.refreshable {
            await viewStore.send(.refresh, while: \.isRefreshing)
          }
        }
      }
      .navigationViewStyle(.stack)
      .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
      .onAppear { viewStore.send(.onAppear) }
      .onDisappear { viewStore.send(.onDisappear) }
    }
  }

  private func imageRequestModifier(headers: [String: String]?) -> AnyModifier {
    AnyModifier { request in
      var request = request
      headers?.forEach { key, value in
        request.setValue(value, forHTTPHeaderField: key)
      }
      return request
    }
  }

  private func toolbar(_ viewStore: ViewStore<ReadingState, ReadingAction>) -> some ToolbarContent {
    Group {
      ToolbarItemGroup(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
        }
      }

      ToolbarItemGroup(placement: .navigationBarTrailing) {
        Button {
          viewStore.send(.previousChapter)
        } label: {
          Image(systemName: "arrow.backward")
        }
        .disabled(viewStore.isFirstChapter)

        Button {
          viewStore.send(.nextChapter)
        } label: {
          Image(systemName: "arrow.forward")
        }
        .disabled(viewStore.isLastChapter)
      }
    }
  }
}
