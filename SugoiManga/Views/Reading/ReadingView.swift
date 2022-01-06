//
//  ReadingView.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-05.
//

import SwiftUI
import Kingfisher

struct ReadingView: View {
    @ObservedObject private var viewModel: ReadingViewModel
    @Environment(\.presentationMode) var presentationMode

    init(chapters: [Chapter], chapterIndex: Int, mangaService: MangaService) {
        viewModel = ReadingViewModel(
            chapters: chapters,
            chapterIndex: chapterIndex,
            mangaService: mangaService
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.fetching {
                    ProgressView()
                        .padding()
                }

                ZoomableScrollView {
                    List {
                        ForEach(viewModel.imageURLs, id: \.self) { url in
                            KFImage(url)
                                .placeholder { progress in
                                    ProgressView(progress)
                                        .progressViewStyle(.circular)
                                        .padding()
                                }
                                .requestModifier(imageRequestModifier)
                                .resizable()
                                .scaledToFill()
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
        }
        .navigationViewStyle(.stack)
        .onAppear { viewModel.fetchCurrentChapter() }
    }

    private var imageRequestModifier: AnyModifier {
        AnyModifier { request in
            var request = request
            viewModel.imageRequestHeaders?.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
            return request
        }
    }

    private var toolbar: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.fetchPrevChapter()
                } label: {
                    Image(systemName: "arrow.backward")
                }
                .disabled(!viewModel.hasPrevChapter)

                Button {
                    viewModel.fetchNextChapter()
                } label: {
                    Image(systemName: "arrow.forward")
                }
                .disabled(!viewModel.hasNextChapter)
            }
        }
    }
}
