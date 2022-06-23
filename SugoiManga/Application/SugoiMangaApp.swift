//
//  SugoiMangaApp.swift
//  Shared
//
//  Created by Vincent Le on 2021-11-02.
//

import SwiftUI
import ComposableArchitecture

@main
struct SugoiMangaApp: App {
  @Environment(\.scenePhase) var scenePhase

  var body: some Scene {
    WindowGroup {
      RootView(
        store: Store(
          initialState: RootState(),
          reducer: rootReducer,
          environment: .live(environment: .init())
        )
      )
    }
    .onChange(of: scenePhase) { _ in
      PersistenceController.shared.save()
    }
  }
}
