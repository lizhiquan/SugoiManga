//
//  Manga.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-03.
//

import Foundation

struct Manga: Identifiable, Equatable {
  typealias ID = URL
  var id: ID { detailURL }
  let title: String
  let coverImageURL: URL?
  let detailURL: URL
  let genres: [String]
  let status: Status?
  let view: Int
  let sourceID: SourceID

  enum Status: Int32 {
    case ongoing = 0
    case completed = 1
  }

  init(
    title: String,
    coverImageURL: URL?,
    detailURL: URL,
    genres: [String],
    status: Manga.Status?,
    view: Int,
    sourceID: SourceID
  ) {
    self.title = title
    self.coverImageURL = coverImageURL
    self.detailURL = detailURL
    self.genres = genres
    self.status = status
    self.view = view
    self.sourceID = sourceID
  }

  init(with favorite: FavoriteManga) {
    self.title = favorite.title!
    self.coverImageURL = favorite.coverImageURL
    self.detailURL = favorite.detailURL!
    self.genres = (favorite.genres as? [String]) ?? []
    self.status = favorite.status.flatMap { Manga.Status(rawValue: $0.int32Value) }
    self.view = favorite.view?.intValue ?? 0
    self.sourceID = SourceID(rawValue: favorite.sourceID!)!
  }
}

// MARK: - Mock

extension Manga {
  static let mock1 = Self(
    title: "1",
    coverImageURL: nil,
    detailURL: URL(string: "1")!,
    genres: ["Action"],
    status: .ongoing,
    view: 100,
    sourceID: .mangakakalot
  )

  static let mock2 = Self(
    title: "2",
    coverImageURL: nil,
    detailURL: URL(string: "2")!,
    genres: ["Romance"],
    status: .completed,
    view: 200,
    sourceID: .mangakakalot
  )

  static let mocks: [Self] = [.mock1, .mock2]
}
