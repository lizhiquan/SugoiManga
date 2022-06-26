//
//  Chapter.swift
//  SugoiManga (iOS)
//
//  Created by Vincent Le on 2021-11-05.
//

import Foundation

struct Chapter: Identifiable, Equatable {
  var id: String { title }
  let title: String
  let updatedAt: String
  let view: Int?
  let detailURL: URL
}

// MARK: - Mock

extension Chapter {
  static let mocks = [
    Self(
      title: "Chapter 1",
      updatedAt: "-",
      view: 1,
      detailURL: URL(string: "1")!
    ),
    Self(
      title: "Chapter 2",
      updatedAt: "-",
      view: 2,
      detailURL: URL(string: "2")!
    )
  ]
}
