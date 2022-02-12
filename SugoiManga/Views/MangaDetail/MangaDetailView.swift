//
//  MangaDetailView.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-04.
//

import SwiftUI
import Kingfisher
import CoreData

struct MangaDetailView: View {
    @ObservedObject private var viewModel: MangaDetailViewModel
    @State private var isReading = false
    @State private var selectedChapterIndex = 0

    init(manga: Manga, context: NSManagedObjectContext) {
        viewModel = MangaDetailViewModel(manga: manga, context: context)
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
            .refreshable {
                await viewModel.fetchDetailAsync()
            }
        }
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.markAsFavorite()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                }
            }
        }
        .onAppear {
            viewModel.fetchDetail()
        }
        .fullScreenCover(isPresented: $isReading) {
            ReadingView(
                chapters: viewModel.chapters,
                chapterIndex: selectedChapterIndex,
                mangaService: viewModel.mangaService
            )
        }
    }

    func mangaInfo(in size: CGSize) -> some View {
        VStack(spacing: 8) {
            KFImage(viewModel.coverImageURL)
                .resizable()
                .scaledToFit()
                .shadow(radius: 5)
                .frame(maxWidth: size.width / 2.5)
                .frame(maxWidth: 200)
                .padding(.top, 8)

            Text(viewModel.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            if let author = viewModel.author {
                Text(author)
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            if let summary = viewModel.summary {
                Text(summary)
                    .font(.subheadline)
                    .padding(.top, 8)
            }
        }
    }

    var chapters: some View {
        Section("Chapters") {
            if viewModel.fetching {
                ProgressView()
                    .center()
            }

            if let chapters = viewModel.chapters {
                ForEach(chapters.indices, id: \.self) { index in
                    let chapter = chapters[index]

                    Button {
                        selectedChapterIndex = index
                        isReading = true
                    } label: {
                        ChapterView(chapter: chapter)
                    }
                }
            }
        }
    }
}

struct ChapterView: View {
    let chapter: Chapter

    var body: some View {
        HStack {
            Text(chapter.title)
                .lineLimit(1)
                .foregroundColor(.primary)

            Spacer()

            Text(chapter.updatedAt)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
