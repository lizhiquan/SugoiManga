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

// MARK: - Mock

extension MangaDetail {
  static let mock = Self(
    summary: "summary",
    updatedAt: Date(),
    chapters: Chapter.mocks,
    author: "author",
    genres: ["Action"],
    status: .ongoing
  )
}
