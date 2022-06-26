//
//  SourcePickerCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-11.
//

import ComposableArchitecture

struct SourcePickerState: Equatable {
  var sections = IdentifiedArrayOf<SourceSectionState>()
}

enum SourcePickerAction: Equatable {
  case onAppear
  case sectionDetail(id: Source.Language, action: SourceSectionAction)
}

struct SourcePickerEnvironment {}

let sourcePickerReducer = Reducer<
  SourcePickerState,
  SourcePickerAction,
  SystemEnvironment<SourcePickerEnvironment>
>.combine(
  sourceSectionReducer.forEach(
    state: \.sections,
    action: /SourcePickerAction.sectionDetail,
    environment: { _ in }
  ),
  .init { state, action, environment in
    switch action {
    case .onAppear:
      let sourceSections = sourcesGroupedByLanguage()
        .map { language, sources in
          SourceSectionState(
            id: language,
            sources: .init(uniqueElements: sources.map {
              LatestUpdatesState(source: $0)
            })
          )
        }
      state.sections = .init(uniqueElements: sourceSections)
      return .none

    case .sectionDetail:
      return .none
    }
  }
)
