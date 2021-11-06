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
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                chapters
            }
        }
        .navigationTitle(viewModel.manga.title)
        .onAppear {
            viewModel.fetchDetail()
        }
    }

    func mangaInfo(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            KFImage(viewModel.manga.coverImageURL)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size.width / 2.5)

            Text(viewModel.manga.title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()

            if !viewModel.manga.author.isEmpty {
                Text(viewModel.manga.author)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.bottom)
            }

            Text(viewModel.manga.description)
                .font(.subheadline)
        }
    }

    var chapters: some View {
        Section("Chapters") {
            if viewModel.fetching {
                ProgressView()
            }
            if let chapters = viewModel.mangaDetail?.chapters {
                ForEach(chapters) { chapter in
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
