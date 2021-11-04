//
//  Manga.swift
//  SugoiManga (iOS)
//
//  Created by Chi-Quyen Le on 2021-11-03.
//

import Foundation

struct Manga: Identifiable {
    let title: String
    let description: String
    let author: String
    let coverImageURL: URL?
    let detailURL: URL
    let categories: [String]
    let status: Status
    let views: Int

    enum Status {
        case ongoing
        case finished
    }

    var id: String { title }
}
