//
//  MangaDetail.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Foundation

struct MangaDetail {
    let updatedAt: Date?
    let chapters: [Chapter]
}

struct Chapter: Identifiable {
    let title: String
    let updatedAt: String
    let views: Int?
    let detailURL: URL

    var id: String { title }
}
