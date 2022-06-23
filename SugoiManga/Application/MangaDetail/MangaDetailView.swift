//
//  MangaDetailView.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-04.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct MangaDetailView: View {
  let store: Store<MangaDetailState, MangaDetailAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      GeometryReader { geometry in
        List {
          Section {
            mangaInfo(in: geometry.size, viewStore: viewStore)
              .frame(maxWidth: .infinity)
              .foregroundColor(.primary)
              .listRowInsets(EdgeInsets())
              .listRowBackground(Color.clear)
          }
          .listStyle(.plain)
          chapterList(viewStore)
        }
        .refreshable {
          await viewStore.send(.fetch, while: \.isLoading)
        }
      }
      .navigationTitle(viewStore.manga.title)
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          if let isFavorite = viewStore.isFavorite {
            Button {
              viewStore.send(.toggleFavorite)
            } label: {
              Image(systemName: isFavorite ? "star.fill" : "star")
            }
          }
        }
      }
      .onAppear { viewStore.send(.onAppear) }
      .onDisappear { viewStore.send(.onDisappear) }
      .fullScreenCover(
        isPresented: viewStore.binding(
          get: \.isReading,
          send: MangaDetailAction.setReading(isPresented:)
        )
      ) {
        IfLetStore(
          store.scope(
            state: \.readingState,
            action: MangaDetailAction.readingAction
          )
        ) { store in
          ReadingView(store: store)
        }
      }
      .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
    }
  }

  func mangaInfo(in size: CGSize, viewStore: ViewStore<MangaDetailState, MangaDetailAction>) -> some View {
    VStack(spacing: 8) {
      KFImage(viewStore.manga.coverImageURL)
        .resizable()
        .scaledToFit()
        .shadow(radius: 5)
        .frame(maxWidth: size.width / 2.5)
        .frame(maxWidth: 200)
        .padding(.top, 8)

      Text(viewStore.manga.title)
        .font(.title2)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)
        .padding(.top, 8)

      if let author = viewStore.detail?.author {
        Text(author)
          .font(.caption)
          .fontWeight(.semibold)
      }

      if let summary = viewStore.detail?.summary {
        Text(summary)
          .font(.subheadline)
          .padding(.top, 8)
      }
    }
  }

  @ViewBuilder
  private func chapterList(
    _ viewStore: ViewStore<MangaDetailState, MangaDetailAction>
  ) -> some View {
    Section("Chapters") {
      if viewStore.isLoading {
        ProgressView()
          .hCenter()
      } else if let chapters = viewStore.detail?.chapters {
        ForEach(chapters.indices, id: \.self) { index in
          Button {
            viewStore.send(.selectChapterIndex(index))
          } label: {
            ChapterView(chapter: chapters[index])
          }
        }
      }
    }
  }
}

struct ChapterView: View {
  let chapter: Chapter

  var body: some View {
    HStack {
      Text(chapter.title)
        .lineLimit(1)
        .foregroundColor(.primary)

      Spacer()

      Text(chapter.updatedAt)
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
  }
}
