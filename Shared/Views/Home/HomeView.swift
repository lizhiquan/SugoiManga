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
            mangaList
                .navigationTitle("Latest Updates")
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always)
                )
                .toolbar {
                    if viewModel.isFetchingFromBeginning {
                        ProgressView()
                    } else {
                        Button {
                            viewModel.fetchFromBeginning()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.fetchFromBeginning()
        }
    }

    var mangaList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<viewModel.mangas.count, id: \.self) { i in
                        let manga = viewModel.mangas[i]
                        NavigationLink(destination: MangaDetailView(manga: manga)) {
                            MangaView(manga: manga)
                        }
                        .buttonStyle(.plain)
                        .id(i)
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: manga)
                        }
                    }

                    if viewModel.isFetchingNextPage {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            .onReceive(viewModel.scrollToTopPublisher) {
                proxy.scrollTo(0)
            }
        }
    }
}
