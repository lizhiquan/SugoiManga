//
//  ReadingCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-19.
//

import ComposableArchitecture

struct ReadingState: Equatable {
  let manga: Manga
  let chapters: [Chapter]
  var currentIndex: Int
  var isLoading = false
  var detail: ChapterDetail?
  var alert: AlertState<ReadingAction>?

  var isFirstChapter: Bool { currentIndex == chapters.count - 1 }
  var isLastChapter: Bool { currentIndex == 0 }
  var currentChapter: Chapter { chapters[currentIndex] }
  var title: String { currentChapter.title }
  var imageURLs: [URL] { detail?.imageURLs ?? [] }
  var imageRequestHeaders: [String: String]? { detail?.imageRequestHeaders }
}

enum ReadingAction: Equatable {
  case onAppear
  case onDisappear
  case nextChapter
  case previousChapter
  case fetch
  case detailResponse(Result<ChapterDetail, ClientError>)
  case alertDismissed
}

struct ReadingEnvironment {}

let readingReducer = Reducer<
  ReadingState,
  ReadingAction,
  SystemEnvironment<ReadingEnvironment>
> { state, action, environment in
  struct FetchDetailID: Hashable {}

  switch action {
  case .onAppear:
    return .init(value: .fetch)

  case .onDisappear:
    return .cancel(id: FetchDetailID())

  case .nextChapter:
    state.currentIndex -= 1
    return .init(value: .fetch)

  case .previousChapter:
    state.currentIndex += 1
    return .init(value: .fetch)

  case .fetch:
    guard let source = sources.first(where: { $0.id == state.manga.sourceID }) else {
      return .none
    }
    state.detail = nil
    state.isLoading = true
    return environment.mangaClient.chapterDetail(source.id, state.currentChapter.detailURL)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(ReadingAction.detailResponse)
      .cancellable(id: FetchDetailID(), cancelInFlight: true)

  case .detailResponse(.success(let detail)):
    state.isLoading = false
    state.detail = detail
    return .none

  case .detailResponse(.failure(let error)):
    debugPrint(error)
    state.isLoading = false
    state.alert = .init(
      title: .init("Error"),
      message: .init(error.localizedDescription),
      dismissButton: .default(.init("OK"))
    )
    return .none

  case .alertDismissed:
    state.alert = nil
    return .none
  }
}
