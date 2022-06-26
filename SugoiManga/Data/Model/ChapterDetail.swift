//
//  ChapterDetail.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-05.
//

import Foundation

struct ChapterDetail: Equatable {
  let imageURLs: [URL]
  let imageRequestHeaders: [String: String]?
}

// MARK: - Mock

extension ChapterDetail {
  static let mock = Self(imageURLs: [], imageRequestHeaders: nil)
}
