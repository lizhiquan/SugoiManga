//
//  MangaClient.swift
//  SugoiManga
//
//  Created by Vincent Le on 2022-06-15.
//

import ComposableArchitecture

struct MangaClient {
  var latestUpdateMangas: (_ sourceID: SourceID, _ page: Int) -> Effect<[Manga], ClientError>
  var mangaDetail: (_ sourceID: SourceID, _ url: URL) -> Effect<MangaDetail, ClientError>
  var chapterDetail: (_ sourceID: SourceID, _ url: URL) -> Effect<ChapterDetail, ClientError>
  var searchMangas: (_ sourceID: SourceID, _ keyword: String, _ page: Int) -> Effect<[Manga], ClientError>
}

// MARK: - Live

extension MangaClient {
  static let live = Self(
    latestUpdateMangas: { sourceID, page in
      service(for: sourceID)
        .latestUpdateMangas(page: page)
        .eraseToEffect()
    },
    mangaDetail: { sourceID, url in
      service(for: sourceID)
        .mangaDetail(url: url)
        .eraseToEffect()
    },
    chapterDetail: { sourceID, url in
      service(for: sourceID)
        .chapterDetail(url: url)
        .eraseToEffect()
    },
    searchMangas: { sourceID, keyword, page in
      service(for: sourceID)
        .searchMangas(keyword: keyword, page: page)
        .eraseToEffect()
    }
  )

  private static func service(for sourceID: SourceID) -> MangaService {
    switch sourceID {
    case .mangakakalot:
      return MangaKakalotService.shared
    case .nettruyen:
      return NetTruyenService.shared
    }
  }
}

// MARK: - Mock

extension MangaClient {
  static let mock = Self(
    latestUpdateMangas: { sourceID, page in
      fatalError("unmocked")
    },
    mangaDetail: { sourceID, url in
      fatalError("unmocked")
    },
    chapterDetail: { sourceID, url in
      fatalError("unmocked")
    },
    searchMangas: { sourceID, keyword, page in
      fatalError("unmocked")
    }
  )

  static let preview = Self(
    latestUpdateMangas: { sourceID, page in
      .init(value: page == 1 ? Manga.mocks : [])
    },
    mangaDetail: { sourceID, url in
      .init(value: .mock)
    },
    chapterDetail: { sourceID, url in
      .init(value: .mock)
    },
    searchMangas: { sourceID, keyword, page in
      .init(value: page == 1 ? Manga.mocks : [])
    }
  )
}
