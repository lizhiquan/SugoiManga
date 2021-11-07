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

    init(chapters: [Chapter], chapterIndex: Int) {
        viewModel = ReadingViewModel(chapters: chapters, chapterIndex: chapterIndex)
    }

    var body: some View {
        ZoomableScrollView {
            ScrollView {
                if viewModel.fetching {
                    ProgressView()
                }
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
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
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
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                viewModel.fetchCurrentChapter()
            } label: {
                Image(systemName: "arrow.clockwise")
            }

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
