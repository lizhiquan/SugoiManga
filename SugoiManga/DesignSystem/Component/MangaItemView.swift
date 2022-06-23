//
//  MangaItemView.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-03.
//

import SwiftUI
import Kingfisher

struct MangaItemView: View {
  let manga: Manga

  var body: some View {
    ZStack {
      Rectangle()
        .foregroundColor(Color(UIColor.systemBackground))

      VStack(spacing: 0) {
        GeometryReader { geometry in
          KFImage(manga.coverImageURL)
            .placeholder {
              ProgressView()
            }
            .cancelOnDisappear(true)
            .resizable()
            .scaledToFill()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }

        Text(manga.title)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.primary)
          .padding(8)
          .frame(height: 60)
          .frame(maxWidth: .infinity)
          .multilineTextAlignment(.center)
      }
    }
    .cornerRadius(8)
    .shadow(color: .gray, radius: 8)
    .aspectRatio(3/5, contentMode: .fit)
  }
}

struct MangaItemView_Previews: PreviewProvider {
  static var previews: some View {
    MangaItemView(
      manga: Manga(
        title: "title",
        coverImageURL: nil,
        detailURL: URL(string: "123")!,
        genres: [],
        status: nil,
        view: 1,
        sourceID: .mangakakalot
      )
    )
  }
}
