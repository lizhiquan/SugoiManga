//
//  SourcePickerView.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-11.
//

import SwiftUI
import ComposableArchitecture

struct SourcePickerView: View {
  let store: Store<SourcePickerState, SourcePickerAction>

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        VStack {
          List {
            ForEach(viewStore.sections) { section in
              Section(section.title) {
                ForEach(section.sources) { source in
                  Button {
                    viewStore.send(.sourceTapped(source))
                    dismiss()
                  } label: {
                    SourceView(
                      source: source,
                      selected: viewStore.selectedSource == source
                    )
                  }
                }
              }
            }
          }
        }
        .navigationTitle("Manga Sources")
      }
    }
  }
}

struct SourceView: View {
  let source: Source
  let selected: Bool

  var body: some View {
    HStack {
      Text(source.name)
        .foregroundColor(.primary)
      Spacer()
      if selected {
        Image(systemName: "checkmark.circle.fill")
      }
    }
  }
}

struct SourcePickerView_Previews: PreviewProvider {
  static var previews: some View {
    SourcePickerView(
      store: Store(
        initialState: SourcePickerState(selectedSource: sources[0]),
        reducer: sourcePickerReducer,
        environment: .dev(environment: SourcePickerEnvironment())
      )
    )
  }
}
