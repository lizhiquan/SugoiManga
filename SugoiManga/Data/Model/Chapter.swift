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
