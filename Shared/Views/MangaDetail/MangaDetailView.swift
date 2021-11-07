//
//  MangaDetailView.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-04.
//

import SwiftUI
import Kingfisher

struct MangaDetailView: View {
    @ObservedObject private var viewModel: MangaDetailViewModel

    init(manga: Manga) {
        viewModel = MangaDetailViewModel(manga: manga)
    }

    var body: some View {
        GeometryReader { geometry in
            List {
                mangaInfo(in: geometry.size)
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                chapters
            }
        }
        .navigationTitle(viewModel.title)
        .onAppear {
            viewModel.fetchDetail()
        }
    }

    func mangaInfo(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            KFImage(viewModel.coverImageURL)
                .resizable()
                .scaledToFit()
                .shadow(radius: 5)
                .frame(maxWidth: size.width / 2.5)
                .padding(.top)

            Text(viewModel.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()

            if let author = viewModel.author {
                Text(author)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.bottom)
            }

            Text(viewModel.description)
                .font(.subheadline)
        }
    }

    var chapters: some View {
        Section("Chapters") {
            if viewModel.fetching {
                ProgressView()
            }

            if let chapters = viewModel.chapters {
                ForEach(chapters.indices, id: \.self) { index in
                    let chapter = chapters[index]
                    let readingView = ReadingView(chapters: chapters, chapterIndex: index)

                    NavigationLink(destination: readingView) {
                        HStack {
                            Text(chapter.title)
                                .lineLimit(1)
                            Spacer()
                            Text(chapter.updatedAt)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}
