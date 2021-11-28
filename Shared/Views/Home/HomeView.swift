//
//  HomeView.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-02.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            mangaList
                .navigationTitle("Latest Updates")
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always)
                )
                .toolbar { toolbar }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.fetchFromBeginning()
        }
    }

    private var mangaList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<viewModel.mangas.count, id: \.self) { i in
                        let manga = viewModel.mangas[i]
                        let detailView = MangaDetailView(
                            manga: manga,
                            mangaService: viewModel.mangaSource.service
                        )
                        NavigationLink(destination: detailView) {
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

    private var toolbar: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Menu {
                    ForEach(MangaSource.allCases) { source in
                        Button {
                            viewModel.selectSource(source)
                        } label: {
                            Text(source.rawValue)
                            if viewModel.mangaSource == source {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "books.vertical")
                }
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
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
    }
}
