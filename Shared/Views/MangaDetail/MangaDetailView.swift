//
//  MangaDetailView.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-04.
//

import SwiftUI

struct MangaDetailView: View {
    let manga: Manga

    @ObservedObject private var viewModel = MangaDetailViewModel()

    var body: some View {
        Text(manga.description)
            .navigationTitle(manga.title)
    }
}
