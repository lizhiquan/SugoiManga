//
//  MangaDetail.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-03.
//

import Foundation

struct MangaDetail: Equatable {
  let summary: String
  let updatedAt: Date?
  let chapters: [Chapter]
  let author: String
  let genres: [String]
  let status: Manga.Status
}
