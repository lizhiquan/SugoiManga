//
//  SourceSectionCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-25.
//

import ComposableArchitecture

struct SourceSectionState: Equatable, Identifiable {
  var id: String { title }
  let title: String
  var sources: IdentifiedArrayOf<LatestUpdatesState>
}

enum SourceSectionAction: Equatable {
  case sourceDetail(id: SourceID, action: LatestUpdatesAction)
}

let sourceSectionReducer = Reducer<
  SourceSectionState,
  SourceSectionAction,
  Void
>.combine(
  latestUpdatesReducer
    .forEach(
      state: \.sources,
      action: /SourceSectionAction.sourceDetail,
      environment: { _ in .live(environment: .init()) }
    ),
  .init { state, action, environment in
    return .none
  }
)
