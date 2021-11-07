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
                    mangaList
                }
            }
            .navigationTitle("Latest Updates")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                viewModel.performSearch()
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.fetchLatestMangas()
        }
    }

    var mangaList: some View {
        ScrollView {
            let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.mangas) { manga in
                    NavigationLink(destination: MangaDetailView(manga: manga)) {
                        MangaView(manga: manga)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}
