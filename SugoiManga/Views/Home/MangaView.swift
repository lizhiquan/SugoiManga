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
                .foregroundColor(Color(UIColor.tertiarySystemBackground))

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
        .shadow(radius: 8)
        .aspectRatio(3/5, contentMode: .fit)
    }
}
