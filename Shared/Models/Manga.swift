//
//  Manga.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Foundation

struct Manga: Identifiable, Equatable {
    let title: String
    let description: String
    let author: String?
    let coverImageURL: URL?
    let detailURL: URL
    let genres: [String]
    let status: Status
    let view: Int

    enum Status {
        case ongoing
        case completed
    }

    var id: String { title }
}
