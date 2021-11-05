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
        ZStack {
            Rectangle()
                .foregroundColor(.white)

            VStack(spacing: 0) {
                KFImage(manga.coverImageURL)
                    .cancelOnDisappear(true)
                    .resizable()
                    .aspectRatio(2.5/3, contentMode: .fit)

                Text(manga.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(8)
                    .frame(height: 65)
                    .frame(maxWidth: .infinity)
            }
        }
        .cornerRadius(8)
        .shadow(radius: 8)
    }
}
