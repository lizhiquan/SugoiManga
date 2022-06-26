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

  var body: some View {
    WithViewStore(store) { viewStore in
      List {
        ForEachStore(
          store.scope(
            state: \.sections,
            action: SourcePickerAction.sectionDetail(id:action:)
          )
        ) { sectionStore in
          SourceSectionView(store: sectionStore)
        }
      }
      .navigationTitle("Manga Sources")
      .onAppear { viewStore.send(.onAppear) }
    }
  }
}

struct SourcePickerView_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(["en", "vi_VN"], id: \.self) { id in
      NavigationView {
        SourcePickerView(
          store: Store(
            initialState: SourcePickerState(),
            reducer: sourcePickerReducer,
            environment: .dev(environment: .init())
          )
        )
        .environment(\.locale, .init(identifier: id))
      }
    }
  }
}
