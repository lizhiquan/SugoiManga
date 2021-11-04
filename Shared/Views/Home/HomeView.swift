//
//  HomeView.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-02.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.fetching {
                    ProgressView()
                } else {
                    ScrollView {
                        let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.mangas) { manga in
                                MangaView(manga: manga)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Latest Updates")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.fetchMangas()
        }
    }
}
