//
//  SugoiMangaApp.swift
//  Shared
//
//  Created by Chi-Quyen Le on 2021-11-02.
//

import SwiftUI

@main
struct SugoiMangaApp: App {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
