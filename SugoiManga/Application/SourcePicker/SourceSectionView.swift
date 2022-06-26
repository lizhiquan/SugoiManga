//
//  SourceSectionView.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-25.
//

import SwiftUI
import ComposableArchitecture

struct SourceSectionView: View {
  let store: Store<SourceSectionState, SourceSectionAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      Section(LocalizedStringKey(viewStore.id.localized)) {
        ForEachStore(
          store.scope(
            state: \.sources,
            action: SourceSectionAction.sourceDetail(id:action:)
          )
        ) { sourceStore in
          WithViewStore(sourceStore) { sourceViewStore in
            NavigationLink(
              sourceViewStore.source.name,
              destination: LatestUpdatesView(store: sourceStore)
            )
          }
        }
      }
    }
  }
}
