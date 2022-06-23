//
//  SourcePickerCore.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-11.
//

import ComposableArchitecture

struct SourcePickerState: Equatable {
  struct SourceSection: Equatable, Identifiable {
    var id: String { title }
    let title: String
    let sources: [Source]
  }

  var sections: [SourceSection] = sourcesGroupedByLanguage()
    .map { language, sources in
      SourceSection(
        title: language.localized,
        sources: sources
      )
    }

  var selectedSource: Source
}

enum SourcePickerAction: Equatable {
  case sourceTapped(Source)
}

struct SourcePickerEnvironment {}

let sourcePickerReducer = Reducer<
  SourcePickerState,
  SourcePickerAction,
  SystemEnvironment<SourcePickerEnvironment>
> { state, action, environment in
  switch action {
  case .sourceTapped(let source):
    state.selectedSource = source
    return .none
  }
}
