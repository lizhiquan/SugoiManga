//
//  MangaView.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import SwiftUI
import Kingfisher

struct MangaView: View {
    let manga: Manga

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            KFImage(manga.coverImageURL)
                .cancelOnDisappear(true)
                .resizable()
                .aspectRatio(2.5/3, contentMode: .fit)

            Text(manga.title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(8)
                .frame(height: 50)
        }
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
