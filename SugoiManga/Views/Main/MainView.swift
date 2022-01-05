//
//  MainView.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-01-03.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Discover", systemImage: "square.grid.3x2")
                }
            FavoriteView()
                .tabItem {
                    Label("Favorite", systemImage: "star")
                }
        }
    }
}
