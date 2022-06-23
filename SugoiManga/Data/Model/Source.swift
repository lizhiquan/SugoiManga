//
//  Source.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-27.
//

import Foundation

struct Source: Identifiable, Equatable {
  let id: SourceID
  let name: String
  let language: Language

  enum Language: CaseIterable {
    case english
    case vietnamese

    var localized: String {
      switch self {
      case .english:
        return "English"
      case .vietnamese:
        return "Vietnamese"
      }
    }
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Supported sources

enum SourceID: String {
  case mangakakalot
  case nettruyen
}

let sources = [
  Source(
    id: .mangakakalot,
    name: "MangaKakalot",
    language: .english
  ),
  Source(
    id: .nettruyen,
    name: "NetTruyen",
    language: .vietnamese
  )
]

// MARK: - Helper

func sourcesGroupedByLanguage() -> [(Source.Language, [Source])] {
  Source.Language.allCases.map { language in
    (language, sources.filter { $0.language == language })
  }
}

func findSource(with id: SourceID) -> Source? {
  sources.first(where: { $0.id == id })
}
